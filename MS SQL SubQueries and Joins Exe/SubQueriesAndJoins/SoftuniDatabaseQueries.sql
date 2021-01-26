-- Softuni Database Queries

USE SoftUni

-- 1.	Employee Address
--Write a query that selects:
--•	EmployeeId
--•	JobTitle
--•	AddressId
--•	AddressText
--Return the first 5 rows sorted by AddressId in ascending order.

SELECT TOP 5 [EmployeeID], [JobTitle], e.[AddressID], a.[AddressText]  
	FROM Employees e
		JOIN Addresses a ON e.AddressID = a.AddressID
	ORDER BY e.[AddressID]

-- 2.	Addresses with Towns
--Write a query that selects:
--•	FirstName
--•	LastName
--•	Town
--•	AddressText
--Sorted by FirstName in ascending order then by LastName. Select first 50 employees.

SELECT TOP 50 [FirstName], [LastName], t.[Name] AS [Town], a.AddressText
	FROM Employees e
		JOIN Addresses a ON e.AddressID = a.AddressID
		JOIN Towns t ON a.TownID = t.TownID
	ORDER BY [FirstName] ASC, [LastName]

-- 3.	Sales Employee
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--•	LastName
--•	DepartmentName
--Sorted by EmployeeID in ascending order. Select only employees from "Sales" department.

SELECT [EmployeeID], [FirstName], [LastName],d.[Name] AS [DepartmentName] FROM Employees e
	LEFT JOIN Departments d ON e.[DepartmentID] = d.[DepartmentID]
		WHERE d.[Name] LIKE '%Sales%'

-- 4.	Employee Departments
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--•	Salary
--•	DepartmentName
--Filter only employees with salary higher than 15000. Return the first 5 rows sorted by DepartmentID in ascending order.

SELECT TOP 5 [EmployeeID], [FirstName], [Salary], d.[Name] AS [DepartmentName] FROM Employees e
	LEFT JOIN Departments d ON e.[DepartmentID] = d.[DepartmentID]	
		WHERE [Salary] > 15000
		ORDER BY e.[DepartmentID]

-- 5.	Employees Without Project
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--Filter only employees without a project. Return the first 3 rows sorted by EmployeeID in ascending order.

SELECT TOP 3 e.[EmployeeID], [FirstName] FROM Employees e
	LEFT JOIN EmployeesProjects p ON e.[EmployeeID] = p.[EmployeeID]
	WHERE p.ProjectID IS NULL

-- 6.	Employees Hired After
--Write a query that selects:
--•	FirstName
--•	LastName
--•	HireDate
--•	DeptName
--Filter only employees hired after 1.1.1999 and are from either "Sales" or "Finance" departments, sorted by HireDate (ascending).

SELECT [FirstName], [LastName],[HireDate], d.[Name] AS [DepartmentName] FROM Employees e
	LEFT JOIN Departments d ON e.[DepartmentID] = d.[DepartmentID]
		WHERE [HireDate] > '1.1.1999' AND
			d.[Name] IN('Sales', 'Finance')
		ORDER BY [HireDate] ASC

-- 7.	Employees with Project
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--•	ProjectName
--Filter only employees with a project which has started after 13.08.2002 and it is still ongoing (no end date). Return the first 5 rows sorted by EmployeeID in ascending order.

SELECT TOP 5 e.[EmployeeID], [FirstName],p.[Name] AS [ProjectName] FROM Employees e
		LEFT JOIN EmployeesProjects ep ON e.[EmployeeID] = ep.[EmployeeID]
		LEFT JOIN Projects p ON ep.[ProjectID] = p.[ProjectID]
			WHERE p.[StartDate] > '2002.08.13' AND
				p.[EndDate] IS NULL
		ORDER BY e.[EmployeeID] ASC

-- 8.	Employee 24
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--•	ProjectName
--Filter all the projects of employee with Id 24. If the project has started during or after 2005 the returned value should be NULL.

SELECT e.[EmployeeID], [FirstName], 
CASE
	WHEN YEAR(p.[StartDate]) >= 2005 THEN NULL
	ELSE p.[Name]
END AS [ProjectName]
	FROM Employees e
		LEFT JOIN EmployeesProjects ep ON e.[EmployeeID] = ep.[EmployeeID]
		LEFT JOIN Projects p ON ep.[ProjectID] = p.[ProjectID]
		WHERE e.EmployeeID = 24
	
-- 9.	Employee Manager
--Write a query that selects:
--•	EmployeeID
--•	FirstName
--•	ManagerID
--•	ManagerName
--Filter all employees with a manager who has ID equals to 3 or 7. Return all the rows, sorted by EmployeeID in ascending order.

SELECT e.[EmployeeID], e.[FirstName], m.[EmployeeID] AS [ManagerID], m.[FirstName] AS [ManagerName] FROM Employees e
	LEFT JOIN Employees m ON m.[EmployeeID] = e.[ManagerID]
		WHERE e.[ManagerID] IN (3,7)
	ORDER BY e.[EmployeeID] ASC

-- 10. Employee Summary
--Write a query that selects:
--•	EmployeeID
--•	EmployeeName
--•	ManagerName
--•	DepartmentName
--Show first 50 employees with their managers and the departments they are in (show the departments of the employees). Order by EmployeeID.

SELECT TOP 50 
	e.[EmployeeID],
	CONCAT(e.[FirstName], ' ', e.[LastName]) AS [EmployeeName],
	CONCAT(m.[FirstName], ' ', m.[LastName]) AS [ManagerName],
	d.[Name] AS [DepartmentName]
FROM Employees e
	LEFT JOIN Employees m ON m.[EmployeeID] = e.[ManagerID]
	LEFT JOIN Departments d ON e.[DepartmentID] = d.DepartmentID
ORDER BY e.[EmployeeID]

-- 11. Min Average Salary
-- Write a query that returns the value of the lowest average salary of all departments.

SELECT TOP(1) AVG(Salary) AS MinAverageSalary  
	FROM Employees
		GROUP BY DepartmentID
		ORDER BY MinAverageSalary 