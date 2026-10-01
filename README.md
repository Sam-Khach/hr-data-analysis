# HR Data Analysis (PostgreSQL)

This project is based on an HR dataset that contains several types of information about employees: organizational structure, employment details, training, employee experience (surveys) and performance. The data was loaded into **PostgreSQL**, normalized into a relational database, checked for quality and analyzed with SQL to answer practical business questions.

The data can be used to analyze:

- Workforce distribution across departments, states and job roles
- Hiring patterns and employee demographics
- Employee performance and rating differences
- Training participation, costs, outcomes and duration
- Employee engagement, satisfaction and work-life balance
- Relationships between training, employee experience and performance

## Tools

- **PostgreSQL** – database design, data quality checks, analysis
- **SQL** – joins, aggregations, CTEs, window functions (`RANK`, `ROW_NUMBER`, `LAG`, `AVG() OVER`)
- **Power BI / Excel** – reporting and visualization

## Dataset

- **File:** `data/Cleaned_HR_Data_Analysis.csv`
- **Size:** 2,845 employees, 28 columns (one row per employee)
- The file contains no names or contact details, only employee IDs.

## Project steps

### 1. Raw data preparation
The project started with the original HR dataset in CSV format. It contained employee, organizational, training, survey and performance information in a single table. The CSV was imported into PostgreSQL as the `all_info` table, which preserves the original data before any transformation. Dates are stored as text at this stage because the file mixes two date formats (`20-Sep-19` and `07-10-1969`); they are converted with an explicit format in the next step.

### 2. Database normalization
The raw table was split into related tables:

- **Lookup tables:** `departments`, `divisions`, `jobs`, `states`, `business_units`, `training_programs`
- **Main table:** `employees`
- **Event tables:** `employee_training`, `employee_surveys`, `performance_reviews`

Text values with extra spaces (for example the department `Production` and some job titles) are cleaned with `TRIM`.

### 3. Data quality checks
After normalization, 30 checks verify that the data is reliable and suitable for analysis:

- Missing values in important employee attributes and relationships
- Duplicate employee and transaction records
- Invalid or suspicious dates
- Invalid performance and survey scores
- Missing or invalid training information, negative or unusual costs and durations
- Referential integrity between related tables
- Row counts: the raw table and all normalized tables contain the same 2,845 records

### 4. HR data analysis
The analysis is divided into four main areas:

- **Workforce analysis** – employees by department, state, business unit and status; hiring trend per year
- **Performance analysis** – ratings by department, performance categories, top performers, employees above their department average, rank within department
- **Training analysis** – popular programs, costs, outcomes, training by department, outcome vs performance
- **Employee experience analysis** – engagement, satisfaction and work-life balance by department, job title and division; active vs terminated employees; attrition rate by department

## Project structure

| File | Purpose |
|---|---|
| `1_create_raw_table.sql` | Creates the raw table `all_info` and shows how to import the CSV |
| `2_normalizing_db.sql` | Normalizes the raw table into 10 related tables |
| `3_quality_check.sql` | 30 data quality checks |
| `4_hr_analysis.sql` | Core HR analysis |
| `5_hr_advanced_analysis.sql` | Advanced analysis with CTEs and window functions |
| `data/Cleaned_HR_Data_Analysis.csv` | Source dataset |

## How to run

1. Create a PostgreSQL database.
2. Run `1_create_raw_table.sql`.
3. Import `data/Cleaned_HR_Data_Analysis.csv` into the `all_info` table (pgAdmin: right-click the table → Import/Export Data, CSV, header ON; or use the `\copy` command written in the script). Check that the table has 2,845 rows.
4. Run the scripts in order: `2_normalizing_db.sql` → `3_quality_check.sql` → `4_hr_analysis.sql` → `5_hr_advanced_analysis.sql`.

## Key findings

**Workforce**
- 2,845 employees in 6 departments. Production is the largest (1,910 employees), followed by IT/IS (409) and Sales (311).
- 2,458 employees are active and 387 (13.6%) are terminated.
- Attrition differs a lot between departments: Software Engineering 17.9% and Production 16.9%, compared with IT/IS 8.3%, Sales 3.2% and Admin Offices 1.3%. No one has left the Executive Office (24 employees).

**Performance**
- The average rating is 2.97 out of 5, and most employees (1,451) are rated 3.
- Department averages are close to each other (2.79 to 3.03). Admin Offices is the highest and Executive Office the lowest, but Executive Office has only 24 employees.

**Training**
- Total training cost is 1,591,148.63 (average 559.28 per training record).
- Communication Skills is the most attended program (633 records); program costs per record are similar (544 to 570).
- Training outcomes are split almost evenly: Completed 737, Incomplete 731, Passed 709, Failed 668. Average ratings are almost the same for all outcomes (2.94 to 3.01).

**Employee experience**
- Average scores are close to 3 out of 5 for engagement (2.94), satisfaction (3.03) and work-life balance (2.99).
- Admin Offices has the lowest satisfaction (2.51) even though it has the highest average rating (3.03).
- Executive Office and Admin Offices report the best work-life balance (3.29 and 3.20).

## Data quality findings

The checks found no missing values, duplicate records, invalid scores or broken relationships. They also showed a few things to be aware of when reading the results:

- **Training before hire:** 273 training records (9.6%) have a date earlier than the employee's start date, and 272 survey records (9.6%) too. This may be pre-hire onboarding or a data entry problem.
- **Score vs rating:** the text performance score and the numeric rating do not always agree. For example, 144 records are either "Exceeds" with a rating of 1–2, or "PIP" / "Needs Improvement" with a rating of 4–5.
- **Age at hire:** 182 employees were hired at an age under 18 or over 75.
- **Location:** 2,523 of 2,845 employees (89%) are in one state (MA), so state-level comparisons are limited.
- **Small groups:** job titles and divisions with only a few survey records should not be compared with larger groups.

## Author

**Samvel Khachatryan** – Business & Data Analyst
[GitHub](https://github.com/Sam-Khach) · sam.khachatryan99@mail.ru
