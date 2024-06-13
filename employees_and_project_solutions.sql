
-- 1. Find the names of employees who are currently working on 
-- projects in the IT department.


SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name
FROM employees e
JOIN projects p
ON e.employee_id = p.employee_id
WHERE p.project_status = 'Ongoing'
AND e.department = 'IT';



-- 2. List the project names and the corresponding start dates 
-- for all projects that are currently ongoing.



SELECT DISTINCT pd.project_name, p.start_date, 
p.project_status FROM project_departments pd
LEFT JOIN projects p
ON pd.project_id = p.project_id
WHERE p.project_status = 'Ongoing';


-- 3. Retrieve the names and ages of employees who have 
-- resigned after working for more than 3 years.



SELECT employee_id, first_name, last_name, date_joined, date_resigned, 
DATEDIFF(YEAR, date_joined, date_resigned) AS years_with_company
FROM employees
WHERE DATEDIFF(YEAR, date_joined, date_resigned) > 3  -- ensures they have worked more than 3 years
AND date_resigned < GETDATE();  -- ensures they have resigned




-- 4. Find the total salary paid to (active) employees in the 'Finance' department.



SELECT SUM(salary) AS total_finance_dept_salary
FROM employees
WHERE department = 'Finance'
AND date_resigned > GETDATE();




-- 5. List the project names and employee names for projects that started in 2024.


SELECT pd.project_name, CONCAT(e.first_name, ' ', e.last_name) AS full_name
FROM project_departments pd
JOIN projects p
ON pd.project_id = p.project_id
JOIN employees e
ON p.employee_id = e.employee_id
WHERE p.start_date >= '2024-01-01';




-- 6. Find the names of employees who have worked on more than 
-- one project, along with the count of distinct projects 
-- they have been involved in.


SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name,
	   STRING_AGG(pd.project_name, '  |  ') AS projects_worked_on,
	   COUNT(p.project_id) AS no_of_projects
FROM employees e
JOIN projects p
ON e.employee_id = p.employee_id
JOIN project_departments pd
ON p.project_id = pd.project_id
GROUP BY e.first_name, e.last_name
HAVING COUNT(p.project_id) > 1
ORDER BY no_of_projects DESC;




-- 7. Find the (active) employees who are currently working in 
-- the 'Operations' department and have a performance level of 'Exceeds'.



SELECT *
FROM employees
WHERE department = 'Operations' AND performance_level = 'Exceeds'
AND date_resigned > GETDATE();



-- 8. Retrieve the names of employees who joined 
-- before 2023 and are working on ongoing projects.


SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name,
e.date_joined,
p.project_status
FROM employees e
JOIN projects p
ON e.employee_id = p.employee_id
JOIN project_departments pd
ON p.project_id = pd.project_id
WHERE p.project_status = 'Ongoing'
AND date_joined < '2023-01-01';



-- 9. Retrieve the names of employees who share the 
-- same last name as another employee, along with their respective departments.



SELECT DISTINCT e1.first_name, e1.last_name
FROM employees e1
INNER JOIN employees e2
ON e1.last_name = e2.last_name
GROUP BY e1.first_name, e1.last_name, e2.first_name
HAVING COUNT(DISTINCT CASE WHEN e1.employee_id <> e2.employee_id THEN e2.employee_id END) > 0;




-- 10. Write an SQL query to find (active) employees whose 
-- performance level is higher than the average performance level 
-- in their respective departments.  


-- Step 1: Calculate the numerical representation of performance levels
WITH performance_rank AS (
    SELECT 
        employee_id, 
        department, 
		date_resigned,
        CASE performance_level
            WHEN 'Outstanding' THEN 5
            WHEN 'Exceeds' THEN 4
            WHEN 'Meets' THEN 3
            WHEN 'Needs Improvement' THEN 2
            WHEN 'Below' THEN 1
        END AS performance_Score
    FROM employees
    WHERE date_resigned > GETDATE()  -- retrieves the active employees
),
-- Step 2: Calculate the average performance score per department
avg_department_performance AS (
    SELECT 
        department, 
        AVG(performance_score) AS avg_performance_score
    FROM performance_rank
    GROUP BY department
)
-- Step 3: Find employees whose performance is higher than the average in their department
SELECT 
    pr.employee_id, 
    e.first_name, 
    e.last_name, 
    pr.department, 
    pr.performance_score, 
    adp.avg_performance_score
