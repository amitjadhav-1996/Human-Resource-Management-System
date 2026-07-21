create database hr_db;
use hr_db;

create table departments(
dept_id int primary key, 
dept_name varchar(40) unique not null, 
location varchar(40) not null);

select * from departments;

create table employees(
emp_id int primary key,
emp_name varchar(50) not null,
gender varchar(10),
hire_date date,
job_title varchar(40),
salary int not null,
dept_id int references departments(dept_id),
manager_id int);

select * from employees order by emp_id;

create table payroll(
payroll_id int primary key,
emp_id int references employees(emp_id),
pay_month date not null,
bonus int,
deductions int,
net_salary int);

CREATE TABLE employee_history (
	emp_id INT,
    emp_name VARCHAR(50),
    dept_name VARCHAR(50),
    job_title VARCHAR(100),
    salary DECIMAL(10,2),
    action varchar(20),
    action_performed_by varchar(30),
    action_time timestamp
);

DELIMITER //

CREATE TRIGGER before_employee_delete
BEFORE DELETE ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_history (
        emp_id,
        emp_name,
        dept_name,
        job_title,
        salary,
        action,
        action_performed_by,
        action_time
    )
    VALUES (
        OLD.emp_id,
        OLD.emp_name,
        OLD.dept_name,
        OLD.job_titlr,
        OLD.salary,
        'DELETE',
        CURRENT_USER(),
        CURRENT_TIMESTAMP
    );
END //

DELIMITER ;

select * from payroll;

-- 1) How many employees are there in the organization?
select count(*) from employees; -- There are total 500 employees present in the organization

-- 2) How many employees work in each department?
select dept_id, count(dept_id) from employees group by dept_id; -- Every department wise employees
select count(emp_id) from employees where dept_id=40; -- cross checked using where condition

-- 3)How many male and female employees are there?
select gender, count(emp_id) from employees group by gender; -- 250 each

-- 4)What is the average employee salary?
select avg(salary) from employees; 

-- 5)Who are the top 10 highest-paid employees?
select emp_id, emp_name, salary from employees order by salary desc limit 10;

-- 6)Who are the bottom 10 lowest-paid employees?
select emp_id, emp_name, salary from employees order by salary limit 10;

-- 7)Which employees earn above the company average salary?
select emp_id, emp_name, salary from employees
where salary > (select avg(salary) from employees); -- used subquery
select count(*) from employees where salary>(select avg(salary) from employees); -- 250 count whose salary is greater than avg salary

-- 8) What is the salary range (max-min) in the company?
select max(salary) - min(salary) as salary_range from employees;

-- 9) How many employees joined each year?
select year(hire_date) as year, count(emp_id) from employees
group by year order by year;

-- 10) Which employees have worked the longest in the company?
select emp_id, emp_name, hire_date, timestampdiff(day,hire_date,current_date()) as period from employees
order by period desc limit 10; -- top 10 old employees working in the organization

-- 11) What is the total salary expense for each department?
select dept_id, sum(salary) from employees
group by dept_id;

-- 12) Which department has the highest average salary?
select dept_id, avg(salary) from employees
group by dept_id order by avg(salary) desc limit 1;


-- 13) Which department has the lowest average salary?
select dept_id, avg(salary) from employees
group by dept_id order by avg(salary) limit 1;

-- 14) What percentage of employees belong to each department?
select dept_id, count(emp_id), round((count(emp_id)*100/(select count(*) from employees)),2) as Percentage_Of_Employees from employees
group by dept_id;

-- 15) What percentage of total salary expense belongs to each department?
select dept_id, sum(salary), round((sum(salary)*100/(select sum(salary) from employees)),2) as Percentage_Of_Employees from employees
group by dept_id;

-- 16) What is the total monthly payroll expense?
select monthname(pay_month) as month, sum(salary)+sum(bonus) from employees e join payroll p using(emp_id)
group by month ;

-- 16) What is the total mannual payroll expense?
select year(pay_month) as year, sum(salary)+sum(bonus) from employees e join payroll p using(emp_id)
group by year ;

