SET search_path TO lab5;

/*  
 *  Aika Manalo - Set 2C
 */

-- BASIC SELECT
-- Q1.1 List all students’ first and last names.
SELECT stu_first_name, stu_last_name
FROM student;

-- Q1.2 List all courses (code + title).
SELECT crs_code, crs_title
FROM course;

-- Q1.3 Show all lab offerings for for COMP 2714 in Fall 2025 (days + start time).
SELECT off_days, off_start_time 
FROM course_offering 
WHERE crs_code = 'COMP 2714' AND term_code = '202550' AND off_type = 'Lab';

-- Q1.4 Display all rows from your enrolment table.
SELECT * FROM enrollment;

-- INNER JOIN
-- Q2.1 List all students and the sections they are enrolled in. Include student name, section id, and term.
SELECT s.stu_first_name, s.stu_last_name, o.off_sect, o.term_code
FROM student AS s
JOIN enrollment AS e ON s.stu_id = e.stu_id
JOIN course_offering AS o ON e.off_id = o.off_id;

-- Q2.2 Show all course offerings with their course titles.
SELECT o.off_type, c.crs_code
FROM course_offering AS o
JOIN course AS c ON o.crs_code = c.crs_code;

-- Q2.3 Display enrollments with the course title and the meeting days.
SELECT e.enr_id, o.off_days, c.crs_title
FROM enrollment AS e
JOIN course_offering AS o ON e.off_id = o.off_id
JOIN course AS c ON o.crs_code = c.crs_code;

-- SEARCHING AND FILTERING
-- Q3.1 Students enrolled in Fall 2025 only (term code 202550).
SELECT DISTINCT s.stu_id, s.stu_first_name, s.stu_last_name
FROM student AS s
JOIN enrollment AS e ON s.stu_id = e.stu_id
JOIN course_offering AS o ON e.off_id = o.off_id
WHERE o.term_code = '202550';

-- Q3.2 Courses whose title contains the word Database (case-insensitive).
SELECT * FROM course
WHERE crs_title ILIKE '%Database%';

-- Q3.4 Students whose last name begins with C.
SELECT * FROM student
WHERE stu_last_name LIKE 'C%';

-- OUTER JOIN
-- Q4.1 All students with their enrollment info, including students with no enrollments (use LEFT JOIN).
SELECT s.stu_id, s.stu_last_name, e.enr_status
FROM student AS s
LEFT JOIN enrollment AS e ON s.stu_id = e.stu_id;

-- Q4.2 Courses not offered in the current term.
SELECT c.crs_code, c.crs_title
FROM course AS c
LEFT JOIN course_offering AS o ON c.crs_code = o.crs_code
WHERE o.off_id IS NULL;

--- REFLECTION
/*
 * 1. Row Count & Duplicates:
 * The row counts make sense because JOIN-ing combines rows from different tables based on matching PK/FKs. 
 * Duplicates did appear in some JOIN queries (e.g. Q2.1) since a student can be linked to a number of course offerings
 * depending if it was a Lab or Lecture section. Since they could be enrolled in both, duplicates would occur
 * so it depended on your query.
 *
 * 2. Using DISTINCT:
 * DISTINCT is meaningful in Q3.1 because it ensures a student is listed only once for the term, regardless of how many 
 * different offerings they were enrolled in. Without it, the count would reflect enrollment seats rather than unique people.
 * 
 * 3. Minimal Columns:
 * Yes, I am selecting only the columns requested by the prompt (e.g., Q1.1 only selects names) to ensure 
 * query efficiency and avoid retrieving unnecessary data.
 */