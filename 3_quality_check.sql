-- ============================================================
-- HR ANALYTICS PROJECT
-- STEP 3: DATA QUALITY CHECKS
-- ============================================================
-- Main checks:
--   1-3    Missing values and duplicate employees
--   4-6    Date logic (birth date, start date, age at hire)
--   7-10   Performance ratings and survey scores
--   11-17  Training data and duplicate records
--   18-25  Referential integrity between tables
--   26-30  Extra checks: spaces in raw text, row counts,
--          training/survey before start date, score vs rating
--
-- How to read the results: most checks should return 0 rows.
-- Checks marked "REVIEW" can return rows; they show data issues
-- that should be known before the analysis is used.
-- ============================================================


-- ============================================================
-- 1. CHECK MISSING VALUES IN EMPLOYEES
-- ============================================================
--
-- Important employee relationships should normally exist.

SELECT
    employee_id,
    department_id,
    job_id,
    state_id,
    business_unit_id
FROM employees
WHERE department_id IS NULL
   OR job_id IS NULL
   OR state_id IS NULL
   OR business_unit_id IS NULL;



-- ============================================================
-- 2. CHECK MISSING VALUES IN IMPORTANT EMPLOYEE ATTRIBUTES
-- ============================================================

SELECT
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE start_date IS NULL) AS missing_start_date,
    COUNT(*) FILTER (WHERE dob IS NULL) AS missing_dob,
    COUNT(*) FILTER (WHERE gender_code IS NULL) AS missing_gender,
    COUNT(*) FILTER (WHERE employee_status IS NULL) AS missing_status,
    COUNT(*) FILTER (WHERE pay_zone IS NULL) AS missing_pay_zone
FROM employees;


-- ============================================================
-- 3. CHECK FOR DUPLICATE EMPLOYEE IDs
-- ============================================================

SELECT
    employee_id,
    COUNT(*) AS employee_count
FROM employees
GROUP BY employee_id
HAVING COUNT(*) > 1;


-- ============================================================
-- 4. CHECK EMPLOYEE DATE VALUES
-- ============================================================

SELECT
    employee_id,
    dob,
    start_date
FROM employees
WHERE dob >= start_date;



-- ============================================================
-- 5. CHECK FUTURE EMPLOYEE START DATES
-- ============================================================

SELECT
    employee_id,
    start_date
FROM employees
WHERE start_date > CURRENT_DATE;



-- ============================================================
-- 6. CHECK AGE AT HIRE (REVIEW)
-- ============================================================
-- Employees hired younger than 18 or older than 75 are unusual.

SELECT
    employee_id,
    dob,
    start_date,
    EXTRACT(YEAR FROM AGE(start_date, dob)) AS age_at_hire
FROM employees
WHERE EXTRACT(YEAR FROM AGE(start_date, dob)) < 18
   OR EXTRACT(YEAR FROM AGE(start_date, dob)) > 75
ORDER BY age_at_hire;



-- ============================================================
-- 7. CHECK PERFORMANCE RATINGS
-- ============================================================

SELECT
    employee_id,
    employee_rating
FROM performance_reviews
WHERE employee_rating < 1
   OR employee_rating > 5;



-- ============================================================
-- 8. CHECK PERFORMANCE RATING DISTRIBUTION
-- ============================================================

SELECT
    employee_rating,
    COUNT(*) AS number_of_reviews
FROM performance_reviews
GROUP BY employee_rating
ORDER BY employee_rating;



-- ============================================================
-- 9. CHECK SURVEY SCORES
-- ============================================================

SELECT
    survey_id,
    employee_id,
    engagement_score,
    satisfaction_score,
    work_life_balance_score
FROM employee_surveys
WHERE engagement_score < 1
   OR engagement_score > 5
   OR satisfaction_score < 1
   OR satisfaction_score > 5
   OR work_life_balance_score < 1
   OR work_life_balance_score > 5;



-- ============================================================
-- 10. CHECK SURVEY SCORE DISTRIBUTION
-- ============================================================

