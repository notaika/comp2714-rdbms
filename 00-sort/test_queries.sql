SET search_path TO lab_tracker_group_10;

-- Row Counts
SELECT 'department' AS table_name, COUNT(*) AS row_count FROM department
UNION ALL
SELECT 'term' AS table_name, COUNT(*) AS row_count FROM term
UNION ALL
SELECT 'set' AS table_name, COUNT(*) AS row_count FROM set
UNION ALL
SELECT 'user' AS table_name, COUNT(*) AS row_count FROM "user"
UNION ALL
SELECT 'professor' AS table_name, COUNT(*) AS row_count FROM professor
UNION ALL
SELECT 'student' AS table_name, COUNT(*) AS row_count FROM student
UNION ALL
SELECT 'course' AS table_name, COUNT(*) AS row_count FROM course
UNION ALL
SELECT 'location' AS table_name, COUNT(*) AS row_count FROM location
UNION ALL
SELECT 'section' AS table_name, COUNT(*) AS row_count FROM section
UNION ALL
SELECT 'lab' AS table_name, COUNT(*) AS row_count FROM lab
UNION ALL
SELECT 'lab_session' AS table_name, COUNT(*) AS row_count FROM lab_session
UNION ALL
SELECT 'progress' AS table_name, COUNT(*) AS row_count FROM progress
UNION ALL
SELECT 'progress_log' AS table_name, COUNT(*) AS row_count FROM progress_log;

-- Sections with Course, Term, and Location
SELECT s.section_id,
       s.crs_code,
       c.crs_title,
       s.term_code,
       t.term_name,
       s.loc_code,
       l.loc_campus,
       l.loc_building,
       l.loc_room,
       s.sec_days
FROM section s
JOIN course c ON s.crs_code = c.crs_code
JOIN term t ON s.term_code = t.term_code
JOIN location l ON s.loc_code = l.loc_code
ORDER BY s.section_id;

-- Labs by Section
SELECT lb.section_id,
       lb.lab_name,
       lb.lab_type,
       lb.deliverable,
       s.crs_code,
       s.term_code
FROM lab lb
JOIN section s ON lb.section_id = s.section_id
ORDER BY lb.section_id;

-- Lab Sessions with Set, Professor, and Location
SELECT ls.session_id,
       ls.section_id,
       st.set_name,
       st.set_program,
       p.prof_first_name || ' ' || p.prof_last_name AS professor_name,
       ls.loc_code,
       l.loc_campus,
       l.loc_building,
       l.loc_room,
       ls.ses_meet_dates,
       ls.ses_due_dates,
       ls.ses_start_time,
       ls.ses_end_time
FROM lab_session ls
JOIN set st ON ls.set_id = st.set_code
JOIN professor p ON ls.prof_id = p.prof_id
JOIN location l ON ls.loc_code = l.loc_code
ORDER BY ls.session_id;

-- Students by Set
SELECT stu_set, COUNT(*) AS student_count
FROM student
GROUP BY stu_set
ORDER BY stu_set;

-- Students with Progress
SELECT p.prog_id,
       p.session_id,
       s.stu_id,
       s.stu_first_name,
       s.stu_last_name,
       p.prog_attendance,
       p.prog_preparedness,
       p.prog_self_score,
       p.prog_prof_score
FROM progress p
JOIN student s ON p.stu_id = s.stu_id
ORDER BY p.prog_id;

-- Progress Log History
SELECT pl.log_id,
       pl.prog_id,
       p.stu_id,
       p.session_id,
       pl.crs_code,
       pl.log_changes,
       pl.log_timestamp,
       pl.weight
FROM progress_log pl
JOIN progress p ON pl.prog_id = p.prog_id
ORDER BY pl.log_timestamp;

-- Average Professor Score by Student
SELECT s.stu_id,
       s.stu_first_name,
       s.stu_last_name,
       ROUND(AVG(p.prog_prof_score), 2) AS avg_prof_score
FROM student s
JOIN progress p ON s.stu_id = p.stu_id
GROUP BY s.stu_id, s.stu_first_name, s.stu_last_name
ORDER BY avg_prof_score DESC, s.stu_id;

-- Attendance Summary
SELECT prog_attendance, COUNT(*) AS total_records
FROM progress
GROUP BY prog_attendance
ORDER BY prog_attendance;

-- Sessions per Professor
SELECT p.prof_id,
       p.prof_first_name,
       p.prof_last_name,
       COUNT(ls.session_id) AS total_sessions
FROM professor p
LEFT JOIN lab_session ls ON p.prof_id = ls.prof_id
GROUP BY p.prof_id, p.prof_first_name, p.prof_last_name
ORDER BY total_sessions DESC, p.prof_id;

-- Sections per Term
SELECT term_code, COUNT(*) AS total_sections
FROM section
GROUP BY term_code
ORDER BY term_code;

-- Progress Records per Student
SELECT s.stu_id,
       s.stu_first_name,
       s.stu_last_name,
       COUNT(p.prog_id) AS total_progress_records
FROM student s
LEFT JOIN progress p ON s.stu_id = p.stu_id
GROUP BY s.stu_id, s.stu_first_name, s.stu_last_name
ORDER BY total_progress_records DESC, s.stu_id;

-- Data Quality Check: Sections Missing Labs
SELECT s.section_id, s.crs_code, s.term_code
FROM section s
LEFT JOIN lab lb ON s.section_id = lb.section_id
WHERE lb.section_id IS NULL;

