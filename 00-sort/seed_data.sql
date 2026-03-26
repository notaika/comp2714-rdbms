SET search_path TO lab_tracker_group_10;

TRUNCATE TABLE progress_log, progress, lab_session, lab, section, location, student, professor, "user", course, set, term, department RESTART IDENTITY CASCADE;

-- Department Inserts
INSERT INTO department (dpt_code, dpt_name, dpt_school, dpt_email, dpt_location, dpt_phone_num, dpt_website)
VALUES ('COMP',
        'Computing',
        'Computing & Information Technology',
        'comp@bcit.ca',
        'BBY-SW05-1850',
        '(111)-222-3333',
        'https://bcit.ca/comp'),

       ('BSYS',
        'Business Information Systems',
        'Business + Media',
        'business@bcit.ca',
        'BBY-SW01-1000',
        '(604)-432-8234',
        'https://bcit.ca/business'),

       ('ELEX',
        'Electrical and Electronics',
        'Engineering',
        'energy@bcit.ca',
        'BBY-SW03-2000',
        '(604)-432-8456',
        'https://bcit.ca/energy'),

       ('MECH',
        'Mechanical Engineering',
        'Engineering',
        'mechanical@bcit.ca',
        'BBY-SW09-1500',
        '(604)-434-1234',
        'https://bcit.ca/mechanical'),

       ('NURS',
        'Nursing',
        'Health Sciences',
        'health@bcit.ca',
        'BBY-SW12-1100',
        '(604)-432-8888',
        'https://bcit.ca/health');

-- Term Inserts
INSERT INTO term (term_year, term_sem, term_start_date, term_end_date)
VALUES (2025, 'Winter', '2025-01-06', '2025-04-11'),
       (2025, 'Spring/Summer', '2025-04-28', '2025-08-08'),
       (2025, 'Fall', '2025-09-02', '2025-12-12'),
       (2026, 'Winter', '2026-01-05', '2026-04-10'),
       (2022, 'Spring/Summer', '2022-04-27', '2022-08-07');

-- Set Inserts
INSERT INTO set (set_name, set_program, set_term_year)
VALUES ('C', 'CST', '202220'),
       ('A', 'CST', '202530'),
       ('B', 'CST', '202530'),
       ('C', 'CST', '202530'),
       ('E', 'CST', '202530'),
       ('F', 'CST', '202530');

-- User Inserts
INSERT INTO "user" (user_id, display_name, role, email)
VALUES ('u_instructor', 'Maryam Khezrzadeh', 'instructor', 'mkhezrzadeh@bcit.ca'),
       ('u_ta1', 'Daniel Saavedra', 'ta', 'dsaavedra@bcit.ca'),
       ('u_system', 'Lab Tracker System', 'system', 'noreply@labtracker.local');

-- Professor Inserts
INSERT INTO professor (prof_id, prof_last_name, prof_first_name, prof_email, prof_phone, user_id)
VALUES ('A20000000', 'Khezrzadeh', 'Maryam', 'mkhezrzadeh@bcit.ca', '(666)-666-6666', 'u_instructor'),
       ('A20000001', 'Saavedra', 'Daniel', 'dsaavedra@bcit.ca', '(777)-777-7777', 'u_ta1'),
       ('A20000002', 'Brown', 'Ella', 'ella.brown@bcit.ca', '(888)-888-8888', NULL),
       ('A20000003', 'Chan', 'Victor', 'victor.chan@bcit.ca', '(999)-999-9999', NULL),
       ('A20000004', 'Singh', 'Priya', 'priya.singh@bcit.ca', '(555)-123-4567', NULL);

-- Student Inserts
INSERT INTO student (stu_id,
                     stu_last_name,
                     stu_first_name,
                     stu_program,
                     stu_email,
                     stu_phone,
                     stu_dpt,
                     stu_admit_term,
                     stu_set,
                     user_id)
VALUES ('A123',
        'Saavedra',
        'Daniel',
        'CST',
        'dsaavedra@bcit.ca',
        '(124)-232-1413',
        'COMP',
        '202530',
        'C',
        'u_ta1');

INSERT INTO student (stu_id,
                     stu_last_name,
                     stu_first_name,
                     stu_program,
                     stu_email,
                     stu_phone,
                     stu_dpt,
                     stu_admit_term,
                     stu_set)