-- 17) How much bonus was paid each month?
select monthname(pay_month) as month, sum(bonus)as bonus from employees e join payroll p on e. emp_id=p.emp_id
group by month;

-- 18) How much bonus was paid by each department?
select dept_id, sum(bonus) as bonus from employees e join payroll p on e. emp_id=p.emp_id
group by dept_id;

-- 19) Which employees received the highest bonus?
select emp_id, emp_name, salary, sum(bonus) as total_bonus from employees e join payroll p using(emp_id)
group by emp_id order by total_bonus desc limit 10; -- top 10 employees getting higher bonus

-- 20) What is the average bonus paid to employees?
select sum(bonus)/count(distinct emp_id) as yearly_average_bonus from payroll;

-- 21) Which employees have the highest deductions?
select e.emp_id, emp_name,salary, sum(deductions) as yearly_deductions from employees e join payroll p
on e.emp_id=p.emp_id group by emp_id order by 4 desc limit 10; -- top 10 employees getting highest salary deducted

-- 22) What is the average net salary across the company?
select avg(net_salary) from payroll;

-- 23) Show employee name, department name, and salary.
select emp_name, dept_name, salary from employees e join departments d on e.dept_id=d.dept_id; -- two tables joined using join

-- 23) Show employee name, department name, and net salary.
select emp_name, dept_name, net_salary from employees e join departments d 
on e.dept_id=d.dept_id join payroll p on e.emp_id=p.emp_id; -- three tables joined using join

-- 24) List employees with their department locations.
select emp_id, emp_name, e.dept_id, location from employees e join departments d on e.dept_id=d.dept_id;

-- 25) Show top-paid employee from each department.
select emp_id, emp_name, dept_id, salary from employees e  -- used corelated sub-query
where salary= (select max(salary) from employees e1 where e1.dept_id=e.dept_id) order by dept_id;

-- 26)Find employees earning more than their department average salary.
select emp_id, emp_name, dept_id, salary from employees e  -- used corelated sub-query
where salary>(select avg(salary) from employees e1 where e1.dept_id=e.dept_id) order by dept_id;

-- 27)Find no of employees department wise who are earning more than their department average salary.
select dept_id, count(emp_id) from employees e  -- used corelated sub-query
where salary>(select avg(salary) from employees e1 where e1.dept_id=e.dept_id)
group by dept_id order by count(emp_id);


-- 28) Find departments whose average salary is above the company average.
select dept_id, avg(salary) from employees
group by dept_id having avg(salary)>(select avg(salary) from employees);

-- 29) Find employees receiving above-average bonuses.
select e.emp_id, emp_name, salary, bonus from employees e join payroll p on e. emp_id=p.emp_id
where bonus>(select avg(bonus) from payroll);

-- Window Functions

-- 30) Rank employees by salary across the company.
select *, row_number() over(order by salary desc), -- row_number()
rank() over(order by salary desc), -- (rank()
dense_rank() over(order by salary desc) --  dense_rank()
from employees;

-- 31) Rank employees by salary within each department.
select *, row_number() over(partition by dept_id order by salary desc), -- row_number()
rank() over(partition by dept_id order by salary desc), -- (rank()
dense_rank() over(partition by dept_id order by salary desc) --  dense_rank()
from employees;

-- 32) -- 31) Rank employees by salary within each departmen name.
select *, row_number() over(partition by dept_name order by salary desc), -- row_number()
rank() over(partition by dept_name order by salary desc), -- (rank()
dense_rank() over(partition by dept_name order by salary desc) --  dense_rank()
from employees e join departments d on e.dept_id=d.dept_id;

-- 33) Find the top 3 earners in every department.
select * from (select emp_id, emp_name, salary, dense_rank() over(partition by dept_name order by salary desc) as rn --  dense_rank()
from employees e join departments d on e.dept_id=d.dept_id) t where rn<=3;

-- 34) Find the second highest-paid employee in each department.
select * from (select emp_id, emp_name, e.dept_id, salary, dense_rank() over(partition by dept_name order by salary desc) as rn --  dense_rank()
from employees e join departments d on e.dept_id=d.dept_id) t where rn=2 order by dept_id;

