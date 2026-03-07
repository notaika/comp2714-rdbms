SET search_path TO lab5;

-- update or delete on table "department" violates foreign key constraint "professor_dept_code_fkey" on table "professor"
DELETE FROM department
WHERE dept_code = 'COMP';

DELETE FROM course_offering 
WHERE off_sect = 'L1' AND crs_code = 'COMP 2714';

-- update or delete on table "location" violates foreign key constraint "department_dept_location_fkey" on table "department"
DELETE FROM location
WHERE loc_code = 'SE12 260';