FROM performance_rank pr
JOIN avg_department_performance adp
    ON pr.department = adp.department
JOIN employees e
    ON pr.employee_ID = e.employee_id
WHERE pr.performance_score > adp.avg_performance_score;



-- 11. Write an SQL query to find the top 3 departments 
-- with the highest average salary (for active employees). 
-- Return the department and the average salary, rounded to 2 decimal places.


SELECT TOP 3 department, AVG(salary) AS average_salary
FROM employees
WHERE date_resigned > GETDATE()
GROUP BY department
ORDER BY average_salary DESC;



-- 12. Write an SQL query to find the project names and 
-- the total number of employees who have joined before the 
-- project start date. Return the project_name and the count of such employees.



SELECT pd.project_name, COUNT(p.employee_id) AS total_no_of_employees
FROM project_departments pd
JOIN projects p
ON pd.project_id = p.project_id
JOIN employees e
ON p.employee_id = e.employee_id
WHERE e.date_joined < p.start_date
GROUP BY pd.project_name, pd.project_name
ORDER BY total_no_of_employees DESC;




-- 13. Write an SQL query to find the employees who have not been 
-- assigned to any project but not retired. 
-- Return the employee_id, first_name, last_name, and department. 


-- all employees not assigned to projects will have project_id as NULL
-- then filter for not retired employees


SELECT e.employee_id, e.first_name, e.last_name, e.department, e.date_resigned
FROM employees e
LEFT JOIN projects p
ON e.employee_id = p.employee_id
LEFT JOIN project_departments pd
ON p.project_id = pd.project_id
WHERE pd.project_id IS NULL 
AND date_resigned > GETDATE();



-- 14. Write an SQL query to find the names of employees who have been assigned to projects that are in 
-- 'Finance' and 'IT' lead departments but not in 'Customer Service'. 
-- Return the employee_id, first_name, and last_name. 


SELECT e.employee_id, e.first_name, e.last_name
FROM employees e
JOIN projects p
ON e.employee_id = p.employee_id
JOIN project_departments pd
ON p.project_id = pd.project_id
WHERE pd.lead_department IN ('Finance', 'IT')
AND e.department != 'Customer Service';



-- 15. Write an SQL query to find the average salary of employees 
-- for each project, rounded to 2 decimal places. 
-- Return the project_id, project_name, and average salary. 


WITH salary_cte
AS
(
SELECT pd.project_id, pd.project_name, e.salary AS salary
FROM project_departments pd
LEFT JOIN projects p
ON pd.project_id = p.project_id
JOIN employees e
ON p.employee_id = e.employee_id
GROUP BY pd.project_name, pd.project_id, pd.project_name, e.salary
)
SELECT project_id, project_name, AVG(salary) AS average_salary
FROM salary_cte
GROUP BY project_id, project_name
ORDER BY average_salary DESC;




-------------------


--Part B


--1. Write a SQL query to find the average salary of employees 
-- who have not resigned, grouped by department and performance level.


SELECT department, performance_level, AVG(salary) AS average_salary
FROM employees
WHERE date_resigned > GETDATE()  -- employees that have not resigned 
GROUP BY department, performance_level;



