CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(20),
    location VARCHAR(20)
);

INSERT INTO department (dept_id, dept_name, location) VALUES
(1, 'Finance', 'Mumbai'),
(2, 'Sales', 'Bangalore'),
(3, 'HR', 'Delhi');

select * from department;
drop table employee;

CREATE TABLE employee (
    emp_id INT PRIMARY KEY,
    name VARCHAR(20),
    age INT,
    salary NUMERIC,
    dept_id INT references department(dept_id),
    manager_id INT
    --CONSTRAINT fk_dept
      --  FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

INSERT INTO employee (emp_id, name, age, salary, dept_id, manager_id) VALUES
(101, 'Ramesh', 20, 50000, 1, 103),
(102, 'Suresh', 22, 50000, 1, 103),
(103, 'Ram',    28, 80000, 1, NULL),
(104, 'Deep',   25, 30000, 2, 105),
(105, 'Pradeep',22, 60000, 2, NULL),
(106, 'Amit',   26, 40000, NULL, NULL);

select * from employee;
select * from department;

/*
Key data scenarios included intentionally:

Employees with departments

Employee without department (Amit)

Employees with managers

Managers who are also employees
*/

-- INNER JOIN
-- ==============

-- show employees along with their department name and location

select e.name, d.location from employee e join department d on e.dept_id = d.dept_id;

---
/*
Result Explanation
===================

Amit is excluded (no department)

Only employees with matching departments appear

Interview line:

INNER JOIN returns only matching rows from both tables.
*/
---

-- LEFT OUTER JOIN (Most Used in Real Systems)

-- Show all employees details (name, salary, and department_name), even if they don’t belong to any department

select e.name, e.salary, d.dept_name from employee e left join department d on e.dept_id = d.dept_id;

---
/*
RESULT EXPLANATION
==================

Amit appears with NULL department

No employee is dropped

*/
--

-- select employee details from finance department only
select e.name, e.salary, UPPER(d.dept_name) as department_name, d.location from employee e join department d on e.dept_id = d.dept_id 
where UPPER(d.dept_name) = 'FINANCE'; 

-- we have used upper to make our filter case insensitive -- however postgres always searches case insensitive - unless the entry is made in ''

select e.name, e.salary, d.dept_name as department_name, d.location from employee e join department d on e.dept_id = d.dept_id 
where d.dept_name = 'Finance';  

-- select all employees from department Finance and those which have not been assigned any department

select e.name, e.salary, UPPER(d.dept_name) as department_name, d.location from employee e left join department d on e.dept_id = d.dept_id 
where UPPER(d.dept_name) = 'FINANCE' or e.dept_id = NULL; --- this could not include AMIT with NULL dept_id

select e.name, e.salary, e.dept_id, UPPER(d.dept_name) as department_name, d.location from employee e left join department d on e.dept_id = d.dept_id 
where UPPER(d.dept_name) = 'FINANCE' or d.dept_name is NULL;  -- this included AMIT

select e.name, e.salary, UPPER(d.dept_name) as department_name, d.location from employee e left join department d on e.dept_id = d.dept_id 
where UPPER(d.dept_name) = 'FINANCE' or e.dept_id is NULL; -- this included AMIT



-- 
/*
RESULT EXPLANATION
==================

TO CHECK NULL values in a field don't use "=" instead  use "is NULL"
why?

SQL uses three possible boolean values:
TRUE
FALSE
UNKNOWN

AND SQL TREATS NULL as UNKNOWN

SO in where clause -> which wants boolean output(TRUE) on expressions

10 = NULL -> UNKNOWN
NULL = NULL -> UNKNOWN
NULL = 10 -> UNKNOWN
UNKNOWN or TRUE. -> TRUE
UNKNOWN or FALSE -> UNKNOWN (filtered out)

-- GOLDEN RULE: WHERE KEEPS ONLY "TRUE", NOT "FALSE" OR "UNKNOWN"

WHY FAILED: SELECT e.name, e.salary, UPPER(d.dept_name) AS department_name, d.location
FROM employee e
LEFT JOIN department d
    ON e.dept_id = d.dept_id
WHERE UPPER(d.dept_name) = 'FINANCE'
   OR e.dept_id = NULL;

What Happens for Amit
Column	Value
e.dept_id	NULL
d.dept_name	NULL

Now evaluate WHERE:

UPPER(NULL) = 'FINANCE'   → UNKNOWN
NULL = NULL               → UNKNOWN
UNKNOWN OR UNKNOWN        → UNKNOWN

Result

❌ Row is filtered out

Key Rule:

WHERE clause never keeps rows that evaluate to UNKNOWN.
Why the Second Query Works
Your Working Query
SELECT e.name, e.salary, e.dept_id, UPPER(d.dept_name) AS department_name, d.location
FROM employee e
LEFT JOIN department d
    ON e.dept_id = d.dept_id
WHERE UPPER(d.dept_name) = 'FINANCE'
   OR d.dept_name IS NULL;

What Happens for Amit
UPPER(NULL) = 'FINANCE' → UNKNOWN
d.dept_name IS NULL    → TRUE
UNKNOWN OR TRUE        → TRUE

Result

✅ Amit is included

4. Why d.dept_name IS NULL Is the Correct Check

With a LEFT JOIN:

If there is no matching row, all columns from the right table become NULL

That is how SQL represents “no match”

So this is the canonical pattern:

LEFT JOIN ...
WHERE right_table.column IS NULL


This is known as an ANTI-JOIN pattern.

5. Even Better (Interview-Preferred) Version

Instead of using UPPER() (which prevents index usage), write:

SELECT
    e.name,
    e.salary,
    d.dept_name,
    d.location
FROM employee e
LEFT JOIN department d
    ON e.dept_id = d.dept_id
WHERE d.dept_name = 'Finance'
   OR d.dept_id IS NULL;

Why this is better

No function on indexed column

Cleaner intent

Performs better at scale

6. Important Interview Rule (Memorize This)

Never compare anything with NULL using = or !=

Always use:

IS NULL
IS NOT NULL

7. JOIN Predicate vs WHERE Predicate (Advanced Insight)
❌ Dangerous Pattern
LEFT JOIN department d ON e.dept_id = d.dept_id
WHERE d.dept_name = 'Finance'


This turns LEFT JOIN into INNER JOIN.

✅ Correct Pattern
LEFT JOIN department d
    ON e.dept_id = d.dept_id
   AND d.dept_name = 'Finance';


Interview explanation:

ON controls matching

WHERE controls filtering

8. One-Line Interview Answer

Question:
Why didn’t e.dept_id = NULL work?

Answer:
Because NULL represents unknown, comparisons with = return UNKNOWN, and WHERE filters out UNKNOWN rows. IS NULL must be used instead.

Final Takeaway

We have now understood:
✔ SQL three-valued logic
✔ Why LEFT JOIN rows disappear
✔ How to correctly handle NULL
✔ How to explain this clearly in interviews
*/


-- if we use where in OUTER JOIN (employee e left join department d on e.dept_id = d.dept_id where d.dept_name = 'Finance'), 
-- it effectively has become innerjoin 
-- (employee e join department d on e.dept_id = d.dept_id) 
-- so better we use this

select e.name, e.salary, d.dept_id, d.dept_name from employee e left join department d on e.dept_id = d.dept_id 
and d.dept_name = 'Finance'

-- in action

select e.*, d.dept_name, d.location from employee e left join department d on e.dept_id = d.dept_id 
where dept_name = 'Finance'; --same data as below query
select e.*, d.dept_name, d.location from employee e join department d on e.dept_id = d.dept_id where dept_name = 'Finance';


-- but if we really wanted left join -> means we want those employees as well which do not belong to dept_name = 'Finance'
-- they will just be having department fields (dept_name and location) as null in the resultset

select e.*, d.dept_name, d.location from employee e left join department d on e.dept_id = d.dept_id and d.dept_name = 'Finance';

-- STEP 5: RIGHT OUTER JOIN (Conceptual Clarity)
-- Show all departments, even those without employees

select e.name, e.salary, d.dept_name, d.location from employee e right join department d on e.dept_id = d.dept_id;
select e.name, e.salary, d.dept_name, d.location from department d left join employee e on e.dept_id = d.dept_id;

---
/*
RESULT EXPLANATION

SAME OUTPUT

LEFT JOIN -> puts all the rows matching and non-matching from the table to the left of the keyword
-- for non-matching rows from the left table -> right table columns will have null values

RIGHT JOIN -- puts all the rows matching and non-matching from the table to the right of the keyword
-- for non-matching rows from the right table -> left table columns will have null values

Interview Insight

RIGHT JOIN = LEFT JOIN with table order reversed

Prefer LEFT JOIN in production for readability
*/

-- STEP 6: SELF JOIN (Very Important)

-- Show employee and their manager
select * from employee;
select e.name as employee_name, m.name as manager_name from employee e join employee m on e.manager_id = m.emp_id;
select e.name as employee_name, m.name as manager_name from employee e 
left join employee m on e.manager_id = m.emp_id; -- this includes employess with no managers - probably managers themselves

/*
Key Observations

Ram and Pradeep show NULL manager (top-level)

Same table plays two roles

Interview phrase:

SELF JOIN is used to model hierarchical relationships.
*/

-- FULL OUTER JOIN (Audit / Reconciliation)

-- Show all employees and all departments, matched where possible

select e.name, d.dept_name from employee e full outer join department d on e.dept_id = d.dept_id;

/*
When This Is Used

Data audits

Migration validation

ETL mismatch detection
*/

-- CROSS JOIN (Cartesian Product)
-- Generate all employee–department combinations (theoretical)
-- does not require on condition since we are going for cartesian product -> all possible values from left to right
select e.name, d.dept_name from employee e cross join department d;

-- RESULT EXPLANATION
-- EACH employee has 3 possible departments
/*
⚠ Rows = employees × departments

Interview warning:
Never use unintentionally.
*/

-- interview specifics

-- Employees without department (Anti-Join)
select e.name from employee e left join department d on e.dept_id = d.dept_id where d.dept_id is null;

-- Departments without employees
select d.dept_name from department d left join employee e on d.dept_id = e.dept_id where e.emp_id is null;

select * from employee;
-- Employees earning more than their manager
select e.name as emp_name, e.salary as emp_salary, m.name as manager_name, m.salary as manager_salary from employee e left join employee m
on e.manager_id = m.emp_id where e.salary > m.salary

update employee  set salary = 70000 where name = 'Deep';



