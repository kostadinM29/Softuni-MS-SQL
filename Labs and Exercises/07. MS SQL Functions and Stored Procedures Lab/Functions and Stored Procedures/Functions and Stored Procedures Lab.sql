-- 01. Salary Level Function
--Write a function ufn_GetSalaryLevel(@Salary MONEY) that receives salary of an employee and returns the level of the salary.
--If salary is < 30000 return "Low"
--If salary is between 30000 and 50000 (inclusive) returns "Average"
--If salary is > 50000 return "High"

CREATE FUNCTION udf_GetSalaryLevel(@Salary MONEY) 
RETURNS NVARCHAR(20)
BEGIN
	DECLARE @LevelOfSalary VARCHAR(20)
	IF (@Salary < 30000)
		SET @LevelOfSalary = 'Low'
	ELSE IF (@Salary BETWEEN 30000 AND 50000)
		SET @LevelOfSalary = 'Average'
	ELSE
		SET @LevelOfSalary = 'High'
RETURN @LevelOfSalary
END

--SELECT *,.udf_GetSalaryLevel(Salary)  FROM Employees

-- 02. Employees with Three Projects
--Create a procedure that assigns projects to an employee
--If the employee has more than 3 projects, throw an exception 

CREATE PROCEDURE usp_AssignProject(@EmployeeID INT, @ProjectID INT)
AS
BEGIN
	DECLARE @MaxProjects INT = 3, @EmployeeProjectsCount INT
	SET @EmployeeProjectsCount =
	(
	SELECT COUNT(*) 
	FROM [dbo].[EmployeesProjects] AS ep
	WHERE ep.EmployeeId = @EmployeeID
	)
	IF(@EmployeeProjectsCount >= @MaxProjects)
		THROW 50001, 'The employee has too many projects!', 1;

	INSERT INTO [dbo].[EmployeesProjects](EmployeeID, ProjectID)VALUES (@EmployeeID, @ProjectID)
END