VALUES ('A001', 'Nguyen', 'Ava', 'CST', 'ava.nguyen@my.bcit.ca', '(111)-111-1111', 'COMP', '202530', 'A'),
       ('B002', 'Park', 'Leo', 'CST', 'leo.park@my.bcit.ca', '(222)-222-2222', 'COMP', '202530', 'B'),
       ('C003', 'O''Reilly', 'Liam', 'CST', 'liam.oreilly@my.bcit.ca', '(333)-333-3333', 'COMP', '202530', 'C'),
       ('E001', 'Alvarez', 'Diego', 'CST', 'diego.alvarez@my.bcit.ca', '(444)-444-4444', 'COMP', '202530', 'E'),
       ('F003', 'Dubois', 'Chloe', 'CST', 'chloe.dubois@my.bcit.ca', '(555)-555-5555', 'COMP', '202530', 'F');

-- Course Inserts
INSERT INTO course (crs_num, crs_dpt, crs_title, crs_creds)
VALUES (2714, 'COMP', 'Relational Database Systems', 3),
       (1510, 'COMP', 'Programming Fundamentals', 4),
       (1712, 'COMP', 'Business Analysis & System Design', 3),
       (1113, 'COMP', 'Applied Mathematics', 3),
       (2522, 'COMP', 'Object Oriented Programming I', 3);

-- Location Inserts
INSERT INTO location (loc_code, loc_campus, loc_building, loc_room)
VALUES ('BBY-SW01-3460', 'BBY', 'SW01', '3460'),
       ('BBY-SW01-3465', 'BBY', 'SW01', '3465'),
       ('BBY-SW03-2605', 'BBY', 'SW03', '2605'),
       ('BBY-SE12-101', 'BBY', 'SE12', '101'),
       ('DTC-310', 'DTC', 'DTC', '310'),
       ('DTC-318', 'DTC', 'DTC', '318');

-- Section Inserts
INSERT INTO section (section_id,
                     term_code,
                     crs_code,
                     loc_code,
                     sec_type,
                     sec_start_date,
                     sec_end_date,
                     sec_days,
                     sec_cap)
VALUES ('L01', '202530', 'COMP 2714', 'BBY-SW01-3460', 'Lab', '2025-11-10', '2026-01-18', 'Mon', 25),
       ('L02', '202530', 'COMP 2714', 'BBY-SW01-3465', 'Lab', '2025-11-12', '2026-02-08', 'Wed', 25),
       ('L03', '202530', 'COMP 2714', 'BBY-SW03-2605', 'Lab', '2025-11-18', '2026-02-15', 'Tue', 25),
       ('L04', '202530', 'COMP 2714', 'BBY-SE12-101', 'Lab', '2025-11-19', '2026-02-23', 'Wed', 25),
       ('L05', '202530', 'COMP 2714', 'DTC-310', 'Lab', '2025-11-20', '2026-03-09', 'Thu', 25),
       ('L06', '202530', 'COMP 2714', 'DTC-318', 'Lab', '2025-11-21', '2026-03-11', 'Fri', 25);

-- Lab Inserts
INSERT INTO lab (section_id,
                 sec_type,
                 lab_name,
                 lab_type,
                 deliverable)
VALUES ('L01', 'Lab', 'Lab 01', 'DB', 'Environment Setup & Intro SQL'),
       ('L02', 'Lab', 'Lab 02', 'DB', 'SQL Queries & Validation'),
       ('L03', 'Lab', 'Lab 03', 'DB', 'Constraints & Integrity'),
       ('L04', 'Lab', 'Lab 04', 'DB', 'Normalization Review'),
       ('L05', 'Lab', 'Lab 05', 'DB', 'Joins & Reporting'),
       ('L06', 'Lab', 'Lab 06', 'DB', 'Milestone Integration');

-- Lab Session Inserts
INSERT INTO lab_session (session_id,
                         set_id,
                         section_id,
                         prof_id,
                         loc_code,
                         ses_meet_dates,
                         ses_due_dates,
                         ses_start_time,
                         ses_end_time)
