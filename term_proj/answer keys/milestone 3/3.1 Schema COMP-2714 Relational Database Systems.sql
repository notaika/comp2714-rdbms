-- =========================================================
-- LabTracker - Reference schema.sql
-- Based on the Winter 2026 logical ERD
-- =========================================================

DROP SCHEMA IF EXISTS lab_tracker_reference CASCADE;
CREATE SCHEMA lab_tracker_reference;
SET search_path TO lab_tracker_reference;

-- =========================================================
-- COURSE
-- =========================================================
CREATE TABLE course (
    crs_code        TEXT PRIMARY KEY,
    crs_title       TEXT NOT NULL,
    crs_credits     INTEGER NOT NULL,
    crs_description TEXT,

    CONSTRAINT chk_course_credits_positive
        CHECK (crs_credits > 0)
);

-- =========================================================
-- TERM
-- =========================================================
CREATE TABLE term (
    term_code       TEXT PRIMARY KEY,
    term_title      TEXT NOT NULL,
    term_start_date DATE NOT NULL,
    term_end_date   DATE NOT NULL,

    CONSTRAINT chk_term_code_format
        CHECK (term_code ~ '^[0-9]{6}$'),

    CONSTRAINT chk_term_dates
        CHECK (term_end_date >= term_start_date)
);

-- =========================================================
-- STUDENT
-- =========================================================
CREATE TABLE student (
    stu_id      TEXT PRIMARY KEY,
    stu_fname   TEXT NOT NULL,
    stu_lname   TEXT NOT NULL,
    stu_email   TEXT NOT NULL,

    CONSTRAINT uq_student_email UNIQUE (stu_email),
    CONSTRAINT chk_student_email_format
        CHECK (position('@' in stu_email) > 1)
);

