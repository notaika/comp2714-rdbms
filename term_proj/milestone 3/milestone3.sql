DROP SCHEMA IF EXISTS lab_tracker_group_10 CASCADE;
CREATE SCHEMA lab_tracker_group_10;
SET search_path TO lab_tracker_group_10;

DROP TABLE IF EXISTS progress_log CASCADE;
DROP TABLE IF EXISTS submission CASCADE;
DROP TABLE IF EXISTS progress CASCADE;
DROP TABLE IF EXISTS enrollment CASCADE;
DROP TABLE IF EXISTS section_teacher_allocation CASCADE;
DROP TABLE IF EXISTS lab_session CASCADE;
DROP TABLE IF EXISTS lecture CASCADE;
DROP TABLE IF EXISTS lab CASCADE;
DROP TABLE IF EXISTS section CASCADE;
DROP TABLE IF EXISTS course CASCADE;
DROP TABLE IF EXISTS student CASCADE;
DROP TABLE IF EXISTS professor CASCADE;
DROP TABLE IF EXISTS term CASCADE;
DROP TABLE IF EXISTS set CASCADE;
DROP TABLE IF EXISTS department CASCADE;

-- DEPARTMENT
CREATE TABLE department
(
    dpt_code      VARCHAR(8) PRIMARY KEY,
    dpt_name      VARCHAR(50)  NOT NULL,
    dpt_school    VARCHAR(120) NOT NULL,
    dpt_email     VARCHAR(50)  NOT NULL,
    dpt_location  VARCHAR(25)  NOT NULL,
    dpt_phone_num VARCHAR(15),
    dpt_website   VARCHAR(50),

    CONSTRAINT dept_code_check CHECK (dpt_code ~ '^[A-Z0-9]{3,6}$')
);

-- TERM
CREATE TABLE term
(
    term_year       SMALLINT    NOT NULL,
    term_sem        VARCHAR(25) NOT NULL,
    term_start_date DATE        NOT NULL,
    term_end_date   DATE        NOT NULL,
    term_name       VARCHAR(30) GENERATED ALWAYS AS ( term_sem || ' ' || term_year::text ) STORED,

    term_code       VARCHAR(6) GENERATED ALWAYS AS ( (term_year::text) || CASE term_sem
                                                                              WHEN 'Winter' THEN '10'
                                                                              WHEN 'Spring/Summer' THEN '20'
                                                                              WHEN 'Fall' THEN '30' END ) STORED,

    CONSTRAINT term_pk PRIMARY KEY (term_code),
    CONSTRAINT term_sem_ck CHECK (term_sem IN ('Winter', 'Spring/Summer', 'Fall')),
    CONSTRAINT term_name_year_sem_ui UNIQUE (term_year, term_sem)
);

-- SET
CREATE TABLE set
(
    set_code      INTEGER PRIMARY KEY GENERATED ALWAYS AS IDENTITY,
    set_name      VARCHAR(2) NOT NULL,
    set_program   VARCHAR(8) NOT NULL,
    set_term_year VARCHAR(6) NOT NULL,
    set_capacity  INTEGER    NOT NULL DEFAULT 25,
    set_campus    VARCHAR(15) GENERATED ALWAYS AS ( CASE
                                                        WHEN set_name IN ('A', 'B', 'C', 'D') THEN 'Burnaby'
                                                        WHEN set_name IN ('E', 'F') THEN 'Downtown' END ) STORED,
    FOREIGN KEY (set_term_year)
        REFERENCES term (term_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT set_name_ck CHECK (set_name IN ('A', 'B', 'C', 'D', 'E', 'F'))
);

-- USER
CREATE TABLE "user"
(
    user_id      VARCHAR(20) PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    role         VARCHAR(20)  NOT NULL,
    email        VARCHAR(120) UNIQUE,
    
    CONSTRAINT role_check CHECK (role IN ('instructor', 'ta', 'system', 'student'))
);

-- PROFESSOR
CREATE TABLE professor
(
    prof_id         VARCHAR(10) PRIMARY KEY,
    prof_last_name  VARCHAR(50) NOT NULL,
    prof_first_name VARCHAR(50) NOT NULL,
    prof_email      VARCHAR(120) UNIQUE,
    prof_phone      VARCHAR(15),
    user_id         VARCHAR(20),

    FOREIGN KEY (user_id)
        REFERENCES "user" (user_id),
    CONSTRAINT prof_id_ck CHECK (prof_id ~ '^A[0-9]{8}$')
);

-- STUDENT
CREATE TABLE student
(
    stu_id         VARCHAR(10) PRIMARY KEY,
    stu_last_name  VARCHAR(50) NOT NULL,
    stu_first_name VARCHAR(50) NOT NULL,
    stu_program    VARCHAR(10) NOT NULL,
    stu_email      VARCHAR(50) UNIQUE,
    stu_phone      VARCHAR(15),
    stu_dpt        VARCHAR(8)  NOT NULL,
    stu_admit_term VARCHAR(6)  NOT NULL,
    stu_set        VARCHAR(2)  NOT NULL,
    user_id        VARCHAR(20),

    FOREIGN KEY (stu_dpt)
        REFERENCES department (dpt_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (stu_admit_term)
        REFERENCES term (term_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    FOREIGN KEY (user_id)
        REFERENCES "user" (user_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    CONSTRAINT stu_id_ck CHECK (stu_id ~ '^[A-Z0-9]{4,9}')
);

-- COURSE
CREATE TABLE course
(
    crs_num   INTEGER,
    crs_dpt   VARCHAR(8)    NOT NULL,
    crs_title VARCHAR(120)  NOT NULL,
    crs_creds NUMERIC(3, 1) NOT NULL,
    crs_desc  TEXT,
    crs_code  VARCHAR(16) GENERATED ALWAYS AS ( crs_dpt || ' ' || crs_num) STORED,

    CONSTRAINT crs_pk PRIMARY KEY (crs_code),

    FOREIGN KEY (crs_dpt)
        REFERENCES department (dpt_code),
    CONSTRAINT crs_num_ck CHECK (crs_num BETWEEN 1 AND 9999),
    CONSTRAINT crs_creds_ck CHECK (crs_creds > 0),

    CONSTRAINT crs_ui UNIQUE (crs_dpt, crs_num)
);

