--Queries for SoftUni Database
USE SoftUni


-- 1.	Employees with Salary Above 35000
--Create stored procedure usp_GetEmployeesSalaryAbove35000 that returns all employees’ first and last names for whose salary is above 35000. 

GO
CREATE PROC usp_GetEmployeesSalaryAbove35000
AS
BEGIN
	SELECT [FirstName], [LastName] FROM Employees
		WHERE [Salary] > 35000
END
GO

EXEC usp_GetEmployeesSalaryAbove35000

-- 2.	Employees with Salary Above Number
--Create stored procedure usp_GetEmployeesSalaryAboveNumber that accept a number (of type DECIMAL(18,4)) as parameter and
--returns all employees’ first and last names whose salary is above or equal to the given number. 

GO
CREATE PROC usp_GetEmployeesSalaryAboveNumber(@Number DECIMAL(18,4))
AS
BEGIN
	SELECT [FirstName], [LastName] FROM Employees
		WHERE [Salary] >= @Number
END
GO

EXEC usp_GetEmployeesSalaryAboveNumber 48100

-- 3.	Town Names Starting With
-- Write a stored procedure usp_GetTownsStartingWith that accept string as parameter and returns all town names starting with that string. 

GO
CREATE PROC usp_GetTownsStartingWith(@String NVARCHAR(50))
AS
BEGIN
	SELECT [Name] FROM Towns
		WHERE LEFT([Name], LEN(@String)) = @String
END
GO

EXEC usp_GetTownsStartingWith b

-- 4.	Employees from Town
--Write a stored procedure usp_GetEmployeesFromTown that accepts town name as parameter and return the employees’ first and last name that live in the given town. 

GO
CREATE PROC usp_GetEmployeesFromTown(@Town NVARCHAR(50))
AS
BEGIN
	SELECT FirstName, LastName FROM Employees e
		JOIN Addresses a ON e.AddressID = a.AddressID
		JOIN Towns t ON a.TownID = t.TownID
		WHERE t.Name = @Town
END
GO

EXEC usp_GetEmployeesFromTown Sofia

-- 5.	Salary Level Function
--Write a function ufn_GetSalaryLevel(@salary DECIMAL(18,4)) that receives salary of an employee and returns the level of the salary.
--•	If salary is < 30000 return "Low"
--•	If salary is between 30000 and 50000 (inclusive) return "Average"
--•	If salary is > 50000 return "High"

GO
CREATE FUNCTION ufn_GetSalaryLevel(@Salary DECIMAL(18,4))
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @SalaryOutput NVARCHAR(50)
	IF(@Salary < 30000)
		SET @SalaryOutput = 'Low'
	ELSE IF(@Salary BETWEEN 30000 AND 50000)
		SET @SalaryOutput = 'Average'
	ELSE
		SET @SalaryOutput = 'High'
RETURN @SalaryOutput
END
GO

-- DROP FUNCTION ufn_GetSalaryLevel

SELECT Salary, dbo.ufn_GetSalaryLevel(Salary) FROM Employees

-- 6.	Employees by Salary Level
--Write a stored procedure usp_EmployeesBySalaryLevel that receive as parameter level of salary (low, average or high)
--and print the names of all employees that have given level of salary. You should use the function - "dbo.ufn_GetSalaryLevel(@Salary) ",
--which was part of the previous task, inside your "CREATE PROCEDURE …" query.

GO
CREATE PROC usp_EmployeesBySalaryLevel(@Level NVARCHAR(50))
AS
BEGIN
	SELECT FirstName, LastName FROM
	(
		SELECT 
		FirstName,
		LastName,
		dbo.ufn_GetSalaryLevel(Salary) AS [SalaryLevel]
		FROM Employees

	) AS [SalaryLevelQuery]
	WHERE SalaryLevel = @Level
END
GO


-- DROP PROCEDURE usp_EmployeesBySalaryLevel
EXEC usp_EmployeesBySalaryLevel High

-- 7.	Define Function
--Define a function ufn_IsWordComprised(@setOfLetters, @word) that returns true or false depending on that if the word is a comprised of the given set of letters. 

GO
CREATE FUNCTION ufn_IsWordComprised(@SetOfLetters NVARCHAR(50), @Word NVARCHAR(50))
RETURNS BIT
AS
BEGIN
	DECLARE @Result BIT = 1
	DECLARE @Count INT = 1
	DECLARE @CurrentChar NVARCHAR(1)

	WHILE @Count <= LEN(@Word)
		BEGIN
			SET @CurrentChar = SUBSTRING(@Word, @Count,1)
			IF @SetOfLetters LIKE CONCAT('%', @CurrentChar, '%')
				SET @Count += 1
			ELSE
			BEGIN
				SET @Result = 0
				BREAK -- Important, lol
			END
		END
	RETURN @Result
END
GO

SELECT 'test', dbo.ufn_IsWordComprised('test', 'nest')

-- 8.	* Delete Employees and Departments
--Write a procedure with the name usp_DeleteEmployeesFromDepartment (@departmentId INT) which deletes all Employees from a given department.
--Delete these departments from the Departments table too.
--Finally SELECT the number of employees from the given department.
--If the delete statements are correct the select query should return 0.

GO
CREATE PROC usp_DeleteEmployeesFromDepartment(@DepartmentId INT)
AS
BEGIN
	WITH cte_Employees(EmployeeID)  -- Forever alone
	AS 
	(
		SELECT EmployeeID FROM Employees
		WHERE DepartmentID = @DepartmentId
	)

	DELETE FROM EmployeesProjects  
		WHERE EmployeeID IN (SELECT * FROM cte_Employees) 

	UPDATE Employees
		SET ManagerID = NULL
		WHERE ManagerID IN (	SELECT EmployeeID FROM Employees 
								WHERE DepartmentID = @DepartmentId) -- I honestly have no idea why it works with the first where clause but not here.
	
	ALTER TABLE Departments ALTER COLUMN ManagerID INT

	UPDATE Departments
	SET ManagerID = NULL
	WHERE ManagerID IN (		SELECT EmployeeID FROM Employees 
								WHERE DepartmentID = @DepartmentId) -- :(

	DELETE FROM Employees
	WHERE DepartmentID = @DepartmentId

	DELETE FROM Departments
	WHERE DepartmentID = @DepartmentId
		
	SELECT COUNT(*) AS [Count]
	FROM Employees
	WHERE DepartmentID = @DepartmentId

END
GO
