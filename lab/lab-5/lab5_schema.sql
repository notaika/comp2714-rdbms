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
DROP TABLE IF EXISTS STUDENT CASCADE;
DROP TABLE IF EXISTS PROFESSOR CASCADE;
DROP TABLE IF EXISTS TERM CASCADE;
DROP TABLE IF EXISTS DEPARTMENT CASCADE;
DROP TABLE IF EXISTS BUILDING CASCADE;


-- BUILDING Table
CREATE TABLE BUILDING
(
    build_code      VARCHAR(5)       NOT NULL, 
    build_room      CHAR(5)          NOT NULL,
    
    
    PRIMARY KEY (build_code, build_room)
);

-- DEPARTMENT Table
CREATE TABLE DEPARTMENT
(
    dep_code      VARCHAR(5)     NOT NULL,
    dep_name      VARCHAR(30)    NOT NULL,
    dep_school    VARCHAR(50)    NOT NULL,
    dep_phone     CHAR(12)       NOT NULL,
    dep_email     VARCHAR(30)    NOT NULL,
    dep_website   VARCHAR(30)    NOT NULL,
    build_code    VARCHAR(5)     NOT NULL,
    build_room    CHAR(5)        NOT NULL,

    PRIMARY KEY (dep_code),
    FOREIGN KEY (build_code, build_room) REFERENCES BUILDING (build_code, build_room) ON UPDATE CASCADE
);

-- TERM Table
CREATE TABLE TERM
(
    term_name       VARCHAR(15)     NOT NULL,
    term_year       INTEGER         NOT NULL,
    term_semester   VARCHAR(10)     NOT NULL,
    
    PRIMARY KEY (term_name)
);

-- PROFESSOR Table
CREATE TABLE PROFESSOR 
(
    prof_num            CHAR(9)    NOT NULL,
    prof_lname          VARCHAR(35)   NOT NULL,
    prof_fname          VARCHAR(35)   NOT NULL,
    prof_email          VARCHAR(35)   NOT NULL,
    prof_phone          CHAR(12)      NOT NULL,
    prof_date_hired     DATE          DEFAULT CURRENT_DATE,
    build_code          VARCHAR(5)    NOT NULL,
    build_room          CHAR(5)       NOT NULL,
    dep_code            VARCHAR(5)    NOT NULL,       

    PRIMARY KEY (prof_num),
    FOREIGN KEY (build_code, build_room) REFERENCES BUILDING (build_code, build_room) ON UPDATE CASCADE,
    FOREIGN KEY (dep_code) REFERENCES DEPARTMENT (dep_code) ON UPDATE CASCADE
);

-- STUDENT Table
CREATE TABLE STUDENT 
(
    stu_num      CHAR(9)       NOT NULL, 
    stu_lname    VARCHAR(35)   NOT NULL,
    stu_fname    VARCHAR(35)   NOT NULL,
    stu_email    VARCHAR(35)   NOT NULL,
    stu_phone    CHAR(12)      NOT NULL,
    stu_program  VARCHAR(5)    NOT NULL,
    term_name    VARCHAR(15)   NOT NULL,
    dep_code     VARCHAR(5)    NOT NULL,
    
    PRIMARY KEY (stu_num),
    FOREIGN KEY (term_name) REFERENCES TERM (term_name) ON UPDATE CASCADE,
    FOREIGN KEY (dep_code) REFERENCES DEPARTMENT (dep_code) ON UPDATE CASCADE
);

-- COURSE Table
CREATE TABLE COURSE
(
    crs_code      VARCHAR(4)      NOT NULL,
    crs_title     VARCHAR(30)     NOT NULL,
    crs_credits   DECIMAL(3, 1)   NOT NULL,
    dep_code      VARCHAR(5)      NOT NULL,
    crs_desc      TEXT,

    PRIMARY KEY (dep_code, crs_code),
    FOREIGN KEY (dep_code) REFERENCES DEPARTMENT (dep_code) ON UPDATE CASCADE,

    CONSTRAINT check_crs_credits CHECK (crs_credits >= 0)
);

-- COURSE OFFERING Table
CREATE TABLE COURSE_OFFERING
(
    off_id          INTEGER         NOT NULL,
    dep_code        VARCHAR(5)      NOT NULL,
    crs_code        VARCHAR(4)      NOT NULL, 
    term_code       CHAR(6)         NOT NULL,
    off_section     VARCHAR(5)      NOT NULL,
    off_type        VARCHAR(10)     NOT NULL,
    prof_num        CHAR(9)         NOT NULL,
    off_days        VARCHAR(3)[]    NOT NULL,
    off_start_time  TIME            NOT NULL,
    off_end_time    TIME            NOT NULL,
    build_code      VARCHAR(5)      NOT NULL, 
    build_room      CHAR(5)         NOT NULL,
    off_capacity    INTEGER         NOT NULL,
    
    
    PRIMARY KEY (dep_code, crs_code, term_code, off_section), 
    FOREIGN KEY (dep_code, crs_code) REFERENCES COURSE (dep_code, crs_code),
    FOREIGN KEY (build_code, build_room) REFERENCES BUILDING (build_code, build_room),
    FOREIGN KEY (prof_num) REFERENCES PROFESSOR (prof_num),

    CONSTRAINT unique_offering UNIQUE (dep_code, crs_code, term_code, off_section),
    CONSTRAINT check_off_capacity CHECK (off_capacity > 0),
    CONSTRAINT check_off_time CHECK (off_end_time > off_start_time)
);

-- ENROLLMENT Table
CREATE TABLE ENROLLMENT
(
    stu_num           CHAR(9)       NOT NULL,
    dep_code          VARCHAR(5)    NOT NULL,
    crs_code          VARCHAR(4)    NOT NULL, 
    term_code         CHAR(6)       NOT NULL,
    off_section       VARCHAR(5)    NOT NULL,
    enr_status        VARCHAR(20)   NOT NULL,   
    enr_final_grade   CHAR(2),

    PRIMARY KEY (stu_num, dep_code, crs_code, term_code),
    FOREIGN KEY (stu_num) REFERENCES STUDENT (stu_num) ON DELETE CASCADE,
    FOREIGN KEY (dep_code, crs_code, term_code, off_section) REFERENCES COURSE_OFFERING (dep_code, crs_code, term_code, off_section) ON DELETE CASCADE
);

