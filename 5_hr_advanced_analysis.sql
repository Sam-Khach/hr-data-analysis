-- ============================================================
-- HR ANALYTICS PROJECT
-- STEP 5: ADVANCED ANALYSIS (CTEs and window functions)
-- ============================================================


-- ============================================================
-- 1. HIRING TREND: hires per year in each department
--    and the change from the previous year (LAG)
-- ============================================================
-- NOTE: the dataset has start dates only, so this shows hiring
-- trends, not total headcount over time.

WITH yearly_hires AS (
    SELECT
        d.department_name,
        EXTRACT(YEAR FROM e.start_date) AS hire_year,
        COUNT(*) AS employees_hired
    FROM employees e
    JOIN departments d
        ON e.department_id = d.department_id
    GROUP BY
        d.department_name,
        EXTRACT(YEAR FROM e.start_date)
)
SELECT
    department_name,
    hire_year,
    employees_hired,
    employees_hired
        - LAG(employees_hired) OVER (
            PARTITION BY department_name
            ORDER BY hire_year
        ) AS change_from_previous_year
FROM yearly_hires
ORDER BY department_name, hire_year;



-- ============================================================
-- 2. WHICH DEPARTMENTS PERFORM ABOVE THE COMPANY-WIDE AVERAGE?
-- ============================================================

WITH department_performance AS (
    SELECT
        d.department_name,
        AVG(pr.employee_rating) AS avg_department_rating
    FROM performance_reviews pr
    JOIN employees e
        ON pr.employee_id = e.employee_id
    JOIN departments d
        ON e.department_id = d.department_id
    GROUP BY d.department_name
),
company_average AS (
    SELECT
        AVG(employee_rating) AS avg_company_rating
    FROM performance_reviews
)
SELECT
    dp.department_name,
    ROUND(dp.avg_department_rating, 2) AS avg_department_rating,
    ROUND(ca.avg_company_rating, 2) AS avg_company_rating
FROM department_performance dp
CROSS JOIN company_average ca
WHERE dp.avg_department_rating > ca.avg_company_rating
ORDER BY dp.avg_department_rating DESC;



-- ============================================================
-- 3. DEPARTMENT PERFORMANCE VS COMPANY PERFORMANCE
-- ============================================================

WITH department_performance AS (
    SELECT
        d.department_name,
        AVG(pr.employee_rating) AS department_average
    FROM employees e
    JOIN departments d
        ON e.department_id = d.department_id
    JOIN performance_reviews pr
        ON e.employee_id = pr.employee_id
    GROUP BY d.department_name
)
SELECT
    department_name,
    ROUND(department_average, 2) AS department_average,
    ROUND(
        (
            department_average -
            (SELECT AVG(employee_rating) FROM performance_reviews)
        )::NUMERIC,
        2
    ) AS difference_from_company_average
FROM department_performance
ORDER BY difference_from_company_average DESC;



-- ============================================================
-- 4. WHICH EMPLOYEES PERFORM ABOVE THEIR DEPARTMENT AVERAGE?
-- ============================================================

WITH employee_performance AS (
    SELECT
        e.employee_id,
        d.department_name,
        pr.employee_rating,
        AVG(pr.employee_rating) OVER (PARTITION BY d.department_id) AS department_avg_rating
    FROM performance_reviews pr
    JOIN employees e
        ON pr.employee_id = e.employee_id
    JOIN departments d
        ON e.department_id = d.department_id
)
SELECT
    employee_id,
    department_name,
    employee_rating,
    ROUND(department_avg_rating, 2) AS department_avg_rating
FROM employee_performance
WHERE employee_rating > department_avg_rating
ORDER BY department_name, employee_rating DESC, employee_id;



-- ============================================================
-- 5. PERFORMANCE RANK WITHIN EACH DEPARTMENT (RANK)
-- ============================================================
-- RANK gives the same rank to equal ratings, so many employees
-- share rank 1.

SELECT
    e.employee_id,
    d.department_name,
    j.title,
    pr.employee_rating,
    RANK() OVER (
        PARTITION BY d.department_name
        ORDER BY pr.employee_rating DESC
    ) AS department_rank
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
JOIN jobs j
    ON e.job_id = j.job_id
