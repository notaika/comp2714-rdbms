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

CREATE USER a00123456 PASSWORD 'adanguyeen';
CREATE USER a00987654 PASSWORD 'rajsingh';
CREATE USER a00777777 PASSWORD 'marialopez';
CREATE USER a00111111 PASSWORD 'zarakhan';

CREATE USER a10000001 PASSWORD 'tomanderson';
CREATE USER a10000002 PASSWORD 'sarayoung';
CREATE USER a10000003 PASSWORD 'reenapatel';
CREATE USER a10000004 PASSWORD 'minchen';
CREATE USER a10000006 PASSWORD 'luisgarcia';

GRANT instructor_role TO a00123456;
GRANT instructor_role TO a00987654;
GRANT instructor_role TO a00777777;
GRANT instructor_role TO a00111111;

GRANT student_role TO a10000001;
GRANT student_role TO a10000002;
GRANT student_role TO a10000003;
GRANT student_role TO a10000004;
GRANT student_role TO a10000006;

GRANT admin_role TO admin_user_test;
GRANT instructor_role TO instructor_user_test;
GRANT student_role TO student_user_test;

-- 5. Create secure views to limit access and enforce row-level visibility.
-- Instructor can only see enrollments for their courses
CREATE OR REPLACE VIEW v_instructor_enrollments AS
SELECT e.*
FROM enrollment e
         JOIN course_offering co ON co.offer_id = e.offer_id
         JOIN professor p ON p.prof_bcit_id = co.offer_prof_id
WHERE lower(current_user) IN (lower(p.prof_bcit_id), 'instructor_user_test');

GRANT SELECT ON v_instructor_enrollments TO instructor_role;

-- Students can only see their own enrollments
CREATE OR REPLACE VIEW v_my_enrollments AS
SELECT *
FROM enrollment
WHERE lower(stu_bcit_id) = lower(current_user);

GRANT SELECT ON v_my_enrollments TO student_role;

-- 6. Test Access Control: Switch between roles to test behaviour
SET ROLE instructor_role;
SELECT *
FROM v_instructor_enrollments; -- Should be allowed
DELETE
FROM enrollment; -- Should fail
RESET ROLE;

SET SESSION AUTHORIZATION instructor_user_test;
SELECT count(*) AS rows_visible_to_generic_instructor
FROM v_instructor_enrollments;
RESET SESSION AUTHORIZATION;

SET SESSION AUTHORIZATION a00123456;
SELECT count(*) AS rows_invisible_to_prof_123456
FROM v_instructor_enrollments;
RESET SESSION AUTHORIZATION;

SET SESSION AUTHORIZATION a10000001;
SELECT count(*) AS v_my_enrollments; -- Should be allowed
SELECT *
FROM student; -- Should fail
RESET SESSION AUTHORIZATION;

-- 7. Revoke Privileges
REVOKE UPDATE ON enrollment FROM instructor_role;
REVOKE SELECT ON v_my_enrollments FROM student_role;

-- Testing Revoke Privileges
-- Testing Instructor Revoked Privileges
SET ROLE instructor_role;
SELECT *
FROM enrollment;

UPDATE enrollment
SET enr_notes = 'testing revoke'
WHERE enr_id = 1;

UPDATE enrollment
SET enr_grade = 'A'
WHERE enr_id = '1';
RESET ROLE;

-- Give back privileges and retest again
GRANT UPDATE (enr_status, enr_grade, enr_notes) ON enrollment TO instructor_role;

SET ROLE instructor_role;
UPDATE enrollment
SET enr_notes = 'testing revoke'
WHERE enr_id = 1;

SELECT enr_notes
FROM enrollment
WHERE enr_id = 1;

SELECT *
FROM enrollment;

-- Reset it back to NULL
UPDATE enrollment
SET enr_notes = NULL
WHERE enr_id = 1;
RESET ROLE;

-- Test Student Revoked Privileges
SET ROLE student_role;
SELECT *
FROM v_my_enrollments;
RESET ROLE;

-- Give back privileges and test again
GRANT SELECT ON v_my_enrollments TO student_role;

SET ROLE student_role;
SELECT *
FROM v_my_enrollments;
RESET ROLE;

-- 8. Reflection Questions
-- 1. Why is it good practice to grant privileges to roles instead of users?
/* Biggest reason is for scalability. Assigning individual privileges to users would make maintenance
a nightmare. The queries would have to be repeated, and there's more room for error/mistakes (like missing
a GRANT or REVOKE on a user. By creating a role, you would just have to assign or remove the role to grant
privileges to a user if they fit the category/permissions. */

-- 2. How do views help enforce the principle of least privilege?
/* View are able to restrict data access at both/either column and row levels. Tables usually contain all
   kind of data that could be sensitive. If we declare a view and grant a user access to a specific view
   vs. the base table, we're basically only showing them what we want/intent for them to see. */

-- 3. What happens when you revoke a privilege that was granted WITH GRANT OPTION?
/* The revoke cascades down... meaning if A grants B a privilege using GRANT OPTION and B passes it to
   C. Revoking that privilege form A will automatically strip privileges that were passed down by A to
   B and C as well. This prevents dangling/lingering unauthorized access.*/

-- 4. How could you extend this design to include a TA role with limited grading rights?
/* I would create a TA role and grant it SELECT access to the required base tables which are -> student,
   course and course_offering. I would then give an UPDATE privilege specifically only for the enr_grade
   column of the enrollment table, and maybe enr_notes.*/

-- OPTIONAL CHALLENGE

-- Create TA Role
CREATE ROLE ta_role;

-- Grant permission to access schema
GRANT USAGE ON SCHEMA "2714lab" TO ta_role;

-- Grant privileges
GRANT SELECT ON student, course, course_offering, enrollment TO ta_role;
GRANT UPDATE (enr_grade, enr_notes) ON enrollment TO ta_role;

-- Create User and Test
CREATE USER ta_user_test PASSWORD 'teachingassist';
GRANT ta_role to ta_user_test;

SET ROLE ta_role;
SELECT * FROM student;

UPDATE enrollment -- This should work
SET enr_grade = 'F', enr_notes = 'See me after class.'
WHERE enr_id = 2;

SELECT * FROM enrollment;

UPDATE enrollment -- This should be denied
SET enr_status = 'Dropped'
WHERE enr_id = 3;

-- Reset back...
UPDATE enrollment -- This should work
SET enr_grade = NULL, enr_notes = NULL
WHERE enr_id = 2;
