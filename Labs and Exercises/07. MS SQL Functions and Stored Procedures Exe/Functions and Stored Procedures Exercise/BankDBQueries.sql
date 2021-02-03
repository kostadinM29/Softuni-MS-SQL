-- Queries for Bank Database
USE Bank
GO

-- 9.	Find Full Name
--You are given a database schema with tables AccountHolders(Id (PK), FirstName, LastName, SSN) and Accounts(Id (PK), AccountHolderId (FK), Balance).
--Write a stored procedure usp_GetHoldersFullName that selects the full names of all people. 

GO
CREATE PROC usp_GetHoldersFullName
AS
BEGIN
	SELECT CONCAT(FirstName, ' ', LastName) AS [Full Name] FROM AccountHolders
END
GO

EXEC usp_GetHoldersFullName

-- 10.	People with Balance Higher Than
--Your task is to create a stored procedure usp_GetHoldersWithBalanceHigherThan 
--that accepts a number as a parameter and returns all people who have more money in total of all their accounts than the supplied number.
--Order them by first name, then by last name.

GO
CREATE PROC usp_GetHoldersWithBalanceHigherThan(@Number MONEY) -- Important data type
AS
BEGIN
	SELECT FirstName AS [First Name], LastName AS [Last Name] FROM AccountHolders ac
		JOIN 
		(
			SELECT 
				AccountHolderId,
				SUM(Balance) AS [BalanceSum]
			FROM Accounts
			GROUP BY AccountHolderId
		) AS [GroupQuery] 
		ON ac.Id = [GroupQuery].AccountHolderId
	WHERE BalanceSum > @Number
	ORDER BY
		FirstName ASC,
		LastName ASC
END
GO

EXEC usp_GetHoldersWithBalanceHigherThan 30000

-- 11. Future Value Function
--Your task is to create a function ufn_CalculateFutureValue that accepts as parameters – sum (decimal), yearly interest rate (float) and number of years(int).
--It should calculate and return the future value of the initial sum rounded to the fourth digit after the decimal delimiter.
--Using the following formula:
--FV=I?((1+R)^T)
--	I – Initial sum
--	R – Yearly interest rate
--	T – Number of years

GO
CREATE FUNCTION ufn_CalculateFutureValue
(
	@Sum				MONEY, -- decimal?
	@YearlyInterestRate FLOAT,
	@NumberOfYears		INT
)
RETURNS DECIMAL(18,4)
AS
BEGIN
	DECLARE @FutureValue DECIMAL(18,4)
	SET @FutureValue = @Sum *(POWER(1 + @YearlyInterestRate, @NumberOfYears))

	RETURN @FutureValue
END
GO

 SELECT dbo.ufn_CalculateFutureValue(1000,0.1,5)

-- 12.	Calculating Interest
--Your task is to create a stored procedure usp_CalculateFutureValueForAccount that uses the function from the previous problem to give an interest to a person's account
--for 5 years, along with information about his/her account id, first name, last name and current balance as it is shown in the example below.
--It should take the AccountId and the interest rate as parameters.
--Again you are provided with “dbo.ufn_CalculateFutureValue” function which was part of the previous task.

GO
CREATE PROC usp_CalculateFutureValueForAccount
(
	@AccountId INT,
	@YearlyInterestRate FLOAT
)
AS
BEGIN
	DECLARE @NumberOfYears INT = 5
	SELECT 
		a.Id AS [Account Id],
		ah.FirstName AS [First Name],
		ah.LastName AS [Last Name],
		a.Balance AS [Current Balance],
		dbo.ufn_CalculateFutureValue(a.Balance, @YearlyInterestRate, @NumberOfYears) AS [Balance in 5 years]
	FROM Accounts a
		JOIN  AccountHolders ah ON a.AccountHolderId = ah.Id
	WHERE a.Id = @AccountId
END
GO

EXEC usp_CalculateFutureValueForAccount 1, 0.1