JOIN performance_reviews pr
    ON e.employee_id = pr.employee_id
ORDER BY
    department_name,
    department_rank,
    e.employee_id;



-- ============================================================
-- 6. TOP 3 EMPLOYEES IN EACH DEPARTMENT (ROW_NUMBER)
-- ============================================================
-- ROW_NUMBER gives exactly 3 rows per department. Ties are broken
-- by employee_id so the result is repeatable.

WITH ranked_employees AS (
    SELECT
        e.employee_id,
        d.department_name,
        j.title,
        pr.employee_rating,
        ROW_NUMBER() OVER (
            PARTITION BY d.department_name
            ORDER BY pr.employee_rating DESC, e.employee_id
        ) AS department_rank
    FROM employees e
    JOIN departments d
        ON e.department_id = d.department_id
    JOIN jobs j
        ON e.job_id = j.job_id
    JOIN performance_reviews pr
        ON e.employee_id = pr.employee_id
)
SELECT
    employee_id,
    department_name,
    title,
    employee_rating,
    department_rank
FROM ranked_employees
WHERE department_rank <= 3
ORDER BY
    department_name,
    department_rank;



-- ============================================================
-- 7. EMPLOYEE TRAINING COST VS DEPARTMENT AVERAGE
-- ============================================================

WITH employee_training_cost AS (
    SELECT
        e.employee_id,
        d.department_name,
        SUM(et.training_cost) AS total_training_cost,
        AVG(SUM(et.training_cost)) OVER (
            PARTITION BY d.department_name
        ) AS department_average_training_cost
    FROM employees e
    JOIN departments d
        ON e.department_id = d.department_id
    JOIN employee_training et
        ON e.employee_id = et.employee_id
    GROUP BY
        e.employee_id,
        d.department_name
)
SELECT
    employee_id,
    department_name,
    ROUND(total_training_cost, 2) AS total_training_cost,
    ROUND(department_average_training_cost, 2) AS department_average_training_cost
FROM employee_training_cost
WHERE total_training_cost > department_average_training_cost
ORDER BY
    department_name,
    total_training_cost DESC,
    employee_id;



-- ============================================================
-- 8. TRAINING OUTCOME VS PERFORMANCE AND EXPERIENCE
-- ============================================================
-- Does the result of the training relate to rating and engagement?
-- (Each employee has one training record, so results are compared
-- by training outcome.)

SELECT
    et.training_outcome,
    COUNT(*) AS employee_count,
    ROUND(AVG(pr.employee_rating), 2) AS average_rating,
    ROUND(AVG(es.engagement_score), 2) AS average_engagement,
    ROUND(AVG(et.training_cost), 2) AS average_training_cost
FROM employee_training et
JOIN performance_reviews pr
    ON et.employee_id = pr.employee_id
JOIN employee_surveys es
    ON et.employee_id = es.employee_id
GROUP BY et.training_outcome
ORDER BY average_rating DESC;



-- ============================================================
-- 9. ACTIVE VS TERMINATED EMPLOYEES: EXPERIENCE AND PERFORMANCE
-- ============================================================

SELECT
    e.employee_status,
    COUNT(*) AS employee_count,
    ROUND(AVG(es.engagement_score), 2) AS average_engagement,
    ROUND(AVG(es.satisfaction_score), 2) AS average_satisfaction,
    ROUND(AVG(es.work_life_balance_score), 2) AS average_work_life_balance,
    ROUND(AVG(pr.employee_rating), 2) AS average_rating
FROM employees e
JOIN employee_surveys es
    ON e.employee_id = es.employee_id
JOIN performance_reviews pr
    ON e.employee_id = pr.employee_id
GROUP BY e.employee_status
ORDER BY employee_count DESC;



-- ============================================================
-- 10. ATTRITION (TERMINATION) RATE BY DEPARTMENT
-- ============================================================

SELECT
    d.department_name,
    COUNT(*) AS total_employees,
    COUNT(*) FILTER (WHERE e.employee_status = 'Terminated') AS terminated_employees,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE e.employee_status = 'Terminated') / COUNT(*),
        2
    ) AS attrition_rate_percent
FROM employees e
JOIN departments d
    ON e.department_id = d.department_id
GROUP BY d.department_name
ORDER BY attrition_rate_percent DESC;
