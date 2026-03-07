TRUNCATE TABLE
    enrollment,
    course_offering,
    course,
    student,
    professor,
    department,
    term,
    location
    RESTART IDENTITY CASCADE;


/* =========================
   Task 1 — Load Seed Data
   (Write plain INSERTs)
   ========================= */

-- LOCATION
INSERT INTO location (loc_building_code, loc_room_code)
VALUES ('SE12', '240'),
       ('SE12', '260'),
       ('SW01', '1015');

-- DEPARTMENT
INSERT INTO department (dept_code, dept_name, dept_school, dept_phone, dept_email, dept_website, dept_location)
VALUES ('COMP', 'Computing', 'Business & Media', '604-111-1111', 'comp@bcit.ca', 'https://bcit.ca/comp', 'SE12 240'),
       ('MATH', 'Mathematics', 'Applied Sciences', '604-222-2222', 'math@bcit.ca', 'https://bcit.ca/math', 'SE12 260');

-- TERM
-- If your schema auto-generates term_code (e.g., 202550 for Fall 2025),
-- be sure the mapping matches these values.
INSERT INTO term (term_year, term_semester, term_name)
VALUES (2025, 'Fall', 'Fall 2025'),
       (2026, 'Winter', 'Winter 2026'),
       (2026, 'Fall', 'Fall 2026');

-- PROFESSOR
INSERT INTO professor (prof_bcit_id, prof_last_name, prof_first_name, prof_email, prof_phone, prof_hire_date,
                       prof_office_loc, dept_code)
VALUES ('A00123456', 'Nguyen', 'Ada', 'ada.nguyen@bcit.ca', '604-300-1111', '2019-08-15', 'SE12 240', 'COMP'),
       ('A00987654', 'Singh', 'Raj', 'raj.singh@bcit.ca', '604-300-2222', '2015-09-01', 'SE12 260', 'COMP'),
       ('A00777777', 'Lopez', 'Maria', 'maria.lopez@bcit.ca', '604-300-3333', '2012-01-10', 'SW01 1015', 'MATH');

-- STUDENT
-- If your admit term must equal your generated term_code, adjust 202550/202650 accordingly.
INSERT INTO student (stu_bcit_id, stu_last_name, stu_first_name, stu_email, stu_phone, stu_program, stu_admit_term,
                     stu_department)
VALUES ('A10000001', 'Anderson', 'Tom', 'tom.anderson@my.bcit.ca', '604-777-1111', 'CST', 202550, 'COMP'),
       ('A10000002', 'Young', 'Sara', 'sara.young@my.bcit.ca', '604-777-2222', 'CST', 202550, 'COMP'),
       ('A10000003', 'Patel', 'Reena', 'reena.patel@my.bcit.ca', '604-777-3333', 'ACIT', 202550, 'COMP'),
       ('A10000004', 'Chen', 'Min', 'min.chen@my.bcit.ca', '604-777-4444', 'MATH', 202650, 'MATH');

-- COURSE
INSERT INTO course (course_subject, course_number, course_title, course_credits, course_dept, course_desc)
VALUES ('COMP', 2714, 'Relational Database Systems', 4.0, 'COMP', 'Core RDBMS course'),
       ('COMP', 1537, 'Web Development 1', 3.0, 'COMP', 'Intro to web dev'),
       ('MATH', 3042, 'Discrete Mathematics', 4.0, 'MATH', 'Proofs & structures');

-- COURSE_OFFERING
-- This solution assumes course_code is stored as 'COMP 2714' and term_code as 202550.
-- If your schema uses numeric identities instead, use the correct literal values for your rows.
INSERT INTO course_offering
(course_code, term_code, offer_section, offer_type, offer_prof_id, offer_days, offer_start_time, offer_end_time,
 offer_loc_code, offer_cap)
VALUES ('COMP 2714', 202550, 'LEC', 'Lecture', 'A00123456', 'Mon,Wed', '09:30', '11:20', 'SE12 240', 60),
       ('COMP 2714', 202550, 'L1', 'Lab', 'A00987654', 'Fri', '12:30', '14:20', 'SE12 260', 24);

-- ENROLLMENT
-- The following assumes that after the two inserts above, offer_id values are 1 (LEC) and 2 (L1).
-- If not, replace 1/2 below with the correct offer_id values as shown in your client UI.
INSERT INTO enrollment (stu_bcit_id, offer_id, enr_status, enr_grade)
VALUES ('A10000001', 1, 'Active', NULL),
       ('A10000002', 1, 'Active', NULL),
       ('A10000003', 1, 'Active', NULL),
       ('A10000001', 2, 'Active', NULL),
       ('A10000002', 2, 'Active', NULL);

/* =========================
   Task 2 — Additional INSERTs
   ========================= */

-- 2.1 New student (COMP, admitted Fall 2025)
INSERT INTO student (stu_bcit_id, stu_last_name, stu_first_name, stu_email, stu_phone, stu_program, stu_admit_term,
                     stu_department)
VALUES ('A10000006', 'Garcia', 'Luis', 'luis.garcia@my.bcit.ca', '604-777-5555', 'CST', 202550, 'COMP');

-- 2.2 New professor and new lab offering (L2) for COMP 2714 Fall 2025
INSERT INTO professor (prof_bcit_id, prof_last_name, prof_first_name, prof_email, prof_phone, prof_hire_date,
                       prof_office_loc, dept_code)
VALUES ('A00111111', 'Khan', 'Zara', 'zara.khan@bcit.ca', '604-300-4444', '2020-05-01', 'SE12 260', 'COMP');

-- Create L2 (assumes course_code='COMP 2714', term_code=202550)
-- The new row will typically get offer_id=3 if your identity starts at 1 and no gaps exist.
INSERT INTO course_offering
(course_code, term_code, offer_section, offer_type, offer_prof_id, offer_days, offer_start_time, offer_end_time,
 offer_loc_code, offer_cap)
VALUES ('COMP 2714', 202550, 'L2', 'Lab', 'A00111111', 'Fri', '14:30', '16:20', 'SE12 260', 24);

-- 2.3 Enroll two students into L2 (replace 3 with the new L2 offer_id if different)
INSERT INTO enrollment (stu_bcit_id, offer_id, enr_status, enr_grade)
VALUES ('A10000001', 3, 'Active', NULL),
       ('A10000006', 3, 'Active', NULL);
