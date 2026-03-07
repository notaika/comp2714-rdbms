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
DROP TABLE IF EXISTS role CASCADE;
DROP TABLE IF EXISTS role_chair CASCADE;
DROP TABLE IF EXISTS role_proghead CASCADE;
DROP TABLE IF EXISTS dept_role CASCADE;
DROP TABLE IF EXISTS professor_dept_role CASCADE;


-- location table
CREATE TABLE location
(
    loc_building VARCHAR(10) NOT NULL,
    loc_room     VARCHAR(10) NOT NULL,
    loc_code     VARCHAR(25) GENERATED ALWAYS AS (loc_building || ' ' || loc_room) STORED,

    PRIMARY KEY (loc_code)
);

-- department table
CREATE TABLE department
(
    dept_code     VARCHAR(8) PRIMARY KEY,
    dept_name     VARCHAR(120) NOT NULL UNIQUE,
    dept_school   VARCHAR(80)  NOT NULL,
    dept_phone    VARCHAR(20),
    dept_email    VARCHAR(120),
    dept_website  VARCHAR(50),
    dept_location VARCHAR(25),

    FOREIGN KEY (dept_location)
        REFERENCES location (loc_code)
        ON UPDATE CASCADE,
    CONSTRAINT dept_code_check CHECK (dept_code ~ '^[A-Z0-9]{3,6}$')
);

-- professor table
CREATE TABLE professor
(
    prof_id         VARCHAR(10) PRIMARY KEY,
    prof_last_name  VARCHAR(50) NOT NULL,
    prof_first_name VARCHAR(50) NOT NULL,
    prof_email      VARCHAR(120) UNIQUE,
    prof_phone      VARCHAR(20),
    prof_hire_date  DATE,
    prof_office_loc VARCHAR(25),
    dept_code       VARCHAR(8)  NOT NULL,

    FOREIGN KEY (prof_office_loc)
        REFERENCES location (loc_code),
    FOREIGN KEY (dept_code)
        REFERENCES department (dept_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT prof_id_check CHECK (prof_id ~ '^A[0-9]{8}$')
);

-- term table
CREATE TABLE term
(
    term_year SMALLINT    NOT NULL,
    term_sem  VARCHAR(10) NOT NULL,
    term_name VARCHAR(30) NOT NULL,

    term_code VARCHAR(6) GENERATED ALWAYS AS ( term_year::text || CASE term_sem
                                                                      WHEN 'Winter' THEN '10'
                                                                      WHEN 'Spring' THEN '30'
                                                                      WHEN 'Summer' THEN '40'
                                                                      WHEN 'Fall' THEN '50' END ) STORED,

    CONSTRAINT term_pk PRIMARY KEY (term_code),
    CONSTRAINT term_sem_check CHECK (term_sem IN ('Winter', 'Spring', 'Summer', 'Fall')),
    CONSTRAINT term_name_unique UNIQUE (term_year, term_sem)
);

-- CASE
--             WHEN set_name IN ('A', 'B', 'C', 'D') THEN 'Burnaby'
--             WHEN set_name IN ('E', 'F') THEN 'Downtown'
-- END ) STORED,

