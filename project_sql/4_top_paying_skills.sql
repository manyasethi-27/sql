SELECT s.skills, ROUND(AVG(j.salary_year_avg), 0) AS avg_salary
FROM job_postings_fact j
INNER JOIN skills_job_dim sj
ON j.job_id = sj.job_id
INNER JOIN skills_dim s
ON s.skill_id = sj.skill_id
WHERE job_title_short = 'Data Analyst'
AND salary_year_avg IS NOT NULL 
GROUP BY s.skills
ORDER BY avg_salary DESC
LIMIT 25;