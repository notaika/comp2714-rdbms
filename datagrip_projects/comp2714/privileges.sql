-- 1. Create roles
CREATE ROLE admin_role;
CREATE ROLE instructor_role;
CREATE ROLE student_role;

-- 2. Grant the roles access to the schema
GRANT USAGE ON SCHEMA "2714lab" TO admin_role, instructor_role, student_role;

-- 3. Grant each role certain privileges.
-- Admin: Full control on all tables and sequences
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA "2714lab" TO admin_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA "2714lab" TO admin_role;

-- Instructor: Read key tables + update limited enrollment columns
GRANT SELECT ON location, department, professor, term, course, course_offering, student, enrollment TO instructor_role;
GRANT UPDATE (enr_status, enr_grade, enr_notes) ON enrollment TO instructor_role;

-- Student: Read offerings; personal rows via view
GRANT SELECT ON course_offering TO student_role;

-- 4. Create Users and assign roles
CREATE USER admin_user_test PASSWORD 'admin123';
CREATE USER instructor_user_test PASSWORD 'instructor123';
CREATE USER student_user_test PASSWORD 'student123';

GRANT admin_role TO admin_user_test;
GRANT instructor_role TO instructor_user_test;
GRANT student_role TO student_user_test;
