WITH top_paying_jobs AS (
    SELECT 
        job_id, 
        job_title, 
        salary_year_avg,
        name AS company_name
    FROM 
        job_postings_fact j
    LEFT JOIN company_dim c
    ON j.company_id = c.company_id
    WHERE 
        job_title_short = 'Data Analyst' AND salary_year_avg IS NOT NULL AND job_location = 'Anywhere'
    ORDER BY 
        salary_year_avg DESC
    LIMIT 10
)
SELECT j.*, s.skills 
FROM top_paying_jobs j
INNER JOIN skills_job_dim sj
ON j.job_id = sj.job_id
INNER JOIN skills_dim s
ON s.skill_id = sj.skill_id
ORDER BY j.salary_year_avg DESC;
