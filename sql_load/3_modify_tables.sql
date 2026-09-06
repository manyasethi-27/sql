/* ⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️⚠️
Database Load Issues (follow if receiving permission denied when running SQL code below)

NOTE: If you are having issues with permissions. And you get error: 

'could not open file "[your file path]\job_postings_fact.csv" for reading: Permission denied.'

1. Open pgAdmin
2. In Object Explorer (left-hand pane), navigate to `sql_course` database
3. Right-click `sql_course` and select `PSQL Tool`
    - This opens a terminal window to write the following code
4. Get the absolute file path of your csv files
    1. Find path by right-clicking a CSV file in VS Code and selecting “Copy Path”
5. Paste the following into `PSQL Tool`, (with the CORRECT file path)

\copy company_dim FROM '[Insert File Path]/company_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_dim FROM '[Insert File Path]/skills_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy job_postings_fact FROM '[Insert File Path]/job_postings_fact.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

\copy skills_job_dim FROM '[Insert File Path]/skills_job_dim.csv' WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

*/

-- NOTE: This has been updated from the video to fix issues with encoding

COPY company_dim
FROM 'C:\Users\manya\OneDrive\Desktop\coding\sql\csv_files\company_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_dim
FROM 'C:\Users\manya\OneDrive\Desktop\coding\sql\csv_files\skills_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY job_postings_fact
FROM 'C:\Users\manya\OneDrive\Desktop\coding\sql\csv_files\job_postings_fact.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

COPY skills_job_dim
FROM 'C:\Users\manya\OneDrive\Desktop\coding\sql\csv_files\skills_job_dim.csv'
WITH (FORMAT csv, HEADER true, DELIMITER ',', ENCODING 'UTF8');

SELECT * FROM job_postings_fact
LIMIT 100;

SELECT '2023-02-19'::DATE,
'123'::INTEGER,
'true'::BOOLEAN,
'3.14'::REAL;

SELECT job_title_short AS title,
job_location AS location,
job_posted_date::DATE AS date
FROM job_postings_fact
LIMIT 50;

SELECT job_title_short AS title,
job_location AS location,
job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'EST' AS date
FROM job_postings_fact
LIMIT 50;

SELECT job_title_short AS title,
job_location AS location,
job_posted_date::DATE AS date,
EXTRACT(MONTH FROM job_posted_date) AS date_month,
EXTRACT(YEAR FROM job_posted_date) AS date_year
FROM job_postings_fact
LIMIT 5;

SELECT EXTRACT(MONTH FROM job_posted_date) AS date_month,
COUNT(job_id) AS job_count
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY date_month
ORDER BY job_count DESC;

SELECT job_schedule_type,
       AVG(salary_year_avg) AS avg_yearly_salary,
       AVG(salary_hour_avg) AS avg_hourly_salary
FROM job_postings_fact
WHERE job_posted_date > '2023-06-01'
GROUP BY job_schedule_type;

SELECT EXTRACT(MONTH FROM job_posted_date AT TIME ZONE 'UTC' AT TIME ZONE 'America/New_York') AS month,
       COUNT(*) AS job_postings
FROM job_postings_fact
WHERE job_posted_date >= '2023-01-01'
  AND job_posted_date < '2024-01-01'
GROUP BY month
ORDER BY month;

SELECT c.name
FROM company_dim c
JOIN job_postings_fact j
ON c.company_id = j.company_id
WHERE j.job_health_insurance = TRUE
  AND EXTRACT(QUARTER FROM j.job_posted_date) = 2;

CREATE TABLE jan23_jobs AS 
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 1;
CREATE TABLE feb23_jobs AS 
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 2;
CREATE TABLE mar23_jobs AS 
SELECT *
FROM job_postings_fact
WHERE EXTRACT(MONTH FROM job_posted_date) = 3;

SELECT job_posted_date
FROM mar23_jobs;

SELECT 
    COUNT(job_id) AS number_of_jobs,
    CASE
        WHEN job_location = 'Anywhere' THEN 'Remote'
        WHEN job_location = 'New York, NY' THEN 'Local'
        ELSE 'Onsite'
    END AS location_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
GROUP BY location_category;

SELECT
    job_title,
    salary_year_avg,
    CASE
        WHEN salary_year_avg >= 100000 THEN 'High'
        WHEN salary_year_avg >= 70000 THEN 'Standard'
        ELSE 'Low'
    END AS salary_category
FROM job_postings_fact
WHERE job_title_short = 'Data Analyst'
AND salary_year_avg IS NOT NULL
ORDER BY salary_year_avg DESC;

