-- ============================================================
-- HR ANALYTICS PROJECT
-- STEP 1: RAW (STAGING) TABLE
-- ============================================================
-- all_info keeps the original CSV exactly as it is, in ONE table.
-- The column ORDER below is the same as the CSV, so the file can be
-- imported without any column mapping.
--
-- Dates are stored as TEXT on purpose. The CSV mixes two date styles
-- (20-Sep-19 and 07-10-1969). If they were imported as DATE, a server
-- with the default MDY setting would read 07-10-1969 as July 10
-- instead of 7 October, without any error. In step 2 the dates are
-- converted with TO_DATE() and an explicit format.
-- ============================================================

DROP TABLE IF EXISTS all_info;

CREATE TABLE all_info (
    employee_id INT,
    start_date VARCHAR(20),                 -- text, format DD-Mon-YY
    title VARCHAR(150),

    -- Organizational information
    businessunit VARCHAR(100),

    -- Employment information
    employeestatus VARCHAR(100),
    employeetype VARCHAR(100),
    payzone VARCHAR(50),
    employeeclassificationtype VARCHAR(100),

    -- Organizational information
    departmenttype VARCHAR(100),
    division VARCHAR(100),

    -- Personal information
    dob VARCHAR(20),                        -- text, format DD-MM-YYYY
    state VARCHAR(10),
    gender_code VARCHAR(20),
    race_desc VARCHAR(100),
    marital_desc VARCHAR(100),

    -- Performance information
    performance_score VARCHAR(50),
    current_employee_rating INT,

    -- Employee survey information
    survey_date VARCHAR(20),                -- text, format DD-MM-YYYY
    engagement_score INT,
    satisfaction_score INT,
    worklife_balance_score INT,

    -- Training information
    training_date VARCHAR(20),              -- text, format DD-Mon-YY
    training_program_name VARCHAR(150),
    training_type VARCHAR(100),
    training_outcome VARCHAR(100),
    training_duration INT,
    training_cost NUMERIC(10,2),

    age INT
);


-- ============================================================
-- IMPORT THE CSV (choose ONE option)
-- ============================================================
-- Option A - pgAdmin:
--   Right-click the table all_info -> Import/Export Data
--   Import, Format = csv, Header = ON, Delimiter = comma.
--
-- Option B - psql (run from the project folder):
--   \copy all_info FROM 'data/Cleaned_HR_Data_Analysis.csv' WITH (FORMAT csv, HEADER true)
-- ============================================================


-- ============================================================
-- CHECK THE IMPORT (expected: 2845 rows, 2845 distinct employees)
-- ============================================================

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT employee_id) AS distinct_employees
FROM all_info;
