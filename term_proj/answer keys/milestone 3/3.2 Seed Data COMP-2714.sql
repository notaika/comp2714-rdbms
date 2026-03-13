-- =========================================================
-- LabTracker - Reference seed_data.sql
-- Mapped from the provided milestone CSV files
-- to the Winter 2026 logical schema.
-- =========================================================

-- Assumes schema.sql has already run and search_path is set.

TRUNCATE TABLE progress_log, progress, lab_session, enrollment, section, student, term, course RESTART IDENTITY CASCADE;

-- TERM
INSERT INTO term (term_code, term_title, term_start_date, term_end_date)
VALUES
    ('202510', 'Winter 2025', '2025-01-06', '2025-04-11'),
    ('202520', 'Spring/Summer 2025', '2025-04-28', '2025-08-08'),
    ('202530', 'Fall 2025', '2025-09-02', '2025-12-12');

-- COURSE
INSERT INTO course (crs_code, crs_title, crs_credits, crs_description)
VALUES
    ('COMP2714', 'Relational Database Systems', 3, 'Reference seed row from courses.csv');

-- STUDENT
INSERT INTO student (stu_id, stu_fname, stu_lname, stu_email)
VALUES
    ('A001', 'Ava', 'Nguyen', 'ava.nguyen@my.bcit.ca'),
    ('A002', 'Noah', 'Kim', 'noah.kim@my.bcit.ca'),
    ('A003', 'Oliver', 'Singh', 'oliver.singh@my.bcit.ca'),
    ('B001', 'Maya', 'Fischer', 'maya.fischer@my.bcit.ca'),
    ('B002', 'Leo', 'Park', 'leo.park@my.bcit.ca'),
    ('B003', 'Zoé', 'Martin', 'zoe.martin@my.bcit.ca'),
    ('C001', 'Sofia', 'Chen', 'sofia.chen@my.bcit.ca'),
    ('C002', 'Arjun', 'Patel', 'arjun.patel@my.bcit.ca'),
    ('C003', 'Liam', 'O’Reilly', 'liam.oreilly@my.bcit.ca'),
    ('D001', 'Layla', 'Haddad', 'layla.haddad@my.bcit.ca'),
    ('D002', 'Ethan', 'Wong', 'ethan.wong@my.bcit.ca'),
    ('D003', 'Nora', 'Iverson', 'nora.iverson@my.bcit.ca'),
    ('E001', 'Diego', 'Alvarez', 'diego.alvarez@my.bcit.ca'),
    ('E002', 'Hana', 'Yamamoto', 'hana.yamamoto@my.bcit.ca'),
    ('E003', 'Farah', 'Rahimi', 'farah.rahimi@my.bcit.ca'),
    ('F001', 'Marco', 'Russo', 'marco.russo@my.bcit.ca'),
    ('F002', 'Amir', 'Kazemi', 'amir.kazemi@my.bcit.ca'),
    ('F003', 'Chloe', 'Dubois', 'chloe.dubois@my.bcit.ca');

-- SECTION
INSERT INTO section (sec_crn, sec_type, sec_set, sec_day, sec_start_time, sec_end_time, crs_code, term_code)
VALUES
    ('L01', 'LAB', 'A', 'Mon', '09:30', '11:20', 'COMP2714', '202530'),
    ('L02', 'LAB', 'B', 'Mon', '13:30', '15:20', 'COMP2714', '202530'),
    ('L03', 'LAB', 'C', 'Tue', '18:30', '20:20', 'COMP2714', '202530'),
    ('L04', 'LAB', 'D', 'Wed', '09:30', '11:20', 'COMP2714', '202530'),
    ('L05', 'LAB', 'E', 'Wed', '13:30', '15:20', 'COMP2714', '202530'),
    ('L06', 'LAB', 'F', 'Thu', '18:30', '20:20', 'COMP2714', '202530');

