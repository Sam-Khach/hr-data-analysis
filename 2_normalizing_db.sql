-- ============================================================
-- HR ANALYTICS PROJECT
-- STEP 2: DATABASE NORMALIZATION
-- ============================================================
-- Splits the raw table all_info into related tables:
--   lookup tables : business_units, departments, divisions, jobs,
--                   states, training_programs
--   main table    : employees
--   event tables  : employee_training, employee_surveys,
--                   performance_reviews
--
-- The script can be re-run: it drops the old tables first.
-- ============================================================


-- ============================================================
-- 0. CLEAN UP (so the script can be run again)
-- ============================================================

DROP TABLE IF EXISTS employee_training CASCADE;
DROP TABLE IF EXISTS employee_surveys CASCADE;
DROP TABLE IF EXISTS performance_reviews CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS training_programs CASCADE;
DROP TABLE IF EXISTS divisions CASCADE;
DROP TABLE IF EXISTS jobs CASCADE;
DROP TABLE IF EXISTS states CASCADE;
DROP TABLE IF EXISTS business_units CASCADE;
DROP TABLE IF EXISTS departments CASCADE;


-- ============================================================
-- 1. BUSINESS UNITS
-- ============================================================

CREATE TABLE business_units (
    business_unit_id SERIAL PRIMARY KEY,
    business_unit_code VARCHAR(20) UNIQUE NOT NULL
);

INSERT INTO business_units (business_unit_code)
SELECT DISTINCT TRIM(businessunit)
FROM all_info
WHERE businessunit IS NOT NULL;


-- ============================================================
-- 2. DEPARTMENTS
-- ============================================================
-- TRIM is needed: in the raw data many values have trailing spaces
-- (for example 'Production       ').

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) UNIQUE NOT NULL
);

INSERT INTO departments (department_name)
SELECT DISTINCT TRIM(departmenttype)
FROM all_info
WHERE departmenttype IS NOT NULL;


-- ============================================================
-- 3. DIVISIONS
-- ============================================================
-- The same division name appears in several departments, so a
-- division is unique per (division_name, department_id).
-- (A UNIQUE constraint on division_name alone would keep only one
-- department per division and leave most employees without a division.)

CREATE TABLE divisions (
    division_id SERIAL PRIMARY KEY,
    division_name VARCHAR(100) NOT NULL,
    department_id INT NOT NULL REFERENCES departments(department_id),
    UNIQUE (division_name, department_id)
);

INSERT INTO divisions (division_name, department_id)
SELECT DISTINCT
    TRIM(r.division),
    d.department_id
FROM all_info r
JOIN departments d
    ON d.department_name = TRIM(r.departmenttype)
WHERE r.division IS NOT NULL;


-- ============================================================
-- 4. JOBS
-- ============================================================
-- TRIM is needed: some job titles have trailing spaces and would
-- otherwise be stored twice.

CREATE TABLE jobs (
    job_id SERIAL PRIMARY KEY,
    title VARCHAR(150) UNIQUE NOT NULL
);

INSERT INTO jobs (title)
SELECT DISTINCT TRIM(title)
FROM all_info
WHERE title IS NOT NULL;


-- ============================================================
-- 5. STATES
-- ============================================================

CREATE TABLE states (
    state_id SERIAL PRIMARY KEY,
    state_code CHAR(2) UNIQUE NOT NULL
);

INSERT INTO states (state_code)
SELECT DISTINCT TRIM(state)
FROM all_info
WHERE state IS NOT NULL;


-- ============================================================
-- 6. EMPLOYEES
-- ============================================================
-- Dates are converted from text to DATE with an explicit format:
--   start_date : DD-Mon-YY   (20-Sep-19)
--   dob        : DD-MM-YYYY  (07-10-1969)

CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    start_date DATE NOT NULL,
    dob DATE NOT NULL,
    state_id INT REFERENCES states(state_id),
    gender_code VARCHAR(20),
    race_desc VARCHAR(50),
    marital_desc VARCHAR(50),
    employee_type VARCHAR(50),
    employee_classification_type VARCHAR(50),
    employee_status VARCHAR(50),
    pay_zone VARCHAR(20),
    job_id INT REFERENCES jobs(job_id),
    department_id INT REFERENCES departments(department_id),
    division_id INT REFERENCES divisions(division_id),
    business_unit_id INT REFERENCES business_units(business_unit_id)
);

INSERT INTO employees (
    employee_id,
    start_date,
    dob,
    state_id,
    gender_code,
    race_desc,
    marital_desc,
    employee_type,
    employee_classification_type,
    employee_status,
    pay_zone,
    job_id,
    department_id,
    division_id,
    business_unit_id
)
SELECT
    r.employee_id,
    TO_DATE(r.start_date, 'DD-Mon-YY'),
    TO_DATE(r.dob, 'DD-MM-YYYY'),
    s.state_id,
    r.gender_code,
    r.race_desc,
    r.marital_desc,
    r.employeetype,
    r.employeeclassificationtype,
    r.employeestatus,
    r.payzone,
    j.job_id,
    d.department_id,
    v.division_id,
    b.business_unit_id
