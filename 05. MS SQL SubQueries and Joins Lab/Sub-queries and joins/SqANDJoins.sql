-- 01. Problem: Addresses with Towns
-- Display address information of all employees in "SoftUni" database. Select first 50 employees
-- The exact format of data is shown below
-- Order them by FirstName, then by LastName (ascending)
-- Hint: Use three-way join

SELECT TOP 50 [FirstName], [LastName], t.[Name] AS [Town], a.[AddressText] FROM Employees AS e
	JOIN Addresses AS a ON  e.AddressID = a.AddressID
	JOIN Towns as t ON t.TownID = a.AddressID
		ORDER BY [FirstName],[LastName]


-- 02. Problem: Sales Employees
-- Find all employees that are in the "Sales" department. Use "SoftUni" database.
-- Order them by EmployeeID.

SELECT [EmployeeID], [FirstName], [LastName], d.[Name] AS [DepartmentName] FROM Employees e
	JOIN Departments d ON d.DepartmentID = e.DepartmentID
		WHERE d.[Name] LIKE '%Sales%'
			ORDER BY [EmployeeID]

-- 03. Problem: Employees Hired After
-- Show all employees that:
-- Are hired after 1/1/1999
-- Are either in "Sales" or "Finance" department
-- Sorted by HireDate (ascending).

SELECT [FirstName], [LastName], [HireDate] , d.[Name] AS [DeptName] FROM Employees e
	JOIN Departments d ON d.[DepartmentID] = e.DepartmentID
		WHERE e.[HireDate] > '1/1/1999'
			AND d.Name IN ('Sales','Finance')
		ORDER BY [HireDate] ASC

-- 04. Problem: Employee Summary
-- Display information about employee's manager and employee's department .
-- Show only the first 50 employees.
-- The exact format is shown below:
-- Sort by EmployeeID (ascending).

SELECT TOP 50 e.[EmployeeID], 
				CONCAT(e.[FirstName], ' ' , e.[LastName]) AS [EmployeeName],
				CONCAT(M.[FirstName], ' ' , M.[LastName]) AS [ManagerName],
				d.[Name] AS [DepartmentName]
FROM Employees AS e
		LEFT JOIN Employees AS m ON m.EmployeeID = e.ManagerID
		LEFT JOIN Departments AS d ON d.DepartmentID = e.DepartmentID
	ORDER BY EmployeeID ASC


-- 05. Problem: Min Average Salary
-- Display lowest average salary of all departments.
-- Calculate average salary for each department.
-- Then show the value of smallest one.

SELECT MIN(a.[AverageSalary]) AS [MinimalSalary] FROM
		(
			SELECT e.[DepartmentID], AVG(e.[Salary]) AS [AverageSalary] FROM Employees e
				GROUP BY e.[DepartmentID]
		)AS a