-- =========================================================
-- SECTION
-- Single table for lecture and lab sections.
-- Lab sections must have a set; lecture sections must not.
-- =========================================================
CREATE TABLE section (
    sec_crn         TEXT PRIMARY KEY,
    sec_type        TEXT NOT NULL,
    sec_set         TEXT,
    sec_day         TEXT NOT NULL,
    sec_start_time  TIME NOT NULL,
    sec_end_time    TIME NOT NULL,
    crs_code        TEXT NOT NULL,
    term_code       TEXT NOT NULL,

    CONSTRAINT fk_section_course
        FOREIGN KEY (crs_code)
        REFERENCES course (crs_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_section_term
        FOREIGN KEY (term_code)
        REFERENCES term (term_code)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_section_crn_type
        UNIQUE (sec_crn, sec_type),

    CONSTRAINT uq_section_term_course_set_type
        UNIQUE (term_code, crs_code, sec_set, sec_type),

    CONSTRAINT chk_section_type
        CHECK (sec_type IN ('LEC', 'LAB')),

    CONSTRAINT chk_section_lab_set_rule
        CHECK (
            (sec_type = 'LAB' AND sec_set IS NOT NULL)
            OR
            (sec_type = 'LEC' AND sec_set IS NULL)
        ),

    CONSTRAINT chk_section_day
        CHECK (sec_day IN ('Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun')),

    CONSTRAINT chk_section_time_order
        CHECK (sec_end_time > sec_start_time)
);

-- =========================================================
-- ENROLLMENT
-- Resolves the M:N relationship between STUDENT and SECTION.
-- =========================================================
CREATE TABLE enrollment (
    sec_crn            TEXT NOT NULL,
    stu_id             TEXT NOT NULL,
    enr_enrolled_at    TIMESTAMP NOT NULL,
    enr_withdrawn_at   TIMESTAMP,
    enr_status         TEXT NOT NULL,

    CONSTRAINT pk_enrollment
        PRIMARY KEY (sec_crn, stu_id),

    CONSTRAINT fk_enrollment_section
        FOREIGN KEY (sec_crn)
        REFERENCES section (sec_crn)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (stu_id)
        REFERENCES student (stu_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_enrollment_status
        CHECK (enr_status IN ('enrolled', 'withdrawn', 'dropped', 'audit')),

    CONSTRAINT chk_enrollment_withdrawn_after_enrolled
        CHECK (
            enr_withdrawn_at IS NULL
            OR enr_withdrawn_at >= enr_enrolled_at
        )
);

-- =========================================================
-- LAB_SESSION
-- Belongs only to LAB sections.
-- =========================================================
CREATE TABLE lab_session (
    lab_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sec_crn        TEXT NOT NULL,
    sec_type       TEXT NOT NULL DEFAULT 'LAB',
    lab_num        INTEGER NOT NULL,
    meeting_date   DATE NOT NULL,
    due_at         TIMESTAMP NOT NULL,

    CONSTRAINT fk_lab_session_section_lab_only
        FOREIGN KEY (sec_crn, sec_type)
        REFERENCES section (sec_crn, sec_type)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT uq_lab_session_labid_section
        UNIQUE (lab_id, sec_crn),

    CONSTRAINT uq_lab_session_section_labnum
        UNIQUE (sec_crn, lab_num),

    CONSTRAINT chk_lab_session_type_lab
        CHECK (sec_type = 'LAB'),

    CONSTRAINT chk_lab_session_lab_num_positive
        CHECK (lab_num > 0),

    CONSTRAINT chk_lab_session_due_after_meeting
        CHECK (due_at >= meeting_date::timestamp)
);

-- =========================================================
-- PROGRESS
-- Resolves the M:N relationship between STUDENT and LAB_SESSION.
-- Includes SEC_CRN so that we can enforce:
--   1) the student is enrolled in the section
--   2) the lab session belongs to that same section
-- =========================================================
CREATE TABLE progress (
    lab_id                   INTEGER NOT NULL,
    stu_id                   TEXT NOT NULL,
    sec_crn                  TEXT NOT NULL,
    attendance               TEXT NOT NULL,
    preparedness             BOOLEAN NOT NULL DEFAULT FALSE,
    in_lab_submission        TEXT,
    polished_resubmission    TEXT,
    self_assessment          INTEGER,
    instructor_assessment    INTEGER,

    CONSTRAINT pk_progress
        PRIMARY KEY (lab_id, stu_id),

    CONSTRAINT fk_progress_student
        FOREIGN KEY (stu_id)
        REFERENCES student (stu_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_progress_enrollment
        FOREIGN KEY (sec_crn, stu_id)
        REFERENCES enrollment (sec_crn, stu_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_progress_lab_section_consistency
        FOREIGN KEY (lab_id, sec_crn)
        REFERENCES lab_session (lab_id, sec_crn)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT chk_progress_attendance
        CHECK (attendance IN ('present', 'absent', 'late', 'excused')),

    CONSTRAINT chk_progress_self_assessment_range
        CHECK (
            self_assessment IS NULL
            OR self_assessment BETWEEN 0 AND 100
        ),

    CONSTRAINT chk_progress_instructor_assessment_range
        CHECK (
            instructor_assessment IS NULL
            OR instructor_assessment BETWEEN 0 AND 100
        )
);

-- =========================================================
-- PROGRESS_LOG
-- Follows the logical model exactly:
-- CHANGED_BY is stored as TEXT, not as a separate USER FK.
-- =========================================================
CREATE TABLE progress_log (
    log_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    changed_by     TEXT NOT NULL,
    changed_at     TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    what_changed   TEXT NOT NULL,
    lab_id         INTEGER NOT NULL,
    stu_id         TEXT NOT NULL,

    CONSTRAINT fk_progress_log_progress
        FOREIGN KEY (lab_id, stu_id)
        REFERENCES progress (lab_id, stu_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
);

-- =========================================================
-- Helpful indexes
-- =========================================================
CREATE INDEX idx_section_course
    ON section (crs_code);

CREATE INDEX idx_section_term
    ON section (term_code);

CREATE INDEX idx_enrollment_student
    ON enrollment (stu_id);

CREATE INDEX idx_lab_session_section
    ON lab_session (sec_crn);

CREATE INDEX idx_progress_student
    ON progress (stu_id);

CREATE INDEX idx_progress_section
    ON progress (sec_crn);

CREATE INDEX idx_progress_log_progress
    ON progress_log (lab_id, stu_id);