-- 35) Compare an employee's salary with the previous employee's salary.
select emp_id, emp_name, salary, lag(salary) over() from employees;

-- Basic Level Questions(Select, Where)

-- 36) Display all employees with their details.
select * from employees;

-- 37) List all departments available in the company.
select distinct dept_id from employees;

-- 38) Find employees who earn more than 50,000.
select * from employees where salary > 50000;

-- 39) Show employees belonging to department ID = 30.
select * from employees where dept_id=30;

-- 40) Display employees whose name starts with 'A'.
select * from employees where emp_name like "A%";

-- 41) Find employees who joined after 2020.
select * from employees where year(hire_date)>2020;

-- 42) Show employee name, salary, and department ID.
select emp_name, salary, dept_id from employees;

-- 43) List employees who do not have a manager assigned (NULL values).
select * from employees where manager_id is null;

-- Join Questions

-- 44) Display employee name along with department name.
select emp_id, emp_name, dept_name from employees e join departments d on e.dept_id=d.dept_id;

-- 45) List all employees and their manager names.
select e.emp_id, e.emp_name, e.manager_id, e1.emp_name as manager_name from
employees e join employees e1 on e.manager_id=e1.emp_id order by emp_id;

-- 46) Show employees with their department details using INNER JOIN.
select emp_id, emp_name, e.dept_id, dept_name, location from 
employees e inner join departments d on e.dept_id= d.dept_id;

-- 47) Find employees who belong to "IT" or "Sales" departments.
select emp_id, emp_name, dept_name from employees e join departments d
on e.dept_id=d.dept_id where dept_name in ("IT", "Sales");

-- CTE questions

-- 48) Write a CTE to display all employees with salary greater than 1,00,000.
with cte as (select * from employees where salary >100000)
select * from cte;

-- 49) Use CTE to display employee name, salary, and department ID.
with cte as ( select emp_name, salary, dept_id from employees)
select * from cte;

-- 50) Use CTE to find employees earning above department average.
with cte as (select emp_id, emp_name, dept_id, salary from employees)
select * from cte c where salary > (select avg(salary) from employees e
where e.dept_id=c.dept_id);  -- Corelated Sub-query

-- View Questions

-- 51) Create a view to display employee names, salaries, and department names.
create view display_emp_details as 
select emp_name, salary, dept_name from employees e join departments d on e.dept_id=d.dept_id;

select * from display_emp_details;  -- Using View

-- 52) Create a view to display department-wise employee count.
create view emp_count_deptwise as select dept_id, count(emp_id)
from employees group by dept_id;

select * from emp_count_deptwise ;  -- calling view using select

-- 53) Create a view for monthly payroll summaries.
create view monthly_payroll as select monthname(pay_month) as month, sum(salary)
 from employees e join payroll p on e.emp_id=p.emp_id
 group by month ;

select * from monthly_payroll;

-- Stored Procedures

-- 54) Create a procedure to display all employees.
delimiter //
create procedure display_employees()
begin
	select * from employees;
end // 
delimiter ;

call display_employees();  -- calling procedure

-- 55) Find employees by department and salary using stored procedure
delimiter //
create procedure dept_salary_input( in d_dept_id int, s_salary int)
begin
	select * from employees
    where dept_id= d_dept_id and salary > s_salary;
end // 
delimiter ;

call dept_salary_input(20,90000);

-- Functions

-- 56) Create a function to calculate annual salary from monthly salary.
delimiter //
create function annual_salary(salary int)
returns int
deterministic
begin
	return salary*12;
end //
delimiter ;

select annual_salary(40000);

-- 57) Create a function to calculate net salary.
delimiter //
create function net_Sal(salary int , bonus int, deductions int)
returns int
deterministic
begin
	return salary+bonus-deductions;
end //
delimiter ;

select net_sal(40000,5000,2000);

-- Index 
-- 58) Create an index on emp_name to speed up employee name searches.
create index idx_emp_name
on employees(emp_name);

explain select * from employees where emp_name="Rahul Singh";

-- 59) Create a composite index on (dept_id, salary)
create index dept_id_sal
on employees(dept_id,salary);


