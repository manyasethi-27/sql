SELECT s.skills, COUNT(sj.job_id) AS demand_count
FROM job_postings_fact j
INNER JOIN skills_job_dim sj
ON j.job_id = sj.job_id
INNER JOIN skills_dim s
ON s.skill_id = sj.skill_id
WHERE job_title_short = 'Data Analyst'
AND job_work_from_home = TRUE
GROUP BY s.skills
ORDER BY demand_count DESC
LIMIT 5;