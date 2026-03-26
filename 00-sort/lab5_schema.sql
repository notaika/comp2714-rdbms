-- 1. Create a schema for this lab (only runs once)
CREATE SCHEMA IF NOT EXISTS lab5;

-- 2. Tell PostgreSQL to use this schema by default
SET search_path TO lab5;

-- 3. Safety header: drop old tables if they exist
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





-- 4. Create your tables in this schema
-- LOCATION table
CREATE TABLE location (
    LOC_building_code VARCHAR(10) NOT NULL,
    LOC_room_code     VARCHAR(10) NOT NULL,
    LOC_code          VARCHAR(25) GENERATED ALWAYS AS (
                          LOC_building_code || ' ' || LOC_room_code
                      ) STORED PRIMARY KEY
);


-- DEPARTMENT table
CREATE TABLE department (
    DEPT_code       VARCHAR(8) PRIMARY KEY
                    CHECK (DEPT_code ~ '^[A-Z0-9]{3,6}$'),   -- e.g., ACCT, MKTG
    DEPT_name       VARCHAR(120) NOT NULL UNIQUE,
    DEPT_school     VARCHAR(80) NOT NULL,
    DEPT_phone      VARCHAR(20),
    DEPT_email      VARCHAR(120),
    DEPT_website    VARCHAR(255),
    DEPT_location   VARCHAR(25) REFERENCES location(loc_code)
                                 ON UPDATE CASCADE
);

-- PROFESSOR table
CREATE TABLE professor (
    PROF_bcit_id      VARCHAR(10) PRIMARY KEY
                      CHECK (PROF_bcit_id ~ '^A[0-9]{8}$'),   -- e.g., A00123456
    PROF_last_name    VARCHAR(50) NOT NULL,
    PROF_first_name   VARCHAR(50) NOT NULL,
    PROF_email        VARCHAR(120) UNIQUE,
    PROF_phone        VARCHAR(20),
    PROF_hire_date    DATE,
    PROF_office_loc   VARCHAR(25) REFERENCES location(loc_code),

    DEPT_code         VARCHAR(8) NOT NULL
                      REFERENCES department(dept_code)
                      ON UPDATE CASCADE
                      ON DELETE RESTRICT
);


-- TERM table
CREATE TABLE term (
    TERM_year       SMALLINT    NOT NULL,               -- e.g., 2025
    TERM_semester   VARCHAR(10) NOT NULL,               -- 'Winter' | 'Spring' | 'Summer' | 'Fall'
    TERM_name       VARCHAR(30) NOT NULL,               -- e.g., 'Fall 2025'

    -- Generated code: YYYY + nn where nn depends on semester
    TERM_code       VARCHAR(6)  GENERATED ALWAYS AS (
        (TERM_year::text) ||
        CASE TERM_semester
            WHEN 'Winter' THEN '10'
            WHEN 'Spring' THEN '30'
            WHEN 'Summer' THEN '40'
            WHEN 'Fall'   THEN '50'
        END
    ) STORED,

    -- Keys & checks
    CONSTRAINT term_pk PRIMARY KEY (TERM_code),
    CONSTRAINT term_semester_ck CHECK (TERM_semester IN ('Winter','Spring','Summer','Fall')),
    CONSTRAINT term_name_year_sem_uniq UNIQUE (TERM_year, TERM_semester)
);

-- STUDENT table
CREATE TABLE student (
    STU_bcit_id     VARCHAR(10) PRIMARY KEY
                    CHECK (STU_bcit_id ~ '^A[0-9]{8}$'),   -- e.g., A00123456
    STU_last_name   VARCHAR(50) NOT NULL,
    STU_first_name  VARCHAR(50) NOT NULL,
    STU_email       VARCHAR(120) UNIQUE,
    STU_phone       VARCHAR(20),
    STU_program     VARCHAR(10),     -- e.g., CST, NURS, ACCT (could link to a PROGRAM table later)
    STU_admit_term  VARCHAR(6)      -- e.g., 202430 (Spring 2024 term code)
                    REFERENCES term(TERM_code)
                    ON UPDATE CASCADE
                    ON DELETE RESTRICT,
    STU_department  VARCHAR(8) NOT NULL
                    REFERENCES department(DEPT_code)
                    ON UPDATE CASCADE
                    ON DELETE RESTRICT
);

