-- Schema to Fix
LabTracker_UNF(
    StudentID,
    StudentName,
    Campus,       -- Burnaby or Downtown
    Set,          -- Burnaby: A–D; Downtown: E–F
    Instructor,
    InstructorOffice,
    -- Repeating groups by lab (UNF):
    Lab1_Date, Lab1_Preparedness, Lab1_CheckIn, Lab1_Submitted, Lab1_SelfAssessment, Lab1_InstructorAssessment, Lab1_Comments,
    Lab2_Date, Lab2_Preparedness, Lab2_CheckIn, Lab2_Submitted, Lab2_SelfAssessment, Lab2_InstructorAssessment, Lab2_Comments,
    Lab3_Date, Lab3_Preparedness, Lab3_CheckIn, Lab3_Submitted, Lab3_SelfAssessment, Lab3_InstructorAssessment, Lab3_Comments,
    Lab4_Date, Lab4_Preparedness, Lab4_CheckIn, Lab4_Submitted, Lab4_SelfAssessment, Lab4_InstructorAssessment, Lab4_Comments, 
    Avg_AttendancePct,
    Avg_SelfScore,
    Avg_InstructorScore,
    Preparedness_Rate
)

-- 1NF 
-- Schema 1: Lab Record Table
CREATE TABLE [IF NOT EXISTS] LabTracker_1NF (
    student_id INTEGER NOT NULL,
    student_name VARCHAR(100) NOT NULL,
    student_email VARCHAR(100) NOT NULL,
    bcit_campus VARCHAR(50) NOT NULL,
    bcit_set VARCHAR(5) NOT NULL,
    instructor_name VARCHAR(100) NOT NULL,
    instructor_office VARCHAR(20) NOT NULL,
    lab_number INTEGER NOT NULL,
    lab_preparedness BOOLEAN,
    lab_checkin VARCHAR(50),
    lab_submission BOOLEAN,
    lab_self_score INTEGER,
    lab_instructor_score INTEGER,
    lab_notes VARCHAR(255),
    avg_attendance_pct DECIMAL(5, 2),
    avg_self_score DECIMAL(5, 2),
    avg_instructor_score DECIMAL (5, 2),
    preparedness_rate VARCHAR(10),
    PRIMARY KEY (student_id, lab_number)
);

-- 2NF
-- Schema 1: Student Table
CREATE TABLE [IF NOT EXISTS] students (
    student_id INTEGER NOT NULL PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    student_email VARCHAR(100) NOT NULL,
    bcit_campus VARCHAR(50) NOT NULL,
    bcit_set VARCHAR(5) NOT NULL,
    instructor_name VARCHAR(100) NOT NULL,
    instructor_office VARCHAR(20) NOT NULL,
    avg_attendance_pct DECIMAL(5, 2),
    avg_self_score DECIMAL(5, 2),
    avg_instructor_score DECIMAL (5, 2),
    preparedness_rate VARCHAR(10)
);

-- Schema 2: Lab Record Table
CREATE TABLE [IF NOT EXISTS] lab_records (
    student_id INTEGER NOT NULL,
    lab_number INTEGER NOT NULL,
    lab_preparedness BOOLEAN,
    lab_checkin VARCHAR(50),
    lab_submission BOOLEAN,
    lab_self_score INTEGER,
    lab_instructor_score INTEGER,
    lab_notes VARCHAR(255),
    PRIMARY KEY(student_id, lab_number),
    FOREIGN KEY student_id REFERENCES students(student_id)
);

-- 3NF
-- Schema 1: Student Table
CREATE TABLE [IF NOT EXISTS] students (
    student_id INTEGER NOT NULL PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    student_email VARCHAR(100) NOT NULL,
    bcit_set VARCHAR(5) NOT NULL,
    FOREIGN KEY bcit_set REFERENCES registered_sets(bcit_set)
);

-- Schema 2: Lab Record Table
CREATE TABLE [IF NOT EXISTS] lab_records (
    student_id INTEGER NOT NULL,
    lab_number INTEGER NOT NULL,
    lab_preparedness BOOLEAN,
    lab_checkin VARCHAR(50),
    lab_submission BOOLEAN,
    lab_self_score INTEGER,
    lab_instructor_score INTEGER,
    lab_notes VARCHAR(255),
    PRIMARY KEY(student_id, lab_number),
    FOREIGN KEY student_id REFERENCES students(student_id)
);

-- Schema 3: Set Schema
CREATE TABLE [IF NOT EXISTS] registered_sets (
    bcit_set VARCHAR(5) NOT NULL PRIMARY KEY,
    bcit_campus VARCHAR(50) NOT NULL,
    instructor_name VARCHAR(100) NOT NULL
    FOREIGN KEY instructor_name REFERENCES instructors(instructor_name)
);

-- Schema 4: Instructor Schema
CREATE TABLE [IF NOT EXISTS] instructors (
    instructor_name VARCHAR(100) NOT NULL PRIMARY,
    instructor_office VARCHAR(20) NOT NULL
);
-- Schema 5: Student Performance Schema
CREATE TABLE [IF NOT EXISTS] student_performances (
    student_id INTEGER NOT NULL PRIMARY KEY,
    avg_attendance_pct DECIMAL(5, 2),
    avg_self_score DECIMAL(5, 2),
    avg_instructor_score DECIMAL (5, 2),
    preparedness_rate VARCHAR(10),
    FOREIGN KEY student_id REFERENCES students(student_id)
);