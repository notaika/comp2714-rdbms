SET search_path TO lab_tracker_group_10;

TRUNCATE TABLE student, professor, "user", course, term, set, department RESTART IDENTITY CASCADE;

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
VALUES ('A20000000', 'Khezrzadeh', 'Maryam', 'mkhezrzadeh@bcit.ca', '(666)-666-6666', 'u_instructor');

INSERT INTO professor (prof_id, prof_last_name, prof_first_name, prof_email, prof_phone)
VALUES ('A20000001', 'Link', 'Bruce', 'blink@bcit.ca', '(555)-555-5555'),
       ('A20000002', 'Ram', 'Erika', 'eram@bcit.ca', '(444)-444-4444'),
       ('A20000003', 'Rozman', 'Paul', 'prozman@bcit.ca', '(123)-456-7890'),
       ('A20000004', 'Wilder', 'Jason', 'jwilder@bcit.ca', '(333)-222-1111');

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
VALUES ('A123', 'Saavedra', 'Daniel', 'CST', 'dsaavedra@bcit.ca', '(124)-232-1413', 'COMP', '202530', 'C', 'u_ta1');

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