VALUES ('L01-L01', 2, 'L01', 'A20000000', 'BBY-SW01-3460', '2025-11-10', '2025-11-16', '09:30:00', '11:20:00'),
       ('L01-L02', 2, 'L01', 'A20000000', 'BBY-SW01-3460', '2025-12-01', '2025-12-07', '09:30:00', '11:20:00'),
       ('L01-L03', 2, 'L01', 'A20000000', 'BBY-SW01-3460', '2026-01-12', '2026-01-18', '09:30:00', '11:20:00'),

       ('L02-L01', 3, 'L02', 'A20000001', 'BBY-SW01-3465', '2025-11-12', '2025-11-18', '13:30:00', '15:20:00'),
       ('L02-L02', 3, 'L02', 'A20000001', 'BBY-SW01-3465', '2025-12-03', '2025-12-09', '13:30:00', '15:20:00'),
       ('L02-L03', 3, 'L02', 'A20000001', 'BBY-SW01-3465', '2026-02-02', '2026-02-08', '13:30:00', '15:20:00'),

       ('L03-L01', 4, 'L03', 'A20000002', 'BBY-SW03-2605', '2025-11-18', '2025-11-23', '18:30:00', '20:20:00'),
       ('L03-L02', 4, 'L03', 'A20000002', 'BBY-SW03-2605', '2025-12-09', '2025-12-14', '18:30:00', '20:20:00'),
       ('L03-L03', 4, 'L03', 'A20000002', 'BBY-SW03-2605', '2026-02-10', '2026-02-15', '18:30:00', '20:20:00'),

       ('L04-L01', 1, 'L04', 'A20000003', 'BBY-SE12-101', '2025-11-19', '2025-11-24', '09:30:00', '11:20:00'),
       ('L04-L02', 1, 'L04', 'A20000003', 'BBY-SE12-101', '2025-12-10', '2025-12-15', '09:30:00', '11:20:00'),
       ('L04-L03', 1, 'L04', 'A20000003', 'BBY-SE12-101', '2026-02-18', '2026-02-23', '09:30:00', '11:20:00'),

       ('L05-L01', 5, 'L05', 'A20000004', 'DTC-310', '2025-11-20', '2025-11-25', '13:30:00', '15:20:00'),
       ('L05-L02', 5, 'L05', 'A20000004', 'DTC-310', '2026-01-14', '2026-01-19', '13:30:00', '15:20:00'),
       ('L05-L03', 5, 'L05', 'A20000004', 'DTC-310', '2026-03-04', '2026-03-09', '13:30:00', '15:20:00'),

       ('L06-L01', 6, 'L06', 'A20000000', 'DTC-318', '2025-11-21', '2025-11-26', '18:30:00', '20:20:00'),
       ('L06-L02', 6, 'L06', 'A20000000', 'DTC-318', '2026-01-16', '2026-01-21', '18:30:00', '20:20:00'),
       ('L06-L03', 6, 'L06', 'A20000000', 'DTC-318', '2026-03-06', '2026-03-11', '18:30:00', '20:20:00');

-- Progress Inserts
INSERT INTO progress (prog_id,
                      stu_id,
                      session_id,
                      prog_attendance,
                      prog_preparedness,
                      prog_lab_submit,
                      prog_final_submit,
                      prog_self_score,
                      prog_prof_score,
                      prog_notes)
VALUES ('A001-L01-L01',
        'A001',
        'L01-L01',
        'Present',
        TRUE,
        'https://submit.bcit.ca/comp2714/inlab/A001-L01-L01.pdf',
        'https://submit.bcit.ca/comp2714/polished/A001-L01-L01.pdf',
        8.2,
        8.5,
        'Submitted for November session'),

       ('A001-L01-L02',
        'A001',
        'L01-L02',
        'Present',
        TRUE,
        'https://submit.bcit.ca/comp2714/inlab/A001-L01-L02.pdf',
        'https://submit.bcit.ca/comp2714/polished/A001-L01-L02.pdf',
        6.7,
        7.0,
        'Submitted for December session'),

       ('B002-L02-L01',
        'B002',
        'L02-L01',
        'Present',
        TRUE,
        'https://submit.bcit.ca/comp2714/inlab/B002-L02-L01.pdf',
        'https://submit.bcit.ca/comp2714/polished/B002-L02-L01.pdf',
        8.2,
        8.5,
        'November lab session'),

       ('C003-L03-L02',
        'C003',
        'L03-L02',
        'Present',
        FALSE,
        'https://submit.bcit.ca/comp2714/inlab/C003-L03-L02.pdf',
        'https://submit.bcit.ca/comp2714/polished/C003-L03-L02.pdf',
        6.7,
        7.0,
        'Late winter session'),

       ('E001-L05-L03',
        'E001',
        'L05-L03',
        'Present',
        TRUE,
        'https://submit.bcit.ca/comp2714/inlab/E001-L05-L03.pdf',
        'https://submit.bcit.ca/comp2714/polished/E001-L05-L03.pdf',
        8.2,
        8.5,
        'March downtown lab');

-- Progress Log Inserts
INSERT INTO progress_log (log_id,
                          prog_id,
                          crs_code,
                          log_changes,
                          log_timestamp,
                          weight)
VALUES ('chg1',
        'A001-L01-L01',
        'COMP 2714',
        'Instructor score adjusted after rubric review',
        '2025-11-17 12:10:00',
        10),

       ('chg2',
        'C003-L03-L02',
        'COMP 2714',
        'Submission status updated after review session',
        '2025-12-16 20:45:00',
        10),

       ('chg3',
        'E001-L05-L03',
        'COMP 2714',
        'Final polished submission recorded',
        '2026-03-10 14:20:00',
        10);