-- Data Quality Check: Progress Rows Without Logs
SELECT p.prog_id, p.stu_id, p.session_id
FROM progress p
LEFT JOIN progress_log pl ON p.prog_id = pl.prog_id
WHERE pl.prog_id IS NULL;

-- Data Quality Check: Sessions with Invalid Time Order
SELECT session_id, ses_start_time, ses_end_time
FROM lab_session
WHERE ses_start_time >= ses_end_time;

-- Data Quality Check: Negative Weights
SELECT log_id, prog_id, weight
FROM progress_log
WHERE weight < 0;

-- Data Quality Check: Invalid Attendance Values
SELECT prog_id, prog_attendance
FROM progress
WHERE prog_attendance NOT IN ('Present', 'Absent', 'Late', 'Excused');

-- Data Quality Check: Duplicate Physical Locations
SELECT loc_campus, loc_building, loc_room, COUNT(*) AS total_rows
FROM location
GROUP BY loc_campus, loc_building, loc_room
HAVING COUNT(*) > 1;

-- Constraint tests
-- Uncomment each block one at a time to verify the expected constraint violation.

-- Constraint Test: Duplicate Student Email
-- Should fail because stu_email is UNIQUE
-- INSERT INTO student (stu_id, stu_last_name, stu_first_name, stu_program, stu_email, stu_phone, stu_dpt, stu_admit_term, stu_set)
-- VALUES ('Z999', 'Test', 'Duplicate', 'CST', 'ava.nguyen@my.bcit.ca', '(999)-999-9999', 'COMP', '202530', 'A');

-- Constraint Test: Invalid Student ID Format
-- Should fail because of stu_id_ck
-- INSERT INTO student (stu_id, stu_last_name, stu_first_name, stu_program, stu_email, stu_phone, stu_dpt, stu_admit_term, stu_set)
-- VALUES ('abc!', 'Broken', 'ID', 'CST', 'broken.id@my.bcit.ca', '(999)-999-9999', 'COMP', '202530', 'A');

-- Constraint Test: Invalid Lab Session Time
-- Should fail because ses_start_time must be before ses_end_time
-- INSERT INTO lab_session (session_id, set_id, section_id, prof_id, loc_code, ses_meet_dates, ses_due_dates, ses_start_time, ses_end_time)
-- VALUES ('BADTIME1', 2, 'L01', 'A20000000', 'BBY-SW01-3460', '2026-03-15', '2026-03-20', '14:00:00', '10:00:00');

-- Constraint Test: Invalid Attendance Value
-- Should fail because prog_attendance is restricted
-- INSERT INTO progress (prog_id, stu_id, session_id, prog_attendance, prog_preparedness, prog_lab_submit, prog_final_submit, prog_self_score, prog_prof_score, prog_notes)
-- VALUES ('BADPROG1', 'A001', 'L01-L01', 'Missing', TRUE, NULL, NULL, 0, 0, 'Invalid attendance test');

-- Constraint Test: Negative Weight
-- Should fail because weight cannot be less than 0
-- INSERT INTO progress_log (log_id, prog_id, crs_code, log_changes, log_timestamp, weight)
-- VALUES ('BADLOG1', 'A001-L01-L01', 'COMP 2714', 'Negative weight test', CURRENT_TIMESTAMP, -5);

-- Constraint Test: Missing Parent Student
-- Should fail because progress.stu_id must reference an existing student
-- INSERT INTO progress (prog_id, stu_id, session_id, prog_attendance, prog_preparedness, prog_lab_submit, prog_final_submit, prog_self_score, prog_prof_score, prog_notes)
-- VALUES ('BADPROG2', 'ZZZZ', 'L01-L01', 'Present', TRUE, NULL, NULL, 5, 5, 'Missing student FK test');

-- Constraint Test: Missing Parent Session
-- Should fail because progress.session_id must reference an existing lab_session
-- INSERT INTO progress (prog_id, stu_id, session_id, prog_attendance, prog_preparedness, prog_lab_submit, prog_final_submit, prog_self_score, prog_prof_score, prog_notes)
-- VALUES ('BADPROG3', 'A001', 'NOSESSION', 'Present', TRUE, NULL, NULL, 5, 5, 'Missing session FK test');

-- Constraint Test: Missing Parent Professor
-- Should fail because lab_session.prof_id must reference an existing professor
-- INSERT INTO lab_session (session_id, set_id, section_id, prof_id, loc_code, ses_meet_dates, ses_due_dates, ses_start_time, ses_end_time)
-- VALUES ('BADPROF1', 2, 'L01', 'A99999999', 'BBY-SW01-3460', '2026-03-18', '2026-03-23', '09:30:00', '11:20:00');

-- Constraint Test: Missing Parent Location for Section
-- Should fail because section.loc_code must reference an existing location
-- INSERT INTO section (section_id, term_code, crs_code, loc_code, sec_type, sec_start_date, sec_end_date, sec_days, sec_cap)
-- VALUES ('BADLOC1', '202530', 'COMP 2714', 'NO-ROOM', 'Lab', '2026-03-01', '2026-03-30', 'Mon', 25);

-- Constraint Test: Missing Parent Location for Session
-- Should fail because lab_session.loc_code must reference an existing location
-- INSERT INTO lab_session (session_id, set_id, section_id, prof_id, loc_code, ses_meet_dates, ses_due_dates, ses_start_time, ses_end_time)
-- VALUES ('BADLOC2', 2, 'L01', 'A20000000', 'NO-ROOM', '2026-03-15', '2026-03-20', '09:30:00', '11:20:00');