CREATE TABLE course (
    COURSE_subject   VARCHAR(8)  NOT NULL,              -- e.g., COMP, MATH
    COURSE_number    INTEGER     NOT NULL,              -- e.g., 2714
    COURSE_title     VARCHAR(120) NOT NULL,             -- e.g., 'Relational Database Systems'
    COURSE_credits   NUMERIC(3,1) NOT NULL,             -- e.g., 4.0
    COURSE_dept      VARCHAR(8)  NOT NULL
                     REFERENCES department(DEPT_code)
                     ON UPDATE CASCADE
                     ON DELETE RESTRICT,
    COURSE_desc      TEXT,

    -- Generated primary key, e.g., 'COMP 2714'
    COURSE_code      VARCHAR(16) GENERATED ALWAYS AS (
        COURSE_subject || ' ' || COURSE_number::text
    ) STORED,
    CONSTRAINT course_pk PRIMARY KEY (COURSE_code),

    -- Useful guards
    CONSTRAINT course_subj_ck  CHECK (COURSE_subject ~ '^[A-Z0-9]{2,8}$'),
    CONSTRAINT course_num_ck   CHECK (COURSE_number BETWEEN 1 AND 9999),
    CONSTRAINT course_credits_ck CHECK (COURSE_credits > 0),

    -- Avoid duplicates like two rows both saying COMP + 2714
    CONSTRAINT course_uni UNIQUE (COURSE_subject, COURSE_number)
);

-- COURSE_OFFERING table 
CREATE TABLE course_offering (
    OFFER_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    COURSE_code      VARCHAR(16) NOT NULL
                     REFERENCES course(COURSE_code)
                     ON UPDATE CASCADE ON DELETE RESTRICT,

    TERM_code        VARCHAR(6)  NOT NULL
                     REFERENCES term(TERM_code)
                     ON UPDATE CASCADE ON DELETE RESTRICT,

    -- Human label students see in timetables (e.g., 'LEC', 'L1', 'L2')
    OFFER_section      VARCHAR(10) NOT NULL,

    -- The kind of event this is
    OFFER_type       VARCHAR(10) NOT NULL,
    CONSTRAINT offer_type_ck
        CHECK (OFFER_type IN ('Lecture','Lab')),

    -- Who teaches (optional while scheduling)
    OFFER_prof_id    VARCHAR(10)
                     REFERENCES professor(PROF_bcit_id)
                     ON UPDATE CASCADE ON DELETE SET NULL,

    -- When & where
    OFFER_days       VARCHAR(20) NOT NULL,     -- e.g., 'Mon,Wed' or 'Fri'
    OFFER_start_time TIME        NOT NULL,
    OFFER_end_time   TIME        NOT NULL,
    OFFER_loc_code   VARCHAR(25) NOT NULL
                     REFERENCES location(LOC_code)
                     ON UPDATE CASCADE ON DELETE RESTRICT,

    OFFER_cap        INTEGER CHECK (OFFER_cap >= 0),

    CONSTRAINT offer_time_ck
        CHECK (OFFER_start_time < OFFER_end_time),

    -- Prevent duplicates within a course+term
    CONSTRAINT offering_uni UNIQUE (COURSE_code, TERM_code, OFFER_section)
);

