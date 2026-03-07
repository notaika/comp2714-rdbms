SET search_path TO lab5;
-- INSERTS

-- truncation of tables should be in dependency order
-- Children/Weak entities -> Parents
TRUNCATE TABLE enrollment RESTART IDENTITY CASCADE;
TRUNCATE TABLE course_offering RESTART IDENTITY CASCADE;
TRUNCATE TABLE student CASCADE;
TRUNCATE TABLE professor CASCADE;
TRUNCATE TABLE course CASCADE;
TRUNCATE TABLE term CASCADE;
TRUNCATE TABLE department CASCADE;
TRUNCATE TABLE location CASCADE;

-- INSERT SCENARIOS
INSERT INTO location (loc_building, loc_room) VALUES 
('SE12', '240'),
('SE12', '260'),
('SW01', '1015');

INSERT INTO term (term_year, term_sem, term_name) VALUES 
(2025, 'Fall', 'Fall 2025'),
(2026, 'Winter', 'Winter 2026'),
(2026, 'Fall', 'Fall 2026'); 

INSERT INTO department (dept_code, dept_name, dept_school, dept_phone, dept_email, dept_website, dept_location) VALUES 
('COMP', 'Computing', 'Business & Media', '604-111-1111', 'comp@bcit.ca', 'https://bcit.ca/comp', 'SE12 240'),
('MATH', 'Mathematics', 'Applied Sciences', '604-222-2222', 'math@bcit.ca', 'https://bcit.ca/math', 'SE12 260');

INSERT INTO professor (prof_id, prof_last_name, prof_first_name, prof_email, prof_phone, prof_hire_date, prof_office_loc, dept_code) VALUES 
('A00123456', 'Nguyen', 'Ada', 'ada.nguyen@bcit.ca', '604-300-1111', '2019-08-15', 'SE12 240', 'COMP'),
('A00987654', 'Singh', 'Raj', 'raj.singh@bcit.ca', '604-300-2222', '2015-09-01', 'SE12 260', 'COMP'),
('A00777777', 'Lopez', 'Maria', 'maria.lopez@bcit.ca', '604-300-3333', '2012-01-10', 'SW01 1015', 'MATH');

INSERT INTO student (stu_id, stu_last_name, stu_first_name, stu_email, stu_phone, stu_program, stu_admit_term, stu_dept) VALUES 
('A10000001', 'Anderson', 'Tom', 'tom.anderson@my.bcit.ca', '604-777-1111', 'CST', '202550', 'COMP'),
('A10000002', 'Young', 'Sara', 'sara.young@my.bcit.ca', '604-777-2222', 'CST', '202550', 'COMP'),
('A10000003', 'Patel', 'Reena', 'reena.patel@my.bcit.ca', '604-777-3333', 'ACIT', '202550', 'COMP'),
('A10000004', 'Chen', 'Min', 'min.chen@my.bcit.ca', '604-777-4444', 'MATH', '202650', 'MATH');

INSERT INTO course (crs_subject, crs_num, crs_title, crs_credits, crs_dept, crs_desc) VALUES 
('COMP', 2714, 'Relational Database Systems', 4.0, 'COMP', 'Core RDBMS course'),
('COMP', 1537, 'Web Development 1', 3.0, 'COMP', 'Intro to web dev'),
('MATH', 3042, 'Discrete Mathematics', 4.0, 'MATH', 'Proofs & structures');

INSERT INTO course_offering (crs_code, term_code, off_sect, off_type, off_prof, off_days, off_start_time, off_end_time, off_loc_code, off_cap) VALUES 
('COMP 2714', '202550', 'LEC', 'Lecture', 'A00123456', '{"Mon", "Wed"}', '09:30', '11:20', 'SE12 240', 60),
('COMP 2714', '202550', 'L1', 'Lab', 'A00987654', '{"Fri"}', '12:30', '14:20', 'SE12 260', 24);

INSERT INTO enrollment (stu_id, off_id, enr_status) VALUES 
('A10000001', 1, 'Active'),
('A10000002', 1, 'Active'),
('A10000003', 1, 'Active'),
('A10000001', 2, 'Active'),
('A10000002', 2, 'Active');