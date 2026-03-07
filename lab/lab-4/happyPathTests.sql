
SET search_path TO lab5;

-- Clean up data from previous runs so we don't get "Duplicate Key" errors
DELETE FROM ENROLLMENT;
DELETE FROM COURSE_OFFERING;
DELETE FROM COURSE;
DELETE FROM PROFESSOR;
DELETE FROM DEPARTMENT;
DELETE FROM STUDENT;
DELETE FROM TERM;
DELETE FROM BUILDING;

-- 1. Create Parents

INSERT INTO BUILDING (build_code, build_name, build_room) 
VALUES ('SW1-1020', 'Software Building', '1020');

INSERT INTO TERM (term_code, term_semester, term_years) 
VALUES ('202610', 'W', 2026);

INSERT INTO STUDENT (stu_num, stu_fname, stu_lname) 
VALUES ('A01234567', 'Lano', 'Doggo');

-- 2. Create Level 1 Dependents
INSERT INTO DEPARTMENT (dep_code, dep_name, build_code) 
VALUES ('COMP', 'Computer Systems Tech', 'SW1-1020');

-- 3. Create Level 2 Dependents (Depends on Dept)
INSERT INTO PROFESSOR (prof_num, prof_fname, prof_lname, dep_code) 
VALUES (999888777, 'Severus', 'Snape', 'COMP');

INSERT INTO COURSE (crs_code, crs_title, crs_credits, dep_code) 
VALUES ('2714', 'Relational Databases', 4, 'COMP');

INSERT INTO COURSE (crs_code, crs_title, crs_credits, dep_code) 
VALUES ('2522', 'Object Oriented Prog', 4, 'COMP');

-- 4. Create Level 3 Dependents (Offering)
INSERT INTO COURSE_OFFERING (off_id, crs_code, term_code, off_section, off_capacity, off_start_time, off_end_time, off_notes, build_code, prof_num)
VALUES ('10001', '2714', '202610', 'A', 30, '08:30:00', '10:30:00', 'Lab A', 'SW1-1020', 999888777);

-- 5. Create Level 4 Dependents (Enrollment)
INSERT INTO ENROLLMENT (stu_num, off_id, enr_status, enr_final_grade)
VALUES ('A01234567', '10001', 'Active', NULL);

SELECT * FROM ENROLLMENT;

SELECT * FROM COURSE_OFFERING;