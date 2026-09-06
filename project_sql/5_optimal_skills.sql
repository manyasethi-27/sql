WITH skills_demand AS (
    SELECT s.skill_id, s.skills, COUNT(sj.job_id) AS demand_count
    FROM job_postings_fact j
    INNER JOIN skills_job_dim sj
    ON j.job_id = sj.job_id
    INNER JOIN skills_dim s
    ON s.skill_id = sj.skill_id
    WHERE job_title_short = 'Data Analyst'
    AND job_work_from_home = TRUE
    AND salary_year_avg IS NOT NULL
    GROUP BY s.skill_id
), average_salary AS (
    SELECT s.skill_id, s.skills, ROUND(AVG(j.salary_year_avg), 0) AS avg_salary
    FROM job_postings_fact j
    INNER JOIN skills_job_dim sj
    ON j.job_id = sj.job_id
    INNER JOIN skills_dim s
    ON s.skill_id = sj.skill_id
    WHERE job_title_short = 'Data Analyst'
    AND salary_year_avg IS NOT NULL 
    AND job_work_from_home = TRUE
    GROUP BY s.skill_id
)

SELECT sd.skill_id,
sd.skills,
demand_count,
avg_salary
FROM skills_demand sd 
INNER JOIN average_salary a
ON sd.skill_id = a.skill_id
ORDER BY demand_count DESC,
avg_salary DESC
LIMIT 25;

--rewriting the same query more concisely--
SELECT 
    s.skill_id, 
    s.skills, 
    COUNT(sj.job_id) AS demand_count,
    ROUND(AVG(j.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact j
INNER JOIN skills_job_dim sj ON j.job_id = sj.job_id
INNER JOIN skills_dim s ON s.skill_id = sj.skill_id
WHERE 
    job_title_short = 'Data Analyst'
    AND job_work_from_home = TRUE
    AND salary_year_avg IS NOT NULL
GROUP BY 
    s.skill_id
HAVING
    COUNT(sj.job_id) > 10
ORDER BY 
    avg_salary DESC,
    demand_count DESC
LIMIT 25;