FROM all_info r
LEFT JOIN states s
    ON s.state_code = TRIM(r.state)
LEFT JOIN jobs j
    ON j.title = TRIM(r.title)
LEFT JOIN departments d
    ON d.department_name = TRIM(r.departmenttype)
LEFT JOIN divisions v
    ON v.division_name = TRIM(r.division)
   AND v.department_id = d.department_id
LEFT JOIN business_units b
    ON b.business_unit_code = TRIM(r.businessunit);


-- ============================================================
-- 7. TRAINING PROGRAMS
-- ============================================================

CREATE TABLE training_programs (
    training_program_id SERIAL PRIMARY KEY,
    program_name VARCHAR(150) UNIQUE NOT NULL
);

INSERT INTO training_programs (program_name)
SELECT DISTINCT TRIM(training_program_name)
FROM all_info
WHERE training_program_name IS NOT NULL;


-- ============================================================
-- 8. EMPLOYEE TRAINING
-- ============================================================

CREATE TABLE employee_training (
    training_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employees(employee_id),
    training_program_id INT NOT NULL REFERENCES training_programs(training_program_id),
    training_date DATE,
    training_type VARCHAR(50),
    training_outcome VARCHAR(50),
    training_duration_days INT,
    training_cost NUMERIC(10,2)
);

INSERT INTO employee_training (
    employee_id,
    training_program_id,
    training_date,
    training_type,
    training_outcome,
    training_duration_days,
    training_cost
)
SELECT
    e.employee_id,
    tp.training_program_id,
    TO_DATE(r.training_date, 'DD-Mon-YY'),
    r.training_type,
    r.training_outcome,
    r.training_duration,
    r.training_cost
FROM all_info r
JOIN employees e
    ON e.employee_id = r.employee_id
JOIN training_programs tp
    ON tp.program_name = TRIM(r.training_program_name);


-- ============================================================
-- 9. EMPLOYEE SURVEYS
-- ============================================================
-- survey_date format: DD-MM-YYYY

CREATE TABLE employee_surveys (
    survey_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employees(employee_id),
    survey_date DATE NOT NULL,
    engagement_score INT,
    satisfaction_score INT,
    work_life_balance_score INT
);

INSERT INTO employee_surveys (
    employee_id,
    survey_date,
    engagement_score,
    satisfaction_score,
    work_life_balance_score
)
SELECT
    e.employee_id,
    TO_DATE(r.survey_date, 'DD-MM-YYYY'),
    r.engagement_score,
    r.satisfaction_score,
    r.worklife_balance_score
FROM all_info r
JOIN employees e
    ON e.employee_id = r.employee_id;


-- ============================================================
-- 10. PERFORMANCE REVIEWS
-- ============================================================
-- NOTE: the dataset has no separate review date, so the survey date
-- is used as the date of the performance record.

CREATE TABLE performance_reviews (
    review_id SERIAL PRIMARY KEY,
    employee_id INT NOT NULL REFERENCES employees(employee_id),
    review_date DATE NOT NULL,
    performance_score VARCHAR(50),
    employee_rating INT
);

INSERT INTO performance_reviews (
    employee_id,
    review_date,
    performance_score,
    employee_rating
)
SELECT
    e.employee_id,
    TO_DATE(r.survey_date, 'DD-MM-YYYY'),
    r.performance_score,
    r.current_employee_rating
FROM all_info r
JOIN employees e
    ON e.employee_id = r.employee_id;


-- ============================================================
-- 11. VERIFY THE NORMALIZED TABLES
-- ============================================================
-- Expected: employees, employee_training, employee_surveys and
-- performance_reviews all have 2845 rows.

SELECT 'business_units' AS table_name, COUNT(*) AS row_count FROM business_units
UNION ALL SELECT 'departments', COUNT(*) FROM departments
UNION ALL SELECT 'divisions', COUNT(*) FROM divisions
UNION ALL SELECT 'jobs', COUNT(*) FROM jobs
UNION ALL SELECT 'states', COUNT(*) FROM states
UNION ALL SELECT 'training_programs', COUNT(*) FROM training_programs
UNION ALL SELECT 'employees', COUNT(*) FROM employees
UNION ALL SELECT 'employee_training', COUNT(*) FROM employee_training
UNION ALL SELECT 'employee_surveys', COUNT(*) FROM employee_surveys
UNION ALL SELECT 'performance_reviews', COUNT(*) FROM performance_reviews;
