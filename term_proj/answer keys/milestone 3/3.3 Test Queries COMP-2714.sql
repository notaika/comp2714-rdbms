-- =========================================================
-- LabTracker - Reference test_queries.sql
-- Meaningful validation queries for schema + seed data
-- =========================================================

SET search_path TO lab_tracker_reference;

-- ---------------------------------------------------------
-- 1) Row counts by table
-- Expected with reference seed:
-- course=1, term=3, student=18, section=6,
-- enrollment=18, lab_session=18, progress=36, progress_log=3
-- ---------------------------------------------------------
SELECT 'course' AS table_name, COUNT(*) AS row_count FROM course
UNION ALL
SELECT 'term', COUNT(*) FROM term
UNION ALL
SELECT 'student', COUNT(*) FROM student
UNION ALL
SELECT 'section', COUNT(*) FROM section
UNION ALL
SELECT 'enrollment', COUNT(*) FROM enrollment
UNION ALL
SELECT 'lab_session', COUNT(*) FROM lab_session
UNION ALL
SELECT 'progress', COUNT(*) FROM progress
UNION ALL
SELECT 'progress_log', COUNT(*) FROM progress_log
ORDER BY table_name;

-- ---------------------------------------------------------
-- 2) Sections offered in each term/course
-- ---------------------------------------------------------
SELECT
    t.term_code,
    c.crs_code,
    s.sec_crn,
    s.sec_type,
    s.sec_set,
    s.sec_day,
    s.sec_start_time,
    s.sec_end_time
FROM section s
JOIN course c ON c.crs_code = s.crs_code
JOIN term t   ON t.term_code = s.term_code
ORDER BY s.sec_crn;

-- ---------------------------------------------------------
-- 3) Student enrollment counts by section
-- Each reference lab section should show 3 students.
-- ---------------------------------------------------------
SELECT
    e.sec_crn,
    COUNT(*) AS enrolled_students
FROM enrollment e
GROUP BY e.sec_crn
ORDER BY e.sec_crn;

-- ---------------------------------------------------------
-- 4) Lab sessions scheduled per section
-- Each reference section should have 3 lab sessions.
-- ---------------------------------------------------------
SELECT
    ls.sec_crn,
    COUNT(*) AS lab_count,
    MIN(ls.meeting_date) AS first_meeting,
    MAX(ls.meeting_date) AS last_meeting
FROM lab_session ls
GROUP BY ls.sec_crn
ORDER BY ls.sec_crn;

-- ---------------------------------------------------------
-- 5) Progress counts per lab session
-- In this seed, labs 1 and 2 per section have progress; lab 3 does not yet.
-- ---------------------------------------------------------
SELECT
    ls.lab_id,
    ls.sec_crn,
    ls.lab_num,
    COUNT(p.stu_id) AS progress_rows
FROM lab_session ls
LEFT JOIN progress p
    ON p.lab_id = ls.lab_id
GROUP BY ls.lab_id, ls.sec_crn, ls.lab_num
ORDER BY ls.lab_id;

-- ---------------------------------------------------------
-- 6) Rich join: student progress details
-- Useful for visually checking the core business process.
-- ---------------------------------------------------------
SELECT
    p.lab_id,
    ls.lab_num,
    ls.sec_crn,
    s.stu_id,
    s.stu_fname,
    s.stu_lname,
    p.attendance,
    p.preparedness,
    p.self_assessment,
    p.instructor_assessment
FROM progress p
JOIN student s
    ON s.stu_id = p.stu_id
JOIN lab_session ls
    ON ls.lab_id = p.lab_id
ORDER BY ls.sec_crn, ls.lab_num, s.stu_id;

-- ---------------------------------------------------------
-- 7) Students missing a polished resubmission
-- ---------------------------------------------------------
SELECT
    p.lab_id,
    ls.sec_crn,
    ls.lab_num,
    p.stu_id,
    s.stu_fname,
    s.stu_lname,
    p.polished_resubmission
FROM progress p
JOIN student s
    ON s.stu_id = p.stu_id
JOIN lab_session ls
    ON ls.lab_id = p.lab_id
WHERE p.polished_resubmission IS NULL
ORDER BY ls.sec_crn, ls.lab_num, p.stu_id;

-- ---------------------------------------------------------
-- 8) Assessment summary by section
-- ---------------------------------------------------------
SELECT
    p.sec_crn,
    ROUND(AVG(p.self_assessment)::numeric, 2) AS avg_self_assessment,
    ROUND(AVG(p.instructor_assessment)::numeric, 2) AS avg_instructor_assessment,
    COUNT(*) AS graded_rows