SELECT
    engagement_score,
    COUNT(*) AS number_of_records
FROM employee_surveys
GROUP BY engagement_score
ORDER BY engagement_score;


SELECT
    satisfaction_score,
    COUNT(*) AS number_of_records
FROM employee_surveys
GROUP BY satisfaction_score
ORDER BY satisfaction_score;


SELECT
    work_life_balance_score,
    COUNT(*) AS number_of_records
FROM employee_surveys
GROUP BY work_life_balance_score
ORDER BY work_life_balance_score;



-- ============================================================
-- 11. CHECK MISSING TRAINING INFORMATION
-- ============================================================

SELECT
    training_id,
    employee_id,
    training_program_id,
    training_date,
    training_type,
    training_outcome,
    training_duration_days,
    training_cost
FROM employee_training
WHERE training_program_id IS NULL
   OR training_date IS NULL
   OR training_outcome IS NULL;



-- ============================================================
-- 12. CHECK INVALID TRAINING COSTS
-- ============================================================

SELECT
    training_id,
    employee_id,
    training_cost
FROM employee_training
WHERE training_cost < 0;



-- ============================================================
-- 13. CHECK INVALID TRAINING DURATION
-- ============================================================

SELECT
    training_id,
    employee_id,
    training_duration_days
FROM employee_training
WHERE training_duration_days <= 0;



-- ============================================================
-- 14. CHECK FUTURE TRAINING DATES
-- ============================================================

SELECT
    training_id,
    employee_id,
    training_date
FROM employee_training
WHERE training_date > CURRENT_DATE;



-- ============================================================
-- 15. CHECK DUPLICATE TRAINING RECORDS
-- ============================================================

SELECT
    employee_id,
    training_program_id,
    training_date,
    training_type,
    training_outcome,
    COUNT(*) AS record_count
FROM employee_training
GROUP BY
    employee_id,
    training_program_id,
    training_date,
    training_type,
    training_outcome
HAVING COUNT(*) > 1;



-- ============================================================
-- 16. CHECK DUPLICATE SURVEY RECORDS
-- ============================================================

SELECT
    employee_id,
    survey_date,
    engagement_score,
    satisfaction_score,
    work_life_balance_score,
    COUNT(*) AS record_count
FROM employee_surveys
GROUP BY
    employee_id,
    survey_date,
    engagement_score,
    satisfaction_score,
    work_life_balance_score
HAVING COUNT(*) > 1;



-- ============================================================
-- 17. CHECK DUPLICATE PERFORMANCE REVIEWS
-- ============================================================

SELECT
    employee_id,
    review_date,
    performance_score,
    employee_rating,
    COUNT(*) AS record_count
FROM performance_reviews
GROUP BY
    employee_id,
    review_date,
    performance_score,
    employee_rating
HAVING COUNT(*) > 1;



-- ============================================================
-- 18. CHECK REFERENTIAL INTEGRITY
-- ============================================================

SELECT
    e.employee_id,
    e.department_id
FROM employees e
LEFT JOIN departments d
    ON e.department_id = d.department_id
WHERE d.department_id IS NULL;



-- ============================================================
-- 19. CHECK EMPLOYEE → JOB RELATIONSHIP
-- ============================================================

SELECT
    e.employee_id,
    e.job_id
FROM employees e
LEFT JOIN jobs j
    ON e.job_id = j.job_id
WHERE j.job_id IS NULL;



-- ============================================================
-- 20. CHECK EMPLOYEE → STATE RELATIONSHIP
-- ============================================================

SELECT
    e.employee_id,
    e.state_id
FROM employees e
LEFT JOIN states s
    ON e.state_id = s.state_id
WHERE s.state_id IS NULL;



-- ============================================================
-- 21. CHECK EMPLOYEE → BUSINESS UNIT RELATIONSHIP
-- ============================================================

SELECT
    e.employee_id,
    e.business_unit_id
FROM employees e
LEFT JOIN business_units b
    ON e.business_unit_id = b.business_unit_id