--2. Find the employee(s) who have the longest tenure (the difference 
-- between date_joined and date_resigned or the current date if they haven't resigned) in each department.


WITH longest_tenure AS
(
SELECT first_name, last_name, date_joined, date_resigned,
		CASE
			WHEN date_resigned > GETDATE() THEN DATEDIFF(YEAR, date_joined, GETDATE())
			WHEN date_resigned < GETDATE() THEN DATEDIFF(YEAR, date_joined, date_resigned)
			END AS tenure
FROM employees
)
SELECT * 
FROM longest_tenure
WHERE tenure = (SELECT MAX(tenure) FROM longest_tenure);




--3. Write a query to retrieve the names of employees who have worked on 
-- projects that have been completed, along with the project names and their respective departments.


SELECT CONCAT(e.first_name, ' ', e.last_name) AS full_name,
pd.project_name, pd.lead_department
FROM employees e
JOIN projects p
ON e.employee_id = p.employee_id
JOIN project_departments pd
ON p.project_id = pd.project_id
WHERE p.project_status = 'Completed';



--4. Find the department(s) with the highest average salary 
-- for employees who have not resigned.


SELECT TOP 1 department, AVG(salary) AS average_salary
FROM employees
WHERE date_resigned > GETDATE()
GROUP BY department
ORDER BY average_salary DESC;




--5. Write a query to retrieve the names of employees who have worked on 
-- projects that have a duration (end_date - start_date) longer than a specified number of days (e.g., 365 days).


WITH project_duration_cte AS
(
SELECT e.first_name, e.last_name, DATEDIFF(DAY, p.start_date, p.end_date) AS project_duration
FROM employees e
JOIN projects p
ON e.employee_id = p.employee_id
)
SELECT *
FROM project_duration_cte
WHERE project_duration > 365;




--6. Find the department(s) with the highest number of resigned employees.


SELECT TOP 1 department, COUNT(employee_id) AS no_of_employees
FROM employees
WHERE date_resigned < GETDATE()
GROUP BY department
ORDER BY no_of_employees DESC;



WITH ResignedCount AS (
    SELECT department, COUNT(employee_id) AS no_of_employees
    FROM employees
    WHERE date_resigned < GETDATE()
    GROUP BY department
)
SELECT department, no_of_employees
FROM ResignedCount
WHERE no_of_employees = (
    SELECT MAX(no_of_employees)
    FROM ResignedCount
);



--7. Find the project(s) that have the highest number of employees assigned to them, 
-- and return the project details (project_name, start_date, end_date, project_status) 
-- along with the count of employees.


WITH employee_count AS
(
SELECT pd.project_name, p.start_date, p.end_date, p.project_status, COUNT(p.employee_id) AS total_no_of_employees
FROM project_departments pd
JOIN projects p
ON pd.project_id = p.project_id
JOIN employees e
ON p.employee_id = e.employee_id
GROUP BY pd.project_name, p.start_date, p.end_date, p.project_status
)
SELECT *
FROM employee_count
WHERE total_no_of_employees = 
(SELECT MAX(total_no_of_employees) FROM employee_count);




--8. Find the employee(s) who have the highest salary and have not 
-- resigned, grouped by department.



WITH salary_rank AS
(
SELECT first_name, last_name, department, salary, performance_level,
RANK() OVER(PARTITION BY department ORDER BY salary DESC) AS rank
FROM employees
WHERE date_resigned > GETDATE()
)
SELECT * 
FROM salary_rank
WHERE rank = 1;



--9. Find the department(s) with the highest average age of 
-- employees who have not resigned.

WITH avg_age AS
(
SELECT department, AVG(age) AS average_age
FROM employees
WHERE date_resigned > GETDATE()
GROUP BY department
)
SELECT * 
FROM avg_age
WHERE average_age = (SELECT MAX(average_age) FROM avg_age);




--10. Find the department(s) that have the highest number of employees who have resigned, 
-- and for each of those departments, return the department name, the count of resigned employees, 
-- and the average tenure (in days) of those resigned employees.


WITH resigned_count AS
(
SELECT department, COUNT(employee_id) AS no_of_resigned_employees, 
AVG(DATEDIFF(DAY, date_joined, date_resigned)) AS tenure
FROM employees
WHERE date_resigned < GETDATE()
GROUP BY department
)
SELECT * 
FROM resigned_count
WHERE no_of_resigned_employees = (SELECT MAX(no_of_resigned_employees) FROM resigned_count);






-- 11. Write a SQL query to find the projects that have employees assigned from at 
-- least three different departments, and for each of those projects, return the project name, 
-- the count of distinct departments represented, and the average age of employees assigned to that project.

-- Steps:

-- COUNT(DISTINCT p.department) gives us the number of unique departments per project

-- We filter out projects that have employees from fewer than 
-- three different departments using HAVING COUNT(DISTINCT p.department) >= 3.


SELECT 
    pd.project_name, 
    COUNT(DISTINCT p.department) AS count_of_dept, 
    STRING_AGG(p.department, ', ') AS emp_departments,
    AVG(e.age) AS average_age
FROM 
    project_departments pd
JOIN 
    projects p ON pd.project_id = p.project_id
JOIN 
    employees e ON p.employee_id = e.employee_id
GROUP BY 
    pd.project_name
HAVING 
    COUNT(DISTINCT p.department) >= 3;






-- 12. Write a SQL query to find the department(s) that have the highest average salary 
-- for employees who have not resigned and have an 'Outstanding' performance level, and 
-- return the department name and the average salary rounded to the nearest integer.


WITH active_employees AS
(
SELECT department, AVG(salary) AS average_salary
FROM employees
WHERE performance_level = 'Outstanding'
AND date_resigned > GETDATE()
GROUP BY department
)
SELECT * 
FROM active_employees
WHERE average_salary = (SELECT MAX(average_salary) FROM active_employees);




--13. Write a SQL query to find the project(s) that have the highest average age 
-- of employees assigned to them, and for each of those projects, return the project name, 
-- the average age of employees rounded to the nearest integer, and the count of employees assigned to that project.


WITH highest_avg_age AS
(
SELECT pd.project_name, COUNT(p.employee_id) AS no_of_employees, ROUND(AVG(e.age), 0) AS average_age
FROM project_departments pd
JOIN projects p
ON pd.project_id = p.project_id
JOIN employees e
ON p.employee_id = e.employee_id
GROUP BY pd.project_name
)
SELECT * 
FROM highest_avg_age
WHERE average_age = (SELECT MAX(average_age) FROM highest_avg_age);



-- 14. Find the employee(s) who have worked on the most number of projects that have 
-- a duration (end_date - start_date) longer than 365 days, and for each of those employees, 
-- return their name, the count of projects with duration longer than 365 days, and 
-- the average duration (in days) of those projects.


-- 1. Create a CTE (Common Table Expression) to join the employees, projects, and project_departments tables
-- and calculate the duration of each project in days
-- 2. Select the required columns: first_name, last_name, count of projects, and average duration
-- 3. Filter the results to include only projects with duration longer than 365 days
-- 4. Group the results by first_name and last_name to get the count and average for each employee
-- 5. Order the results by Average_days in descending order to show employees with the highest average duration first


WITH projectCTE AS (
    SELECT
        e.employee_id,
        e.first_name,
        e.last_name,
        pd.project_name,
        p.project_status,
        DATEDIFF(DAY, p.start_date, p.end_date) AS duration_in_days
    FROM
        employees e
    JOIN
        projects p ON e.employee_id = p.employee_id
    JOIN
        project_departments pd ON p.project_id = pd.project_id
)
SELECT
    first_name,
    last_name,
    COUNT(project_name) AS total_projects,
    AVG(duration_in_days) AS average_days
FROM
    projectCTE
WHERE
    Duration_in_days > 365
GROUP BY
    first_name,
    last_name
ORDER BY
    average_days DESC;


--15. Retrieve the project names and the count of employees who have resigned 
--after working on those projects, but only for projects that have at least one resigned employee.


-- N/A



-- 16. Find the department(s) with the highest average salary for employees 
-- who have worked on completed projects, and return the department name(s) and the corresponding average salary.


WITH completed_projects AS
(
SELECT e.department, AVG(e.salary) AS average_salary
FROM 
    project_departments pd
JOIN 
    projects p ON pd.project_id = p.project_id
JOIN 
    employees e ON p.employee_id = e.employee_id
	WHERE p.project_status = 'Completed'
GROUP BY 
    e.department
)
SELECT *
FROM completed_projects
WHERE average_salary = (SELECT MAX(average_salary) FROM completed_projects);



 