FROM progress p
WHERE p.instructor_assessment IS NOT NULL
GROUP BY p.sec_crn
ORDER BY p.sec_crn;

-- ---------------------------------------------------------
-- 9) Audit log joined back to progress and student context
-- ---------------------------------------------------------
SELECT
    pl.log_id,
    pl.changed_by,
    pl.changed_at,
    pl.what_changed,
    pl.lab_id,
    ls.sec_crn,
    ls.lab_num,
    pl.stu_id
FROM progress_log pl
JOIN progress p
    ON p.lab_id = pl.lab_id
   AND p.stu_id = pl.stu_id
JOIN lab_session ls
    ON ls.lab_id = pl.lab_id
ORDER BY pl.log_id;

-- ---------------------------------------------------------
-- 10) Integrity query: should return ZERO rows
-- Progress must belong to an existing enrollment in the same section.
-- ---------------------------------------------------------
SELECT
    p.lab_id,
    p.stu_id,
    p.sec_crn
FROM progress p
LEFT JOIN enrollment e
    ON e.sec_crn = p.sec_crn
   AND e.stu_id  = p.stu_id
WHERE e.stu_id IS NULL;

-- ---------------------------------------------------------
-- 11) Integrity query: should return ZERO rows
-- Progress section must match the lab session's section.
-- ---------------------------------------------------------
SELECT
    p.lab_id,
    p.stu_id,
    p.sec_crn AS progress_section,
    ls.sec_crn AS lab_section
FROM progress p
JOIN lab_session ls
    ON ls.lab_id = p.lab_id
WHERE p.sec_crn <> ls.sec_crn;

-- ---------------------------------------------------------
-- 12) Integrity query: should return ZERO rows
-- No duplicate lab numbers inside the same section.
-- ---------------------------------------------------------
SELECT
    sec_crn,
    lab_num,
    COUNT(*) AS duplicate_count
FROM lab_session
GROUP BY sec_crn, lab_num
HAVING COUNT(*) > 1;

-- ---------------------------------------------------------
-- 13) Constraint test: invalid attendance should fail
-- DO block catches the error so the script continues cleanly.
-- ---------------------------------------------------------
DO $$
BEGIN
    BEGIN
        INSERT INTO progress (
            lab_id,
            stu_id,
            sec_crn,
            attendance,
            preparedness
        )
        VALUES (1, 'A001', 'L01', 'unknown', TRUE);

        RAISE EXCEPTION 'FAIL: invalid attendance insert unexpectedly succeeded.';
    EXCEPTION
        WHEN check_violation THEN
            RAISE NOTICE 'PASS: invalid attendance was rejected.';
    END;
END $$;

-- ---------------------------------------------------------
-- 14) Constraint test: progress for non-existent student should fail
-- ---------------------------------------------------------
DO $$
BEGIN
    BEGIN
        INSERT INTO progress (
            lab_id,
            stu_id,
            sec_crn,
            attendance,
            preparedness
        )
        VALUES (1, 'ZZZ999', 'L01', 'present', TRUE);

        RAISE EXCEPTION 'FAIL: non-existent student insert unexpectedly succeeded.';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'PASS: non-existent student was rejected.';
    END;
END $$;

-- ---------------------------------------------------------
-- 15) Constraint test: duplicate enrollment should fail
-- ---------------------------------------------------------
DO $$
BEGIN
    BEGIN
        INSERT INTO enrollment (
            sec_crn,
            stu_id,
            enr_enrolled_at,
            enr_status
        )
        VALUES ('L01', 'A001', CURRENT_TIMESTAMP, 'enrolled');

        RAISE EXCEPTION 'FAIL: duplicate enrollment unexpectedly succeeded.';
    EXCEPTION
        WHEN unique_violation THEN
            RAISE NOTICE 'PASS: duplicate enrollment was rejected.';
    END;
END $$;

-- ---------------------------------------------------------
-- 16) Constraint test: progress in the wrong section should fail
-- Student A001 is enrolled in L01, not L02.
-- ---------------------------------------------------------
DO $$
BEGIN
    BEGIN
        INSERT INTO progress (
            lab_id,
            stu_id,
            sec_crn,
            attendance,
            preparedness
        )
        VALUES (4, 'A001', 'L02', 'present', TRUE);

        RAISE EXCEPTION 'FAIL: cross-section progress unexpectedly succeeded.';
    EXCEPTION
        WHEN foreign_key_violation THEN
            RAISE NOTICE 'PASS: cross-section progress was rejected.';
    END;
END $$;
