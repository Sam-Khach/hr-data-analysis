-- ============================================================
-- HR ANALYTICS PROJECT
-- STEP 4: CORE HR ANALYSIS
-- ============================================================
-- Four areas: Workforce, Performance, Training, Employee Experience
-- ============================================================


-- ============================================================
-- EMPLOYEE COUNT BY DEPARTMENT
-- ============================================================

SELECT
    d.department_name,
    COUNT(e.employee_id) AS employee_count
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY employee_count DESC;



-- ============================================================
-- EMPLOYEE COUNT BY STATE
-- ============================================================

SELECT
    s.state_code,
    COUNT(e.employee_id) AS employee_count
FROM employees e
JOIN states s
    ON e.state_id = s.state_id
GROUP BY s.state_code
ORDER BY employee_count DESC;



-- ============================================================
-- EMPLOYEE DISTRIBUTION BY BUSINESS UNIT
-- ============================================================

SELECT
    b.business_unit_code,
    COUNT(e.employee_id) AS employee_count
FROM employees e
JOIN business_units b
    ON e.business_unit_id = b.business_unit_id
GROUP BY b.business_unit_code
ORDER BY employee_count DESC;

-- ============================================================
-- ACTIVE VS TERMINATED EMPLOYEES
-- ============================================================

SELECT
    employee_status,
    COUNT(*) AS employee_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 1) AS percent_of_employees
FROM employees
GROUP BY employee_status
ORDER BY employee_count DESC;


-- ============================================================
-- AVERAGE PERFORMANCE RATING BY DEPARTMENT
-- ============================================================

SELECT
    d.department_name,
    ROUND(AVG(pr.employee_rating), 2) AS average_rating,
    COUNT(pr.employee_id) AS employees_reviewed
FROM performance_reviews pr
JOIN employees e
    ON pr.employee_id = e.employee_id
JOIN departments d
    ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY average_rating DESC;



-- ============================================================
-- PERFORMANCE DISTRIBUTION
-- ============================================================

SELECT
    pr.employee_rating,
    COUNT(*) AS number_of_employees
FROM performance_reviews pr
GROUP BY pr.employee_rating
ORDER BY pr.employee_rating;



-- ============================================================
-- PERFORMANCE CATEGORIES
-- ============================================================

SELECT
    pr.employee_rating,
    CASE
        WHEN pr.employee_rating >= 4 THEN 'Excellent'
        WHEN pr.employee_rating >= 3 THEN 'Good'
        WHEN pr.employee_rating >= 2 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS performance_category,
    COUNT(*) AS employee_count
FROM performance_reviews pr

GROUP BY
    pr.employee_rating,
    CASE
        WHEN pr.employee_rating >= 4 THEN 'Excellent'
        WHEN pr.employee_rating >= 3 THEN 'Good'
        WHEN pr.employee_rating >= 2 THEN 'Average'
        ELSE 'Needs Improvement'
    END
ORDER BY pr.employee_rating;


-- ============================================================
-- TOP-PERFORMING EMPLOYEES
-- ============================================================
-- NOTE: many employees share the top rating, so employee_id is used
-- as a tie-breaker to make the result repeatable.

SELECT
    e.employee_id,
    d.department_name,
    j.title,
    pr.employee_rating
FROM employees e
JOIN performance_reviews pr
    ON e.employee_id = pr.employee_id
JOIN departments d
    ON e.department_id = d.department_id
JOIN jobs j
    ON e.job_id = j.job_id
ORDER BY pr.employee_rating DESC, e.employee_id
LIMIT 10;



-- ============================================================
-- EMPLOYEES ABOVE THEIR DEPARTMENT AVERAGE
-- ============================================================

SELECT *
FROM (
    SELECT
        e.employee_id,
        d.department_name,
        j.title,
        pr.employee_rating,
        AVG(pr.employee_rating)
            OVER (
                PARTITION BY d.department_name
            ) AS department_average_rating
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    JOIN jobs j ON e.job_id = j.job_id
    JOIN performance_reviews pr ON e.employee_id = pr.employee_id
) AS employee_performance
WHERE employee_rating > department_average_rating
ORDER BY department_name, employee_rating DESC;


-- ============================================================
-- MOST POPULAR TRAINING PROGRAMS
-- ============================================================

SELECT
    tp.program_name,
    COUNT(et.training_id) AS participation_count
