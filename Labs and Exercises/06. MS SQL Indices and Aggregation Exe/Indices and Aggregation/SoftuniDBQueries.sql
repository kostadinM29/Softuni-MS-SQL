Use SoftUni

-- 13. Departments Total Salaries
--That’s it! You no longer work for Mr. Bodrog. You have decided to find a proper job as an analyst in SoftUni. 
--It’s not a surprise that you will use the SoftUni database. Things get more exciting here!
--Create a query that shows the total sum of salaries for each department. Order by DepartmentID.

SELECT 
	[DepartmentID],
	SUM([Salary]) AS [TotalSalary]
FROM Employees
GROUP BY [DepartmentID]
ORDER BY [DepartmentID]

-- 14. Employees Minimum Salaries
--Select the minimum salary from the employees for departments with ID (2, 5, 7) but only for those hired after 01/01/2000.

SELECT 
	[DepartmentID],
	MIN([Salary]) AS [MinimumSalary]
FROM Employees
WHERE [DepartmentID] IN (2,5,7) AND HireDate > '2000.01.01'
GROUP BY [DepartmentID]

-- 15. Employees Average Salaries
--Select all employees who earn more than 30000 into a new table.
--Then delete all employees who have ManagerID = 42 (in the new table). Then increase the salaries of all employees with DepartmentID=1 by 5000.
--Finally, select the average salaries in each department.

SELECT * INTO EmployeesBackup2020 FROM Employees
WHERE Salary > 30000

DELETE FROM EmployeesBackup2020 
WHERE ManagerID = 42

UPDATE EmployeesBackup2020
SET Salary += 5000 WHERE DepartmentID = 1

SELECT 
	[DepartmentID],
	AVG([Salary]) AS [AverageSalary]
FROM EmployeesBackup2020
GROUP BY [DepartmentID]

--16. Employees Maximum Salaries
--Find the max salary for each department. Filter those, which have max salaries NOT in the range 30000 – 70000.
Select * FROM
(
SELECT 
	[DepartmentID],
	MAX([Salary]) AS [MaxSalary]
FROM Employees
GROUP BY [DepartmentID]
) AS [MaxSalaryQuery]
WHERE [MaxSalary] NOT BETWEEN 30000 AND 70000

-- 17. Employees Count Salaries
--Count the salaries of all employees who don’t have a manager.

SELECT COUNT([Salary]) AS [Count] FROM Employees
	WHERE ManagerID IS NULL

-- 18. *3rd Highest Salary
--Find the third highest salary in each department if there is such. 

SELECT 
	[DepartmentID],
	[Salary]
FROM
(
SELECT 
	[DepartmentID],
	[Salary],
	DENSE_RANK() OVER (PARTITION BY [DepartmentID] ORDER BY [Salary] DESC) AS [SalaryRank]
FROM Employees
GROUP BY [DepartmentID],[Salary]
) AS [RankSalaryQuery]
WHERE [SalaryRank] = 3

-- 19. **Salary Challenge
--Write a query that returns:
--•	FirstName
--•	LastName
--•	DepartmentID
--Select all employees who have salary higher than the average salary of their respective departments.
--Select only the first 10 rows. Order by DepartmentID.

SELECT TOP 10
	[FirstName],
	[LastName],
	e.[DepartmentID]
FROM Employees e
JOIN 
(
	SELECT 
		[DepartmentID],
		AVG([Salary]) AS [AverageSalary]
	FROM Employees
	GROUP BY [DepartmentID]
) AS avg  ON e.[DepartmentID] = avg.[DepartmentID]
WHERE e.[Salary] > avg.[AverageSalary]
ORDER BY [DepartmentID]
