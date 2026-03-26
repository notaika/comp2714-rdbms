-- =============================================================================
-- COMP 2714 - Lab 8: Data Control Language (DCL) & Security Views
-- Based on Lecture 7: SQL Views and Queries
-- =============================================================================

-- 1. Create roles
-- Roles allow us to manage permissions for groups of users efficiently.
DROP ROLE IF EXISTS admin_role;
DROP ROLE IF EXISTS instructor_role;
DROP ROLE IF EXISTS student_role;
DROP ROLE IF EXISTS ta_role;

CREATE ROLE admin_role;
CREATE ROLE instructor_role;
CREATE ROLE student_role;
CREATE ROLE ta_role;

-- 2. Grant the roles access to the schema
-- USAGE is required to perform any operation in the schema.
GRANT USAGE ON SCHEMA "lab5" TO admin_role, instructor_role, student_role, ta_role;

-- 3. Grant each role certain privileges.

-- Admin: Full control on all tables and sequences
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA "lab5" TO admin_role;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA "lab5" TO admin_role;

-- Instructor: Read key tables + update limited enrollment columns
GRANT SELECT ON location, department, professor, term, course, course_offering, student, enrollment TO instructor_role;
GRANT UPDATE (enr_status, enr_grade, enr_notes) ON enrollment TO instructor_role;

-- Student: Read offerings; personal rows via views
GRANT SELECT ON course_offering, course, term TO student_role;

-- TA Role: Limited grading rights (as per challenge)
GRANT SELECT ON student, course, course_offering, enrollment TO ta_role;
GRANT UPDATE (enr_grade, enr_notes) ON enrollment TO ta_role;


-- 4. Create Users and assign roles
-- Dropping existing test users to ensure a clean slate
DROP USER IF EXISTS admin_user_test;
DROP USER IF EXISTS instructor_user_test;
DROP USER IF EXISTS student_user_test;
DROP USER IF EXISTS ta_user_test;
DROP USER IF EXISTS a00123456, a00987654, a00777777, a00111111;
DROP USER IF EXISTS a10000001, a10000002, a10000003, a10000004, a10000006;

CREATE USER admin_user_test PASSWORD 'admin123';
CREATE USER instructor_user_test PASSWORD 'instructor123';
CREATE USER student_user_test PASSWORD 'student123';
CREATE USER ta_user_test PASSWORD 'teachingassist';

-- Specific Professors
CREATE USER a00123456 PASSWORD 'adanguyeen';
CREATE USER a00987654 PASSWORD 'rajsingh';
CREATE USER a00777777 PASSWORD 'marialopez';
CREATE USER a00111111 PASSWORD 'zarakhan';

-- Specific Students
CREATE USER a10000001 PASSWORD 'tomanderson';
CREATE USER a10000002 PASSWORD 'sarayoung';
CREATE USER a10000003 PASSWORD 'reenapatel';
CREATE USER a10000004 PASSWORD 'minchen';
CREATE USER a10000006 PASSWORD 'luisgarcia';

-- Assign roles
GRANT admin_role TO admin_user_test;
GRANT instructor_role TO instructor_user_test, a00123456, a00987654, a00777777, a00111111;
GRANT student_role TO student_user_test, a10000001, a10000002, a10000003, a10000004, a10000006;
GRANT ta_role TO ta_user_test;


-- 5. Create secure views to limit access and enforce row-level visibility.
-- (Based on Lecture 7: Views for Security and Information Hiding)

-- A. Instructor can only see enrollments for their own courses
-- Use WITH CHECK OPTION to prevent updating rows they can't see.
CREATE OR REPLACE VIEW v_instructor_enrollments AS
SELECT e.*
FROM enrollment e
         JOIN course_offering co ON co.offer_id = e.offer_id
         JOIN professor p ON p.prof_bcit_id = co.offer_prof_id
WHERE lower(current_user) IN (lower(p.prof_bcit_id), 'instructor_user_test')
WITH LOCAL CHECK OPTION;

