SET search_path TO lab5;

-- UPDATE Scenarios
UPDATE course_offering
SET off_start_time = '15:30',
    off_end_time = '17:20',
    off_loc_code = 'SW01 1015'
WHERE off_id = 2;

UPDATE enrollment
SET enr_status = 'Dropped'
WHERE stu_id = 'A10000002';

UPDATE enrollment
SET enr_status = 'Active'
WHERE stu_id = 'A10000002';

UPDATE enrollment
SET enr_grade = 'A'
WHERE off_id = 1 AND stu_id IN ('A10000001', 'A10000003');