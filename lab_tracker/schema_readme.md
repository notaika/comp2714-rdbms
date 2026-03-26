# Lab Tracker Schema Design Notes  
Group: 10

### Primary Key Choices

Most tables use single-column primary keys to simplify joins and foreign key references. Natural identifiers were used where meaningful identifiers already exist in the domain, such as `dpt_code`, `term_code`, `user_id`, `prof_id`, `stu_id`, `crs_code`, `section_id`, `session_id`, `prog_id`, and `log_id`.

The `set` table uses `set_code` as a surrogate primary key because set letters (A–F) repeat across different terms. Using a generated identifier avoids ambiguity when referencing a specific set.

`crs_code` is used as the primary key for `course` instead of `crs_num` because course numbers are only unique within a department. The combined code such as `COMP 2714` uniquely identifies a course.

### Constraints

The schema uses `NOT NULL`, `UNIQUE`, `CHECK`, and generated columns to enforce attribute integrity.

Examples include:
- `term_sem` restricted to `Winter`, `Spring/Summer`, or `Fall`
- `set_name` restricted to `A` through `F`
- `"user".role` restricted to valid system roles
- `sec_cap > 0`
- `sec_start_date < sec_end_date`
- `ses_start_time < ses_end_time`
- `prog_attendance` restricted to `Present`, `Absent`, `Late`, or `Excused`
- `prog_self_score` and `prog_prof_score` limited to the range `0–100`
- `weight >= 0`

Defaults were used where appropriate, such as `sec_type = 'Lab'`, `prog_attendance = 'Absent'`, `prog_preparedness = FALSE`, and `log_timestamp = CURRENT_TIMESTAMP`.

Generated columns are used where values can be derived consistently, including `term_name`, `term_code`, `crs_code`, and `set_campus`.

### Referential Actions

Foreign keys use `ON UPDATE CASCADE` and `ON DELETE RESTRICT`.

`ON UPDATE CASCADE` ensures that if a referenced identifier changes, related rows remain consistent.  
`ON DELETE RESTRICT` prevents removal of records that are referenced by other tables, protecting historical records such as lab sessions and student progress.

### Indexes

Primary keys and unique constraints automatically create indexes in PostgreSQL. These indexes support joins and lookups on commonly referenced attributes across the schema.

### Adjustments

The schema follows the logical ERD structure. `lab` is implemented as a subtype of `section`, meaning every lab must correspond to an existing section with `sec_type = 'Lab'`.

`lab_session` references `set`, `lab`, and `professor`, reflecting the rule that each lab meeting belongs to one lab section, is associated with one student set, and is led by one professor.

`progress` references both `student` and `lab_session` so that each progress record is tied to a specific student and scheduled session.