-- student table
CREATE TABLE student
(
    stu_id         VARCHAR(10) PRIMARY KEY,
    stu_last_name  VARCHAR(50) NOT NULL,
    stu_first_name VARCHAR(50) NOT NULL,
    stu_email      VARCHAR(120) UNIQUE,
    stu_phone      VARCHAR(20),
    stu_program    VARCHAR(10),
    stu_admit_term VARCHAR(6),
    stu_dept       VARCHAR(8)  NOT NULL,

    FOREIGN KEY (stu_admit_term)
        REFERENCES term (term_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (stu_dept)
        REFERENCES department (dept_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT stu_id_check CHECK (stu_id ~ '^A[0-9]{8}$')
);

-- course table
CREATE TABLE course
(
    crs_subject VARCHAR(8)    NOT NULL,
    crs_num     INTEGER       NOT NULL,
    crs_title   VARCHAR(120)  NOT NULL,
    crs_credits DECIMAL(3, 1) NOT NULL,
    crs_dept    VARCHAR(8)    NOT NULL,
    crs_desc    TEXT,
    crs_code    VARCHAR(16) GENERATED ALWAYS AS (crs_subject || ' ' || crs_num) STORED,

    CONSTRAINT crs_pk PRIMARY KEY (crs_code),

    CONSTRAINT crs_subj_check CHECK (crs_subject ~ '^[A-Z0-9]{2,8}$'),
    CONSTRAINT crs_num_check CHECK (crs_num BETWEEN 1 AND 9999),
    CONSTRAINT crs_creds_check CHECK (crs_credits > 0),

    CONSTRAINT crs_uni UNIQUE (crs_subject, crs_num)
);

--course offering table
CREATE TABLE course_offering
(
    off_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crs_code       VARCHAR(16)  NOT NULL,
    term_code      VARCHAR(6)   NOT NULL,

    off_sect       VARCHAR(10)  NOT NULL,
    off_type       VARCHAR(10)  NOT NULL,

    off_prof       VARCHAR(10),

    off_days       VARCHAR(3)[] NOT NULL,
    off_start_time TIME         NOT NULL,
    off_end_time   TIME         NOT NULL,
    off_loc_code   VARCHAR(25)  NOT NULL,
    off_cap        INTEGER      NOT NULL,

    FOREIGN KEY (off_prof) REFERENCES professor (prof_id) ON UPDATE CASCADE ON DELETE SET NULL,
    FOREIGN KEY (off_loc_code)
        REFERENCES location (loc_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT off_time_check CHECK (off_start_time < off_end_time),
    CONSTRAINT off_cap_check CHECK (off_cap > 0),
    CONSTRAINT off_uni UNIQUE (crs_code, term_code, off_sect)
);

--enrollment table
CREATE TABLE enrollment
(
    enr_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    stu_id     VARCHAR(10) NOT NULL,
    off_id     INTEGER     NOT NULL,
    enr_date   DATE                 DEFAULT CURRENT_DATE,
    enr_status VARCHAR(15) NOT NULL DEFAULT 'Active',

    enr_grade  VARCHAR(5),
    enr_notes  TEXT,

    FOREIGN KEY (stu_id)
        REFERENCES student (stu_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (off_id)
        REFERENCES course_offering (off_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

-- SUPERTYPE: role 
CREATE TABLE role
(
    role_code VARCHAR(16) PRIMARY KEY,
    role_name VARCHAR(80) NOT NULL UNIQUE
);

-- SUBTYPE: department chair
CREATE TABLE role_chair
(
    role_code                    VARCHAR(16) PRIMARY KEY,
    chair_release_hours_per_term SMALLINT,
    chair_term_months            SMALLINT
);

-- SUBTYPE: program head
CREATE TABLE role_proghead
(
    role_code              VARCHAR(16) PRIMARY KEY,
    progh_budget_authority BOOLEAN,
    progh_max_programs     SMALLINT,

    FOREIGN KEY (role_code)
        REFERENCES role (role_code)
        ON UPDATE CASCADE
        ON DELETE CASCADE
);

CREATE TABLE dept_role
(
    dept_code        VARCHAR(8)  NOT NULL,
    role_code        VARCHAR(16) NOT NULL,
    dept_role_active BOOLEAN     NOT NULL DEFAULT TRUE,

    CONSTRAINT dept_pk PRIMARY KEY (dept_code, role_code)
);

CREATE TABLE professor_dept_role
(
    pdr_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dept_code      VARCHAR(8)  NOT NULL,
    role_code      VARCHAR(16) NOT NULL,
    prof_id        VARCHAR(10) NOT NULL,

    pdr_start_date DATE        NOT NULL,
    pdr_end_date   DATE,

    FOREIGN KEY (dept_code, role_code)
        REFERENCES dept_role (dept_code, role_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (prof_id)
        REFERENCES professor (prof_id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    CONSTRAINT pdr_dates_check CHECK (pdr_end_date IS NULL OR pdr_start_date < pdr_end_date),
    CONSTRAINT pdr_uni UNIQUE (dept_code, role_code, prof_id, pdr_start_date)
);

-- Business rule: only ONE current holder (NULL end date) per department-role
CREATE UNIQUE INDEX pdr_one_active_per_dept_role_index ON professor_dept_role (dept_code, role_code) WHERE pdr_end_date IS NULL;

-- INSERTS
SELECT * FROM term;