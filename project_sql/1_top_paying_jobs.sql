SELECT 
    name AS company_name, job_id, job_title, 
    job_location, job_schedule_type,
    salary_year_avg, job_posted_date
FROM 
    job_postings_fact j
LEFT JOIN company_dim c ON j.company_id = c.company_id
WHERE 
    job_title_short = 'Data Analyst' 
    AND salary_year_avg IS NOT NULL
    AND job_location = 'Anywhere'
ORDER BY 
    salary_year_avg DESC
LIMIT 10;