GRANT SELECT, UPDATE ON v_instructor_enrollments TO instructor_role;

-- B. Students can only see their own enrollments
CREATE OR REPLACE VIEW v_my_enrollments AS
SELECT *
FROM enrollment
WHERE lower(stu_bcit_id) = lower(current_user)
WITH LOCAL CHECK OPTION;

GRANT SELECT ON v_my_enrollments TO student_role;

-- C. Information Hiding: Public Student Directory (masks sensitive info)
-- Only shows name, program, and department. No email or phone.
CREATE OR REPLACE VIEW v_student_directory AS
SELECT stu_first_name, stu_last_name, stu_program, stu_department
FROM student;

GRANT SELECT ON v_student_directory TO instructor_role, student_role;

-- D. Course Catalog View (Joins for simplified reading)
-- Simplifies the complex join between Course and CourseOffering.
CREATE OR REPLACE VIEW v_course_catalog AS
SELECT c.course_code,
       c.course_title,
       co.offer_section,
       co.offer_type,
       co.offer_days,
       co.offer_start_time,
       co.offer_end_time,
       co.offer_loc_code,
       p.prof_last_name AS instructor
FROM course c
JOIN course_offering co ON c.course_code = co.course_code
LEFT JOIN professor p ON co.offer_prof_id = p.prof_bcit_id;

GRANT SELECT ON v_course_catalog TO student_role, instructor_role;


-- 6. Test Access Control: Switch between roles to test behaviour
-- Testing as Generic Instructor
SET ROLE instructor_role;
SELECT * FROM v_instructor_enrollments; -- Should succeed
-- DELETE FROM enrollment; -- Would fail (uncomment to test error)
RESET ROLE;

-- Testing row-level security for a specific professor
SET SESSION AUTHORIZATION a00123456;
SELECT count(*) AS my_student_count FROM v_instructor_enrollments; -- Should only see their students
RESET SESSION AUTHORIZATION;

-- Testing row-level security for a specific student
SET SESSION AUTHORIZATION a10000001;
SELECT * FROM v_my_enrollments; -- Should only see their own rows
-- SELECT * FROM student; -- Should fail (direct access restricted)
SELECT * FROM v_student_directory; -- Should work (information hiding view)
RESET SESSION AUTHORIZATION;


-- 7. Revoke and Re-grant Privileges (Maintenance Testing)
-- Temporarily remove update rights
REVOKE UPDATE ON enrollment FROM instructor_role;

-- Retest (Should fail)
SET ROLE instructor_role;
-- UPDATE enrollment SET enr_notes = 'test' WHERE enr_id = 1; -- Should fail
RESET ROLE;

-- Restore privileges
GRANT UPDATE (enr_status, enr_grade, enr_notes) ON enrollment TO instructor_role;


-- 8. Reflection Questions
-- 1. Why is it good practice to grant privileges to roles instead of users?
/* It ensures scalability and maintainability. Instead of managing thousands of individual
   users, we manage a few roles. When a new person joins (e.g., a new instructor), we
   simply grant them the 'instructor_role' rather than running multiple GRANT statements. */

-- 2. How do views help enforce the principle of least privilege?
/* Views allow us to present only the necessary columns (column-level security) and
   only the necessary rows (row-level security) to a user. For example, v_student_directory
   hides phone numbers, and v_my_enrollments filters by the user's ID. */

-- 3. What happens when you revoke a privilege that was granted WITH GRANT OPTION?
/* If User A granted a privilege to User B 'WITH GRANT OPTION', and User B granted it to
   User C, then when User A revokes from User B, the privilege is also automatically
   revoked from User C (cascading revoke). */

-- 4. How could you extend this design to include a TA role with limited grading rights?
/* As implemented in the 'ta_role' above, we create a role specifically for TAs and
   grant UPDATE only on the 'enr_grade' and 'enr_notes' columns of the enrollment table,
   while restricting access to other sensitive administrative functions. */

-- =============================================================================
-- END OF LAB 8
-- =============================================================================