-- ENROLLMENT
INSERT INTO enrollment (sec_crn, stu_id, enr_enrolled_at, enr_withdrawn_at, enr_status)
VALUES
    ('L01', 'A001', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L01', 'A002', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L01', 'A003', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L02', 'B001', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L02', 'B002', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L02', 'B003', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L03', 'C001', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L03', 'C002', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L03', 'C003', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L04', 'D001', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L04', 'D002', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L04', 'D003', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L05', 'E001', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L05', 'E002', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L05', 'E003', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L06', 'F001', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L06', 'F002', '2025-09-02 08:00:00', NULL, 'enrolled'),
    ('L06', 'F003', '2025-09-02 08:00:00', NULL, 'enrolled');

-- LAB_SESSION
INSERT INTO lab_session (lab_id, sec_crn, sec_type, lab_num, meeting_date, due_at)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 'L01', 'LAB', 1, '2025-09-08', '2025-09-14 23:59'),
    (2, 'L01', 'LAB', 2, '2025-09-15', '2025-09-21 23:59'),
    (3, 'L01', 'LAB', 3, '2025-09-22', '2025-09-28 23:59'),
    (4, 'L02', 'LAB', 1, '2025-09-08', '2025-09-14 23:59'),
    (5, 'L02', 'LAB', 2, '2025-09-15', '2025-09-21 23:59'),
    (6, 'L02', 'LAB', 3, '2025-09-22', '2025-09-28 23:59'),
    (7, 'L03', 'LAB', 1, '2025-09-09', '2025-09-14 23:59'),
    (8, 'L03', 'LAB', 2, '2025-09-16', '2025-09-21 23:59'),
    (9, 'L03', 'LAB', 3, '2025-09-23', '2025-09-28 23:59'),
    (10, 'L04', 'LAB', 1, '2025-09-10', '2025-09-14 23:59'),
    (11, 'L04', 'LAB', 2, '2025-09-17', '2025-09-21 23:59'),
    (12, 'L04', 'LAB', 3, '2025-09-24', '2025-09-28 23:59'),
    (13, 'L05', 'LAB', 1, '2025-09-10', '2025-09-15 09:00'),
    (14, 'L05', 'LAB', 2, '2025-09-17', '2025-09-22 09:00'),
    (15, 'L05', 'LAB', 3, '2025-09-24', '2025-09-29 09:00'),
    (16, 'L06', 'LAB', 1, '2025-09-11', '2025-09-15 09:00'),
    (17, 'L06', 'LAB', 2, '2025-09-18', '2025-09-22 09:00'),
    (18, 'L06', 'LAB', 3, '2025-09-25', '2025-09-29 09:00');

SELECT setval(pg_get_serial_sequence('lab_session', 'lab_id'), (SELECT MAX(lab_id) FROM lab_session));