SELECT *
FROM (
    SELECT *
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
) AS januray_jobs;

WITH january_jobs AS (
    SELECT * 
    FROM job_postings_fact
    WHERE EXTRACT(MONTH FROM job_posted_date) = 1
)
SELECT * 
FROM january_jobs;

SELECT 
    company_id,
    name AS company_name
FROM company_dim
WHERE company_id IN (
    SELECT
        company_id
    FROM
        job_postings_fact
    WHERE
        job_no_degree_mention = true
) ORDER BY company_id;

WITH company_job_count AS (
    SELECT company_id,
    COUNT(*) AS total_jobs
    FROM job_postings_fact
    GROUP BY company_id
)
SELECT c1.name, c2.total_jobs
FROM company_dim c1
LEFT JOIN company_job_count c2
ON c1.company_id = c2.company_id
ORDER BY total_jobs DESC;

WITH skill_name_count AS (
    SELECT skill_id, COUNT(*) AS skill_count
    FROM skills_job_dim
    GROUP BY skill_id
)
SELECT s1.skills, s2.skill_count
FROM skills_dim s1
INNER JOIN skill_name_count s2
ON s1.skill_id = s2.skill_id
ORDER BY s2.skill_count DESC
LIMIT 5;

SELECT 
    s.skills
FROM skills_dim AS s
WHERE s.skill_id IN (
    SELECT skill_id
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY COUNT(*) DESC
    LIMIT 5
);

SELECT 
    s.skills,
    sj.skill_count
FROM skills_dim AS s
JOIN (
    SELECT 
        skill_id,
        COUNT(*) AS skill_count
    FROM skills_job_dim
    GROUP BY skill_id
    ORDER BY skill_count DESC
    LIMIT 5
) AS sj
ON s.skill_id = sj.skill_id
ORDER BY sj.skill_count DESC;

SELECT c.company_id, c.name, cj.job_count,
CASE
    WHEN cj.job_count < 10 THEN 'Small'
    WHEN cj.job_count BETWEEN 10 AND 50 THEN 'Medium'
    ELSE 'Large'
END AS company_size
FROM company_dim c
JOIN (
    SELECT company_id,
    COUNT(*) AS job_count
    FROM job_postings_fact
    GROUP BY company_id
) AS cj
ON c.company_id = cj.company_id;

WITH remote_jobs AS (
    SELECT sj.skill_id, COUNT(*) AS skill_count
    FROM job_postings_fact j
    INNER JOIN skills_job_dim sj
    ON j.job_id = sj.job_id
    WHERE j.job_work_from_home = True
    AND j.job_title_short = 'Data Analyst'
    GROUP BY skill_id
)
SELECT r.skill_id, s.skills, r.skill_count
FROM remote_jobs r
INNER JOIN skills_dim s
ON r.skill_id = s.skill_id
ORDER BY skill_count DESC
LIMIT 5;

SELECT job_title_short,
company_id,
job_location
FROM jan23_jobs
UNION ALL
SELECT job_title_short,
company_id,
job_location
FROM feb23_jobs
UNION ALL
SELECT job_title_short,
company_id,
job_location
FROM mar23_jobs

SELECT j.job_id, s.skills, s.type
FROM job_postings_fact j
JOIN skills_job_dim sj
ON j.job_id = sj.job_id
JOIN skills_dim s
ON sj.skill_id = s.skill_id
WHERE EXTRACT(QUARTER FROM job_posted_date) = 1
AND j.salary_year_avg > 70000

WITH q1_jobs AS (
    SELECT *
    FROM jan23_jobs
    UNION ALL
    SELECT *
    FROM feb23_jobs
    UNION ALL
    SELECT *
    FROM mar23_jobs
)
SELECT
    q.job_id,
    s.skills,
    s.type
FROM q1_jobs AS q
LEFT JOIN skills_job_dim AS sj
    ON q.job_id = sj.job_id
LEFT JOIN skills_dim AS s
    ON sj.skill_id = s.skill_id
WHERE q.salary_year_avg > 70000;


WITH q1_jobs AS (
    SELECT * 
    FROM jan23_jobs
    UNION ALL
    SELECT *
    FROM feb23_jobs
    UNION ALL
    SELECT *
    FROM mar23_jobs
)
SELECT j.job_id,
s.skills, s.type
FROM q1_jobs j
LEFT JOIN skills_job_dim sj
ON j.job_id = sj.job_id
LEFT JOIN skills_dim s
ON s.skill_id = sj.skill_id
WHERE j.salary_year_avg > 70000;