WHERE b.business_unit_id IS NULL;



-- ============================================================
-- 22. CHECK EMPLOYEE → DIVISION RELATIONSHIP
-- ============================================================

SELECT
    e.employee_id,
    e.division_id
FROM employees e
LEFT JOIN divisions d
    ON e.division_id = d.division_id
WHERE d.division_id IS NULL;



-- ============================================================
-- 23. CHECK TRAINING → EMPLOYEE RELATIONSHIP
-- ============================================================

SELECT
    et.training_id,
    et.employee_id
FROM employee_training et
LEFT JOIN employees e
    ON et.employee_id = e.employee_id
WHERE e.employee_id IS NULL;



-- ============================================================
-- 24. CHECK SURVEY → EMPLOYEE RELATIONSHIP
-- ============================================================

SELECT
    es.survey_id,
    es.employee_id
FROM employee_surveys es
LEFT JOIN employees e
    ON es.employee_id = e.employee_id
WHERE e.employee_id IS NULL;



-- ============================================================
-- 25. CHECK PERFORMANCE → EMPLOYEE RELATIONSHIP
-- ============================================================

SELECT
    pr.review_id,
    pr.employee_id
FROM performance_reviews pr
LEFT JOIN employees e
    ON pr.employee_id = e.employee_id
WHERE e.employee_id IS NULL;


-- ============================================================
-- 26. CHECK SPACES IN RAW TEXT COLUMNS (REVIEW)
-- ============================================================
-- Shows why TRIM() is used in the normalization script.

SELECT
    COUNT(*) FILTER (WHERE departmenttype <> TRIM(departmenttype)) AS department_with_spaces,
    COUNT(*) FILTER (WHERE title <> TRIM(title)) AS title_with_spaces,
    COUNT(*) FILTER (WHERE division <> TRIM(division)) AS division_with_spaces
FROM all_info;



-- ============================================================
-- 27. CHECK ROW COUNTS: RAW TABLE VS NORMALIZED TABLES
-- ============================================================
-- All four counts should be equal (no rows lost during normalization).

SELECT
    (SELECT COUNT(*) FROM all_info) AS raw_rows,
    (SELECT COUNT(*) FROM employees) AS employees,
    (SELECT COUNT(*) FROM employee_training) AS training_records,
    (SELECT COUNT(*) FROM employee_surveys) AS survey_records,
    (SELECT COUNT(*) FROM performance_reviews) AS review_records;



-- ============================================================
-- 28. CHECK TRAINING BEFORE START DATE (REVIEW)
-- ============================================================
-- A training that took place before the employee was hired.
-- It may be pre-hire onboarding or a data entry problem.

SELECT
    COUNT(*) AS trainings_before_start_date,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM employee_training), 1) AS percent_of_trainings
FROM employee_training et
JOIN employees e
    ON et.employee_id = e.employee_id
WHERE et.training_date < e.start_date;



-- ============================================================
-- 29. CHECK SURVEY BEFORE START DATE (REVIEW)
-- ============================================================

SELECT
    COUNT(*) AS surveys_before_start_date,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM employee_surveys), 1) AS percent_of_surveys
FROM employee_surveys es
JOIN employees e
    ON es.employee_id = e.employee_id
WHERE es.survey_date < e.start_date;



-- ============================================================
-- 30. CHECK PERFORMANCE SCORE VS RATING (REVIEW)
-- ============================================================
-- Compares the text score with the numeric rating.
-- Conflicting examples: 'Exceeds' with rating 1-2, or
-- 'PIP' / 'Needs Improvement' with rating 4-5.

SELECT
    performance_score,
    employee_rating,
    COUNT(*) AS number_of_records
FROM performance_reviews
GROUP BY performance_score, employee_rating
ORDER BY performance_score, employee_rating;


SELECT COUNT(*) AS conflicting_records
FROM performance_reviews
WHERE (performance_score = 'Exceeds' AND employee_rating <= 2)
   OR (performance_score IN ('PIP', 'Needs Improvement') AND employee_rating >= 4);
