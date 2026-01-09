create table employee(name varchar(10), age int, department varchar(20), salary numeric);

select * from employee;

INSERT INTO employee (name, age, department, salary)
VALUES
    ('Ramesh', 20, 'Finance', 50000),
    ('Suresh', 22, 'Finance', 50000),
    ('Ram', 28, 'Finance', 20000),
    ('Deep', 25, 'Sales', 30000),
    ('Pradeep', 22, 'Sales', 20000);

-- Show each employee’s salary along with average salary of their department

select name, age, department, salary, avg(salary) over (partition by department order by department desc) 
as avg_dept_salary from employee;

-- Show each employee’s salary and total salary of their department

select name, department, age, salary, sum(salary) over (partition by department order by department ) as total_dept_salary
from employee;

-- Show each employee’s salary and company-wide average salary -- no partition by clause in over function - treats whole table as one window

select name, department, age, salary, avg(salary) over() as avg_company_salary from employee;

-- Find employees whose salary is above department average
-- you cannot directly use window function in where clause -- use a subquery or CTE

select * from (select name, department, salary, avg(salary) over(partition by department) as dept_avg_salary from employee) table_temp
where table_temp.salary > table_temp.dept_avg_salary;

select * from (select name, department, salary, avg(salary) over(partition by department) as dept_avg_salary from employee) table_temp
where table_temp.salary > dept_avg_salary;

select * from (select name, department, salary, avg(salary) over(partition by department) as dept_avg_salary from employee) table_temp
where salary > dept_avg_salary;

select * from (select name, department, salary, avg(salary) over(partition by department) as dept_avg_salary from employee) table_temp
where salary > table_temp.dept_avg_salary;

-- above all are identical queries

-- 2. Ranking window function

-- Rank employees by salary within each department -- in order function do pass order by clause along with partition
-- otherwise ranking won't work, for example - second query

select name, age, department, salary, rank() over (partition by department order by salary desc) as salary_rank_in_dept 
from employee;

select name, age, department, salary, rank() over (partition by department) as salary_rank_in_dept from employee;


-- difference between rank() and dense_rank() - ordering salary in desc order

select name, department, salary, rank() over (partition by department order by salary desc) as salary_rank_dept,
dense_rank() over(partition by department order by salary desc) as salary_dense_rank_dept,
row_number() over (partition by department order by salary desc) as row_num_dept from employee;

-- rank - same salary - same rank, dense_rank also does the same
-- rank- after duplicate salary - it jumps the same no of times there are duplicates
-- dense rank - does not skip or jumps - and gives the next rank after duplicates

-- row number - unique even for duplicate entries, and gaps -> not applicable here

-- Find highest paid employee per department

select * from (select name, department, salary, rank() over (partition by department order by salary desc) as salary_rank_dept from employee) t
where t.salary_rank_dept = 1

-- works even when multiple employees share highest salary

-- find second highest salary in each department

select * from (select name, department, salary, dense_rank() over (partition by department order by salary desc) as dense_rank_sal from employee) t
where t.dense_rank_sal = 2;

-- show salary difference from department average

select name, department, salary, salary - avg(salary) over (partition by department) as diff_avg_sal from employee; 

-- calculate running total of salary per department (ordered by age)

select name, department, age, salary, sum(salary) over (partition by department order by age rows between unbounded preceding and current row) as running_total
from employee;

-- interview : Window frame ( rows between) used earlier

-- compare employee salary with previous employee in same department

select name, department, salary, salary - LAG(salary) over (partition by department order by salary) as salary_diff
from employee;
-- interview what is LAG function

-- Find employees which earn more than previous employee
select * from ( select name, department, salary, LAG(salary) over (partition by department order by salary) as prev_salary from employee) t
where salary > prev_salary;

/*
interview notes:

Q - Why use window function instead of Group BY?
A - Window function allow aggregate calculations without collapsing rows, preserving row-level detail.

Q - Can window function be used in Where?
A - No, Use a subquery or CTE

Q - What is Partition By?
A - It divides data into logical groups for window calculations

Q - Difference between Partition By and Group By?
A - "Group by" reduces rows, whereas "partition by" does not

Q - What happens if ORDER BY is Ommitted?
A - Window function operate on unordere partitions (ranking functions require order by)

*/

-- additional questions

-- find lowest paid employee per department
select * from ( select name, department, salary, age, rank() over (partition by department order by salary) as rank_salary_asc from employee) t
where rank_salary_asc = 1;

-- find lowest paid employee per department - only one record is required per department
select * from (select name, department, salary, age, row_number() over (partition by department order by salary) as row_number_salary_asc from employee)t
where row_number_salary_asc = 1;

-- show percentage contribution of each employee's salary to department total
-- since postgre does integer division if both operands are integer
select name, department, salary, salary*100/sum(salary) over(partition by department)as percentage_contribution_to_dept_total_sal from employee; 

-- so better use below two formats -- however mentioning numeric casting shows production maturity
select name, department, salary, salary*100.0/sum(salary) over(partition by department)as percentage_contribution_to_dept_total_sal from employee; 
select name, department, salary, salary::numeric *100/sum(salary) over(partition by department)as percentage_contribution_to_dept_total_sal from employee; -- mentioning numeric casting shows production maturity

-- find employees who are earning above company average
select * from (select name, department, salary, avg(salary) over() as company_avg_salary from employee) t where salary > company_avg_salary; 

-- get top 2 earners per department
select * from (select name, department, salary, dense_rank() over (partition by department order by salary desc)as dense_rank_sal_dept from employee) t
where dense_rank_sal_dept in (1, 2);

-- if in earlier question asked for exactly 2 entries - use row_number

select * from (select name, department, salary, row_number() over (partition by department order by salary desc) as row_num_sal_desc from employee) t
where row_num_sal_desc in (1,2);