CREATE TABLE enrollment (
    ENR_id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    STU_bcit_id     VARCHAR(10) NOT NULL
                    REFERENCES student(STU_bcit_id)
                    ON UPDATE CASCADE ON DELETE CASCADE,

    OFFER_id        INTEGER NOT NULL
                    REFERENCES course_offering(OFFER_id)
                    ON UPDATE CASCADE ON DELETE CASCADE,

    ENR_date        DATE NOT NULL DEFAULT CURRENT_DATE,  -- when enrollment occurred
    ENR_status      VARCHAR(15) NOT NULL DEFAULT 'Active',
    -- e.g., 'Active', 'Dropped', 'Completed', 'Failed'

    ENR_grade       VARCHAR(5),                         -- optional final grade
    ENR_notes       TEXT,

    CONSTRAINT enr_status_ck
        CHECK (ENR_status IN ('Active','Dropped','Completed','Failed')),

    -- prevent double-enrolling in the same offering
    CONSTRAINT enr_uni UNIQUE (STU_bcit_id, OFFER_id)
);
-- Supertype: one row per role kind (e.g., 'Chair', 'ProgHead')
CREATE TABLE role (
    ROLE_code  VARCHAR(16)  PRIMARY KEY,      -- e.g., 'Chair', 'ProgHead'
    ROLE_name  VARCHAR(80)  NOT NULL UNIQUE   -- human label
);

-- Subtype: Department Chair
CREATE TABLE role_chair (
    ROLE_code                      VARCHAR(16) PRIMARY KEY
                                   REFERENCES role(ROLE_code)
                                   ON UPDATE CASCADE ON DELETE CASCADE,
    CHAIR_release_hours_per_term   SMALLINT,         -- example unique attr
    CHAIR_term_months              SMALLINT
);

-- Subtype: Program Head
CREATE TABLE role_proghead (
    ROLE_code                      VARCHAR(16) PRIMARY KEY
                                   REFERENCES role(ROLE_code)
                                   ON UPDATE CASCADE ON DELETE CASCADE,
    PROGH_budget_authority         BOOLEAN,          -- example unique attr
    PROGH_max_programs             SMALLINT
);

CREATE TABLE dept_role (
    DEPT_code  VARCHAR(8)  NOT NULL
               REFERENCES department(DEPT_code)
               ON UPDATE CASCADE ON DELETE CASCADE,  -- weak entity behavior
    ROLE_code  VARCHAR(16) NOT NULL
               REFERENCES role(ROLE_code)
               ON UPDATE CASCADE ON DELETE RESTRICT,

    DEPR_active BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT dept_role_pk PRIMARY KEY (DEPT_code, ROLE_code)
);

CREATE TABLE professor_dept_role (
    PDR_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    DEPT_code      VARCHAR(8)  NOT NULL,
    ROLE_code      VARCHAR(16) NOT NULL,
    PROF_bcit_id   VARCHAR(10) NOT NULL
                   REFERENCES professor(PROF_bcit_id)
                   ON UPDATE CASCADE ON DELETE CASCADE,

    PDR_start_date DATE NOT NULL,
    PDR_end_date   DATE,

    -- Tie to the dept-scoped position (the weak entity)
    CONSTRAINT pdr_dept_role_fk
      FOREIGN KEY (DEPT_code, ROLE_code)
      REFERENCES dept_role(DEPT_code, ROLE_code)
      ON UPDATE CASCADE ON DELETE RESTRICT,

    CONSTRAINT pdr_dates_ck
      CHECK (PDR_end_date IS NULL OR PDR_start_date < PDR_end_date),

    -- Avoid duplicate periods; tweak if you prefer a different uniqueness rule
    CONSTRAINT pdr_uni UNIQUE (DEPT_code, ROLE_code, PROF_bcit_id, PDR_start_date)
);

-- Business rule: only ONE current holder (NULL end date) per department-role
CREATE UNIQUE INDEX pdr_one_current_per_dept_role_idx
    ON professor_dept_role (DEPT_code, ROLE_code)
    WHERE PDR_end_date IS NULL;
