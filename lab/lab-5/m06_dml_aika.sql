-- UPDATED LAB 5
CREATE SCHEMA IF NOT EXISTS lab5;

SET search_path TO lab5;

DROP TABLE IF EXISTS location CASCADE;
DROP TABLE IF EXISTS department CASCADE;
DROP TABLE IF EXISTS professor CASCADE;
DROP TABLE IF EXISTS student CASCADE;
DROP TABLE IF EXISTS term CASCADE;
DROP TABLE IF EXISTS course CASCADE;
DROP TABLE IF EXISTS course_offering CASCADE;
DROP TABLE IF EXISTS enrollment CASCADE;

-- location table
CREATE TABLE location (
    loc_building   VARCHAR(10)  NOT NULL,
    loc_room       VARCHAR(10)  NOT NULL,
    loc_code       VARCHAR(25)  GENERATED ALWAYS AS (loc_building || ' ' || loc_room) STORED,

    PRIMARY KEY (loc_code)
);

-- department table
CREATE TABLE department (
    dept_code       VARCHAR(8)      PRIMARY KEY,
    dept_name       VARCHAR(120)    NOT NULL    UNIQUE,
    dept_school     VARCHAR(80)     NOT NULL,
    dept_phone      VARCHAR(20),
    dept_email      VARCHAR(120),
    dept_website    VARCHAR(50),
    dept_location   VARCHAR(25),

    FOREIGN KEY (dept_location) REFERENCES location(loc_code) ON UPDATE CASCADE,
    CONSTRAINT dept_code_check CHECK (dept_code ~ '^[A-Z0-9]{3,6}$')
);

-- professor table
CREATE TABLE professor
(
    prof_id         VARCHAR(10)     PRIMARY KEY,
    prof_last_name  VARCHAR(50)     NOT NULL,
    prof_first_name VARCHAR(50)     NOT NULL,
    prof_email      VARCHAR(120)    UNIQUE,
    prof_phone      VARCHAR(20),
    prof_hire_date  DATE,
    prof_office_loc VARCHAR(25),
    dept_code       VARCHAR(8)      NOT NULL,
    
    FOREIGN KEY (prof_office_loc) REFERENCES location(loc_code),
    FOREIGN KEY (dept_code) REFERENCES department(dept_code) ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT prof_id_check CHECK (prof_id ~ '^A[0-9]{8}$')
);

-- term table
CREATE TABLE term (
    term_year       SMALLINT        NOT NULL,
    term_sem        VARCHAR(10)     NOT NULL,
    term_name       VARCHAR(30)     NOT NULL,

    term_code       VARCHAR(6)      GENERATED ALWAYS AS (
        term_year::text || 
        CASE term_sem
            WHEN 'Winter' THEN '10'
            WHEN 'Spring' THEN '30'
            WHEN 'Summer' THEN '40'
            WHEN 'Fall'   THEN '50'
        END
    ) STORED,

    CONSTRAINT term_pk PRIMARY KEY (term_code),
    CONSTRAINT term_sem_check CHECK (term_sem IN ('Winter', 'Spring', 'Summer', 'Fall')),
    CONSTRAINT term_name_unique UNIQUE (term_year, term_sem)
);

-- student table
CREATE TABLE student (
    stu_id          VARCHAR(10)     PRIMARY KEY,
    stu_last_name   VARCHAR(50)     NOT NULL,
    stu_first_name  VARCHAR(50)     NOT NULL,
    stu_email       VARCHAR(120)    UNIQUE,
    stu_phone       VARCHAR(20),
    stu_program     VARCHAR(10),
    stu_admit_term  VARCHAR(6),
    stu_dept        VARCHAR(8)      NOT NULL,

    FOREIGN KEY (stu_admit_term) REFERENCES term(term_code) ON UPDATE CASCADE ON DELETE RESTRICT,
    FOREIGN KEY (stu_dept) REFERENCES department(dept_code) ON UPDATE CASCADE ON DELETE RESTRICT,
    
    CONSTRAINT stu_id_check CHECK (stu_id ~ '^A[0-9]{8}$')
);

-- course table
CREATE TABLE course (
    crs_subject     VARCHAR(8)      NOT NULL,
    crs_num         INTEGER         NOT NULL,
    crs_title       VARCHAR(120)    NOT NULL,
    crs_credits     DECIMAL(3, 1)   NOT NULL,
    crs_dept        VARCHAR(8)      NOT NULL,
    crs_desc        TEXT,
    crs_code        VARCHAR(16)     GENERATED ALWAYS AS (crs_subject || ' ' || crs_num) STORED,

    CONSTRAINT crs_pk PRIMARY KEY (crs_code),

    CONSTRAINT crs_subj_check CHECK (crs_subject ~ '^[A-Z0-9]{2,8}$'),
    CONSTRAINT crs_num_check CHECK (crs_num BETWEEN 1 AND 9999),
    CONSTRAINT crs_creds_check CHECK (crs_credits > 0),

    CONSTRAINT crs_uni UNIQUE (crs_subject, crs_num)
);

--course offering table
CREATE TABLE course_offering (
    off_id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crs_code        VARCHAR(16)     NOT NULL,
    term_code       VARCHAR(6)      NOT NULL,

    off_sect      VARCHAR(10)     NOT NULL,
    off_type      VARCHAR(10)     NOT NULL,

    off_prof        VARCHAR(10),

    off_days        VARCHAR(3)[]    NOT NULL,
    off_start_time  TIME            NOT NULL,
    off_end_time    TIME            NOT NULL,
    off_loc_code    VARCHAR(25)     NOT NULL,
    off_cap         INTEGER         NOT NULL,

    FOREIGN KEY (off_prof) REFERENCES professor(prof_id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (off_loc_code) REFERENCES location(loc_code) ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT off_time_check CHECK (off_start_time < off_end_time),
    CONSTRAINT off_cap_check CHECK (off_cap > 0),
    CONSTRAINT off_uni UNIQUE (crs_code, term_code, off_sect)
);

--enrollment table
CREATE TABLE enrollment (
    enr_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    stu_id        VARCHAR(10)   NOT NULL,
    off_id        INTEGER       NOT NULL,
    enr_date      DATE          DEFAULT CURRENT_DATE,
    enr_status    VARCHAR(15)   NOT NULL DEFAULT 'Active',

    enr_grade     VARCHAR(5),
    enr_notes     TEXT,

    FOREIGN KEY (stu_id) REFERENCES student(stu_id) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (off_id) REFERENCES course_offering(off_id) ON UPDATE CASCADE ON DELETE CASCADE
);

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

-- DELETES
-- update or delete on table "department" violates foreign key constraint "professor_dept_code_fkey" on table "professor"
DELETE FROM department
WHERE dept_code = 'COMP';

DELETE FROM course_offering 
WHERE off_sect = 'L1' AND crs_code = 'COMP 2714';

-- update or delete on table "location" violates foreign key constraint "department_dept_location_fkey" on table "department"
DELETE FROM location
WHERE loc_code = 'SE12 260';