-- PROGRESS
INSERT INTO progress (lab_id, stu_id, sec_crn, attendance, preparedness, in_lab_submission, polished_resubmission, self_assessment, instructor_assessment)
VALUES
    (1, 'A001', 'L01', 'present', TRUE, 'submitted_at=2025-09-08 10:45; link=https://submit.bcit.ca/comp2714/inlab/A001-L01-L01.pdf', 'submitted_at=2025-09-09 12:45; link=https://submit.bcit.ca/comp2714/polished/A001-L01-L01.pdf', 82, 85),
    (2, 'A001', 'L01', 'present', TRUE, 'submitted_at=2025-09-15 10:35; link=https://submit.bcit.ca/comp2714/inlab/A001-L01-L02.pdf', 'submitted_at=2025-09-17 11:35; link=https://submit.bcit.ca/comp2714/polished/A001-L01-L02.pdf', 67, 70),
    (1, 'A002', 'L01', 'present', TRUE, 'submitted_at=2025-09-08 10:45; link=https://submit.bcit.ca/comp2714/inlab/A002-L01-L01.pdf', 'submitted_at=2025-09-09 12:45; link=https://submit.bcit.ca/comp2714/polished/A002-L01-L01.pdf', 82, 85),
    (2, 'A002', 'L01', 'present', TRUE, 'submitted_at=2025-09-15 10:40; link=https://submit.bcit.ca/comp2714/inlab/A002-L01-L02.pdf', NULL, NULL, NULL),
    (1, 'A003', 'L01', 'present', TRUE, 'submitted_at=2025-09-08 10:45; link=https://submit.bcit.ca/comp2714/inlab/A003-L01-L01.pdf', 'submitted_at=2025-09-09 12:45; link=https://submit.bcit.ca/comp2714/polished/A003-L01-L01.pdf', 82, 85),
    (2, 'A003', 'L01', 'present', FALSE, 'submitted_at=2025-09-15 10:35; link=https://submit.bcit.ca/comp2714/inlab/A003-L01-L02.pdf', 'submitted_at=2025-09-17 11:35; link=https://submit.bcit.ca/comp2714/polished/A003-L01-L02.pdf', 67, 70),
    (4, 'B001', 'L02', 'present', TRUE, 'submitted_at=2025-09-08 14:45; link=https://submit.bcit.ca/comp2714/inlab/B001-L02-L01.pdf', 'submitted_at=2025-09-09 16:45; link=https://submit.bcit.ca/comp2714/polished/B001-L02-L01.pdf', 82, 85),
    (5, 'B001', 'L02', 'present', TRUE, 'submitted_at=2025-09-15 14:35; link=https://submit.bcit.ca/comp2714/inlab/B001-L02-L02.pdf', 'submitted_at=2025-09-17 15:35; link=https://submit.bcit.ca/comp2714/polished/B001-L02-L02.pdf', 67, 70),
    (4, 'B002', 'L02', 'present', TRUE, 'submitted_at=2025-09-08 14:45; link=https://submit.bcit.ca/comp2714/inlab/B002-L02-L01.pdf', 'submitted_at=2025-09-09 16:45; link=https://submit.bcit.ca/comp2714/polished/B002-L02-L01.pdf', 82, 85),
    (5, 'B002', 'L02', 'present', TRUE, 'submitted_at=2025-09-15 14:40; link=https://submit.bcit.ca/comp2714/inlab/B002-L02-L02.pdf', NULL, NULL, NULL),
    (4, 'B003', 'L02', 'present', TRUE, 'submitted_at=2025-09-08 14:45; link=https://submit.bcit.ca/comp2714/inlab/B003-L02-L01.pdf', 'submitted_at=2025-09-09 16:45; link=https://submit.bcit.ca/comp2714/polished/B003-L02-L01.pdf', 82, 85),
    (5, 'B003', 'L02', 'present', FALSE, 'submitted_at=2025-09-15 14:35; link=https://submit.bcit.ca/comp2714/inlab/B003-L02-L02.pdf', 'submitted_at=2025-09-17 15:35; link=https://submit.bcit.ca/comp2714/polished/B003-L02-L02.pdf', 67, 70),
    (7, 'C001', 'L03', 'present', TRUE, 'submitted_at=2025-09-09 19:45; link=https://submit.bcit.ca/comp2714/inlab/C001-L03-L01.pdf', 'submitted_at=2025-09-10 21:45; link=https://submit.bcit.ca/comp2714/polished/C001-L03-L01.pdf', 82, 85),
    (8, 'C001', 'L03', 'present', TRUE, 'submitted_at=2025-09-16 19:35; link=https://submit.bcit.ca/comp2714/inlab/C001-L03-L02.pdf', 'submitted_at=2025-09-18 20:35; link=https://submit.bcit.ca/comp2714/polished/C001-L03-L02.pdf', 67, 70),
    (7, 'C002', 'L03', 'present', TRUE, 'submitted_at=2025-09-09 19:45; link=https://submit.bcit.ca/comp2714/inlab/C002-L03-L01.pdf', 'submitted_at=2025-09-10 21:45; link=https://submit.bcit.ca/comp2714/polished/C002-L03-L01.pdf', 82, 85),
    (8, 'C002', 'L03', 'present', TRUE, 'submitted_at=2025-09-16 19:40; link=https://submit.bcit.ca/comp2714/inlab/C002-L03-L02.pdf', NULL, NULL, NULL),
    (7, 'C003', 'L03', 'present', TRUE, 'submitted_at=2025-09-09 19:45; link=https://submit.bcit.ca/comp2714/inlab/C003-L03-L01.pdf', 'submitted_at=2025-09-10 21:45; link=https://submit.bcit.ca/comp2714/polished/C003-L03-L01.pdf', 82, 85),
    (8, 'C003', 'L03', 'present', FALSE, 'submitted_at=2025-09-16 19:35; link=https://submit.bcit.ca/comp2714/inlab/C003-L03-L02.pdf', 'submitted_at=2025-09-18 20:35; link=https://submit.bcit.ca/comp2714/polished/C003-L03-L02.pdf', 67, 70),
    (10, 'D001', 'L04', 'present', TRUE, 'submitted_at=2025-09-10 10:45; link=https://submit.bcit.ca/comp2714/inlab/D001-L04-L01.pdf', 'submitted_at=2025-09-11 12:45; link=https://submit.bcit.ca/comp2714/polished/D001-L04-L01.pdf', 82, 85),
    (11, 'D001', 'L04', 'present', TRUE, 'submitted_at=2025-09-17 10:35; link=https://submit.bcit.ca/comp2714/inlab/D001-L04-L02.pdf', 'submitted_at=2025-09-19 11:35; link=https://submit.bcit.ca/comp2714/polished/D001-L04-L02.pdf', 67, 70),
    (10, 'D002', 'L04', 'present', TRUE, 'submitted_at=2025-09-10 10:45; link=https://submit.bcit.ca/comp2714/inlab/D002-L04-L01.pdf', 'submitted_at=2025-09-11 12:45; link=https://submit.bcit.ca/comp2714/polished/D002-L04-L01.pdf', 82, 85),
    (11, 'D002', 'L04', 'present', TRUE, 'submitted_at=2025-09-17 10:40; link=https://submit.bcit.ca/comp2714/inlab/D002-L04-L02.pdf', NULL, NULL, NULL),
    (10, 'D003', 'L04', 'present', TRUE, 'submitted_at=2025-09-10 10:45; link=https://submit.bcit.ca/comp2714/inlab/D003-L04-L01.pdf', 'submitted_at=2025-09-11 12:45; link=https://submit.bcit.ca/comp2714/polished/D003-L04-L01.pdf', 82, 85),
    (11, 'D003', 'L04', 'present', FALSE, 'submitted_at=2025-09-17 10:35; link=https://submit.bcit.ca/comp2714/inlab/D003-L04-L02.pdf', 'submitted_at=2025-09-19 11:35; link=https://submit.bcit.ca/comp2714/polished/D003-L04-L02.pdf', 67, 70),
    (13, 'E001', 'L05', 'present', TRUE, 'submitted_at=2025-09-10 14:45; link=https://submit.bcit.ca/comp2714/inlab/E001-L05-L01.pdf', 'submitted_at=2025-09-11 16:45; link=https://submit.bcit.ca/comp2714/polished/E001-L05-L01.pdf', 82, 85),
    (14, 'E001', 'L05', 'present', TRUE, 'submitted_at=2025-09-17 14:35; link=https://submit.bcit.ca/comp2714/inlab/E001-L05-L02.pdf', 'submitted_at=2025-09-19 15:35; link=https://submit.bcit.ca/comp2714/polished/E001-L05-L02.pdf', 67, 70),
    (13, 'E002', 'L05', 'present', TRUE, 'submitted_at=2025-09-10 14:45; link=https://submit.bcit.ca/comp2714/inlab/E002-L05-L01.pdf', 'submitted_at=2025-09-11 16:45; link=https://submit.bcit.ca/comp2714/polished/E002-L05-L01.pdf', 82, 85),
    (14, 'E002', 'L05', 'present', TRUE, 'submitted_at=2025-09-17 14:40; link=https://submit.bcit.ca/comp2714/inlab/E002-L05-L02.pdf', NULL, NULL, NULL),
    (13, 'E003', 'L05', 'present', TRUE, 'submitted_at=2025-09-10 14:45; link=https://submit.bcit.ca/comp2714/inlab/E003-L05-L01.pdf', 'submitted_at=2025-09-11 16:45; link=https://submit.bcit.ca/comp2714/polished/E003-L05-L01.pdf', 82, 85),
    (14, 'E003', 'L05', 'present', FALSE, 'submitted_at=2025-09-17 14:35; link=https://submit.bcit.ca/comp2714/inlab/E003-L05-L02.pdf', 'submitted_at=2025-09-19 15:35; link=https://submit.bcit.ca/comp2714/polished/E003-L05-L02.pdf', 67, 70),
    (16, 'F001', 'L06', 'present', TRUE, 'submitted_at=2025-09-11 19:45; link=https://submit.bcit.ca/comp2714/inlab/F001-L06-L01.pdf', 'submitted_at=2025-09-12 21:45; link=https://submit.bcit.ca/comp2714/polished/F001-L06-L01.pdf', 82, 85),
    (17, 'F001', 'L06', 'present', TRUE, 'submitted_at=2025-09-18 19:35; link=https://submit.bcit.ca/comp2714/inlab/F001-L06-L02.pdf', 'submitted_at=2025-09-20 20:35; link=https://submit.bcit.ca/comp2714/polished/F001-L06-L02.pdf', 67, 70),
    (16, 'F002', 'L06', 'present', TRUE, 'submitted_at=2025-09-11 19:45; link=https://submit.bcit.ca/comp2714/inlab/F002-L06-L01.pdf', 'submitted_at=2025-09-12 21:45; link=https://submit.bcit.ca/comp2714/polished/F002-L06-L01.pdf', 82, 85),
    (17, 'F002', 'L06', 'present', TRUE, 'submitted_at=2025-09-18 19:40; link=https://submit.bcit.ca/comp2714/inlab/F002-L06-L02.pdf', NULL, NULL, NULL),
    (16, 'F003', 'L06', 'present', TRUE, 'submitted_at=2025-09-11 19:45; link=https://submit.bcit.ca/comp2714/inlab/F003-L06-L01.pdf', 'submitted_at=2025-09-12 21:45; link=https://submit.bcit.ca/comp2714/polished/F003-L06-L01.pdf', 82, 85),
    (17, 'F003', 'L06', 'present', FALSE, 'submitted_at=2025-09-18 19:35; link=https://submit.bcit.ca/comp2714/inlab/F003-L06-L02.pdf', 'submitted_at=2025-09-20 20:35; link=https://submit.bcit.ca/comp2714/polished/F003-L06-L02.pdf', 67, 70);

-- PROGRESS_LOG
INSERT INTO progress_log (log_id, changed_by, changed_at, what_changed, lab_id, stu_id)
OVERRIDING SYSTEM VALUE
VALUES
    (1, 'u_instructor', '2025-09-09 12:10', 'field=instructor_assessment; old_value=8.0; new_value=8.5; reason=Regraded after resubmission', 1, 'A001'),
    (2, 'u_ta1', '2025-09-16 20:45', 'field=status; old_value=In Progress; new_value=Submitted; reason=Student submitted during lab; TA marked as submitted', 2, 'A003'),
    (3, 'u_system', '2025-09-23 23:59', 'field=late; old_value=False; new_value=True; reason=Auto-flagged after set-specific due time', 4, 'B003');

SELECT setval(pg_get_serial_sequence('progress_log', 'log_id'), (SELECT MAX(log_id) FROM progress_log));