FROM employee_training et
JOIN training_programs tp
    ON et.training_program_id = tp.training_program_id
GROUP BY tp.program_name
ORDER BY participation_count DESC;



-- ============================================================
-- TOTAL TRAINING COST
-- ============================================================

SELECT
    ROUND(SUM(training_cost), 2) AS total_training_cost
FROM employee_training;


-- ============================================================
-- AVERAGE TRAINING COST
-- ============================================================

SELECT
    ROUND(AVG(training_cost), 2) AS average_training_cost
FROM employee_training;


-- ============================================================
-- TRAINING COST BY PROGRAM
-- ============================================================

SELECT
    tp.program_name,
    COUNT(et.training_id) AS training_count,
    ROUND(SUM(et.training_cost), 2) AS total_cost,
    ROUND(AVG(et.training_cost), 2) AS average_cost
FROM employee_training et
JOIN training_programs tp
    ON et.training_program_id = tp.training_program_id
GROUP BY tp.program_name
ORDER BY total_cost DESC;



-- ============================================================
-- TRAINING OUTCOMES
-- ============================================================

SELECT
    training_outcome,
    COUNT(*) AS number_of_training_records
FROM employee_training
GROUP BY training_outcome
ORDER BY number_of_training_records DESC;


-- ============================================================
-- TRAINING OUTCOMES BY PROGRAM
-- ============================================================

SELECT
    tp.program_name,
    et.training_outcome,
    COUNT(*) AS outcome_count
FROM employee_training et
JOIN training_programs tp
    ON et.training_program_id = tp.training_program_id
GROUP BY
    tp.program_name,
    et.training_outcome
ORDER BY
    tp.program_name,
    outcome_count DESC;


-- ============================================================
-- TRAINING BY DEPARTMENT
-- ============================================================

SELECT
    d.department_name,
    COUNT(et.training_id) AS training_records,
    ROUND(SUM(et.training_cost), 2) AS total_training_cost,
    ROUND(AVG(et.training_duration_days), 2)
        AS average_training_duration
FROM employee_training et
JOIN employees e
    ON et.employee_id = e.employee_id
JOIN departments d
    ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY training_records DESC;


-- ============================================================
-- WORK-LIFE BALANCE BY DEPARTMENT
-- ============================================================

SELECT
    d.department_name,
    ROUND(AVG(es.work_life_balance_score), 2)
        AS average_work_life_balance,
    COUNT(es.survey_id) AS survey_count
FROM employee_surveys es
JOIN employees e
    ON es.employee_id = e.employee_id
JOIN departments d
    ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY average_work_life_balance DESC;


-- ============================================================
-- SATISFACTION BY DEPARTMENT
-- ============================================================

SELECT
    d.department_name,
    ROUND(AVG(es.satisfaction_score), 2)
        AS average_satisfaction,
    COUNT(es.survey_id) AS survey_count
FROM employee_surveys es
JOIN employees e
    ON es.employee_id = e.employee_id
JOIN departments d
    ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY average_satisfaction DESC;


-- ============================================================
-- EMPLOYEE EXPERIENCE BY JOB
-- ============================================================

SELECT
    j.title,
    ROUND(AVG(es.engagement_score), 2)
        AS average_engagement,
    ROUND(AVG(es.satisfaction_score), 2)
        AS average_satisfaction,
    ROUND(AVG(es.work_life_balance_score), 2)
        AS average_work_life_balance,
    COUNT(es.survey_id) AS survey_count
FROM employee_surveys es
JOIN employees e
    ON es.employee_id = e.employee_id
JOIN jobs j
    ON e.job_id = j.job_id
GROUP BY j.title
ORDER BY average_engagement DESC;


-- ============================================================
-- EMPLOYEE EXPERIENCE BY DIVISION
-- ============================================================
-- Division names repeat across departments, so results are grouped
-- by division name (all departments combined).

SELECT
    div.division_name,
    ROUND(AVG(es.engagement_score), 2)
        AS average_engagement,
    ROUND(AVG(es.satisfaction_score), 2)
        AS average_satisfaction,
    ROUND(AVG(es.work_life_balance_score), 2)
        AS average_work_life_balance,
    COUNT(es.survey_id) AS survey_count
FROM employee_surveys es
JOIN employees e
    ON es.employee_id = e.employee_id
JOIN divisions div
    ON e.division_id = div.division_id
GROUP BY div.division_name
ORDER BY average_engagement DESC;
