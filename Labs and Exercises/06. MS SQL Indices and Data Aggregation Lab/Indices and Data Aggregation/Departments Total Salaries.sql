-- Departments Total Salaries
--Use "SoftUni" database to create a query which prints the total sum of salaries for each department. 
--Order them by DepartmentID (ascending).

USE [SoftUni]

SELECT 
	[DepartmentID], 
	SUM([Salary]) AS [TotalSalary]
FROM Employees 
	GROUP BY [DepartmentID]
		ORDER BY [DepartmentID]

