-- Notes:
-- 1. Don't forget that table order matters
-- 2. Name your constraints
-- 3. Check lab notes

-- FROM LAB SETUP
-- 1. Only runs once (this creates the schema)
CREATE SCHEMA IF NOT EXISTS lab5;

-- 2. Tell PostgreSQL to use this by default
SET search_path TO lab5;

-- 3. Safety header: drop old tables if they exist (if want to keep re-running)
DROP TABLE IF EXISTS ENROLLMENT CASCADE;
DROP TABLE IF EXISTS COURSE_OFFERING CASCADE;
DROP TABLE IF EXISTS COURSE CASCADE;
DROP TABLE IF EXISTS PROFESSOR CASCADE;
DROP TABLE IF EXISTS DEPARTMENT CASCADE;
DROP TABLE IF EXISTS STUDENT CASCADE;
DROP TABLE IF EXISTS TERM CASCADE;
DROP TABLE IF EXISTS BUILDING CASCADE;


-- BUILDING Table
CREATE TABLE BUILDING
(
    build_code      CHAR(8)      NOT NULL, 
    build_name      VARCHAR(25)  NOT NULL,
    build_room      CHAR(5)      NOT NULL,
    
    PRIMARY KEY (build_code)
);

-- TERM Table
CREATE TABLE TERM
(
    term_code       CHAR(6)     NOT NULL,
    term_semester   CHAR(1)     NOT NULL,
    term_years      INTEGER     NOT NULL,
    
    PRIMARY KEY (term_code)
);

-- STUDENT Table
CREATE TABLE STUDENT 
(
    stu_num      CHAR(9)       NOT NULL, 
    stu_fname    VARCHAR(35)   NOT NULL,
    stu_lname    VARCHAR(35)   NOT NULL,
    
    PRIMARY KEY (stu_num)
);

-- DEPARTMENT Table
CREATE TABLE DEPARTMENT
(
    dep_code      VARCHAR(5)     NOT NULL,
    dep_name      VARCHAR(30)    NOT NULL,
    build_code    CHAR(8)        NOT NULL,

    PRIMARY KEY (dep_code),
    FOREIGN KEY (build_code) REFERENCES BUILDING (build_code) ON UPDATE CASCADE
);

-- PROFESSOR Table
CREATE TABLE PROFESSOR 
(
    prof_num     NUMERIC(9)    NOT NULL,
    prof_fname   VARCHAR(35)   NOT NULL,
    prof_lname   VARCHAR(35)   NOT NULL,
    dep_code     VARCHAR(5)    NOT NULL,

    PRIMARY KEY (prof_num),
    FOREIGN KEY (dep_code) REFERENCES DEPARTMENT (dep_code) ON UPDATE CASCADE
);

-- COURSE Table
CREATE TABLE COURSE
(
    crs_code      VARCHAR(4)    NOT NULL,
    crs_title     VARCHAR(30)   NOT NULL,
    crs_credits   INTEGER       NOT NULL,
    dep_code      VARCHAR(5)    NOT NULL,

    PRIMARY KEY (crs_code),
    FOREIGN KEY (dep_code) REFERENCES DEPARTMENT (dep_code) ON UPDATE CASCADE,

    CONSTRAINT check_crs_credits CHECK (crs_credits >= 0)
);

-- COURSE OFFERING Table
CREATE TABLE COURSE_OFFERING
(
    off_id          CHAR(5)     NOT NULL,
    crs_code        VARCHAR(4)  NOT NULL,
    term_code       CHAR(6)     NOT NULL,
    off_section     VARCHAR(5)  NOT NULL,
    off_capacity    INTEGER     NOT NULL,
    off_start_time  TIME        NOT NULL,
    off_end_time    TIME        NOT NULL,
    off_notes       TEXT,
    build_code      CHAR(8)     NOT NULL,
    prof_num        NUMERIC(9)  NOT NULL,

    PRIMARY KEY (off_id),
    FOREIGN KEY (crs_code) REFERENCES COURSE (crs_code),
    FOREIGN KEY (term_code) REFERENCES TERM (term_code),
    FOREIGN KEY (build_code) REFERENCES BUILDING (build_code),
    FOREIGN KEY (prof_num) REFERENCES PROFESSOR (prof_num),

    CONSTRAINT unique_offering UNIQUE (crs_code, term_code, off_section),
    CONSTRAINT check_off_capacity CHECK (off_capacity > 0),
    CONSTRAINT check_off_time CHECK (off_end_time > off_start_time)
);

-- ENROLLMENT Table
CREATE TABLE ENROLLMENT
(
    stu_num           CHAR(9)       NOT NULL,
    off_id            CHAR(5)       NOT NULL,
    enr_status        VARCHAR(20)   NOT NULL,   
    enr_final_grade   CHAR(2),

    PRIMARY KEY (stu_num, off_id),
    FOREIGN KEY (stu_num) REFERENCES STUDENT (stu_num) ON DELETE CASCADE,
    FOREIGN KEY (off_id) REFERENCES COURSE_OFFERING (off_id) ON DELETE CASCADE
);

