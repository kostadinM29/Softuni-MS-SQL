USE Bank

-- Bank DB Queries

--01.	Create Table Logs
--Create a table – Logs (LogId, AccountId, OldSum, NewSum).
--Add a trigger to the Accounts table that enters a new entry into the Logs table every time the sum on an account changes.
--Submit only the query that creates the trigger.

CREATE TABLE Logs
(
	LogId INT PRIMARY KEY IDENTITY,
	AccountId INT NOT NULL REFERENCES Accounts(Id),
	OldSum MONEY,
	NewSum MONEY
)

GO
CREATE TRIGGER tr_AccountSumLog
ON Accounts
AFTER UPDATE
AS
BEGIN
	INSERT Logs(AccountId, OldSum, NewSum)
	SELECT inserted.Id, deleted.Balance, inserted.Balance
	FROM deleted, inserted
END
GO

--2.	Create Table Emails
--Create another table – NotificationEmails(Id, Recipient, Subject, Body). Add a trigger to logs table and create new email whenever new record is inserted in logs table.
--The following data is required to be filled for each email:
--•	Recipient – AccountId
--•	Subject – "Balance change for account: {AccountId}"
--•	Body - "On {date} your balance was changed from {old} to {new}."

CREATE TABLE NotificationEmails
(
	Id INT PRIMARY KEY IDENTITY,
	Recipient INT REFERENCES Accounts(Id),
	Subject VARCHAR(MAX),
	Body VARCHAR(MAX)
)

GO
CREATE TRIGGER tr_CreateEmailAfterLogTrigger
ON Logs
AFTER INSERT
AS
BEGIN
	INSERT NotificationEmails(Recipient, Subject, Body)
		SELECT inserted.AccountId,
			CONCAT('Balance change for account: ', CAST(inserted.AccountId AS VARCHAR(255))), 
			CONCAT('On ', GETDATE(), ' your balance was changed from ', inserted.OldSum, ' to ', inserted.NewSum)
		FROM inserted
END
GO

--3.	Deposit Money
--Add stored procedure usp_DepositMoney (AccountId, MoneyAmount) that deposits money to an existing account.
--Make sure to guarantee valid positive MoneyAmount with precision up to fourth sign after decimal point.
--The procedure should produce exact results working with the specified precision.

GO
CREATE PROC usp_DepositMoney (@AccountId INT, @MoneyAmount MONEY)
AS
BEGIN
	BEGIN TRAN
	UPDATE Accounts
		SET Balance += @MoneyAmount
		WHERE Accounts.Id = @AccountId
	COMMIT
END
GO

--4.	Withdraw Money
--Add stored procedure usp_WithdrawMoney (AccountId, MoneyAmount) that withdraws money from an existing account.
--Make sure to guarantee valid positive MoneyAmount with precision up to fourth sign after decimal point. 
--The procedure should produce exact results working with the specified precision.

GO
CREATE PROC usp_WithdrawMoney (@AccountId INT, @MoneyAmount MONEY)
AS
BEGIN
	BEGIN TRAN
	DECLARE @CurrentAccountBalance MONEY
		UPDATE Accounts
		SET Balance -= @MoneyAmount
		WHERE Accounts.Id = @AccountId
		
		SET @CurrentAccountBalance = (SELECT Balance FROM Accounts AS a WHERE a.Id = @AccountId)
		
		IF (@CurrentAccountBalance < 0)
			ROLLBACK
		ELSE
	COMMIT
END
GO

--5.	Money Transfer
--Write stored procedure usp_TransferMoney(SenderId, ReceiverId, Amount) that transfers money from one account to another.
--Make sure to guarantee valid positive MoneyAmount with precision up to fourth sign after decimal point.
--Make sure that the whole procedure passes without errors and if error occurs make no change in the database.
--You can use both: "usp_DepositMoney", "usp_WithdrawMoney" (look at previous two problems about those procedures). 

GO
CREATE PROC usp_TransferMoney (@SenderId INT, @ReceiverId INT, @Amount MONEY)
AS
BEGIN
	DECLARE @SenderBalance MONEY = (SELECT Balance FROM Accounts WHERE Id = @SenderId)
	BEGIN TRAN
		IF(@Amount < 0)
			ROLLBACK
		ELSE
		BEGIN
			IF(@SenderBalance - @amount >= 0)
			BEGIN
				EXEC usp_WithdrawMoney @senderId, @amount
				EXEC usp_DepositMoney @receiverId, @amount
				COMMIT
			END
			ELSE
			BEGIN
				ROLLBACK
			END
		END
END
GO

--Queries for Diablo Database

USE Diablo

--6.	Trigger
--1. Users should not be allowed to buy items with higher level than their level. Create a trigger that restricts that. 
--The trigger should prevent inserting items that are above specified level while allowing all others to be inserted.
--2. Add bonus cash of 50000 to users: baleremuda, loosenoise, inguinalself, buildingdeltoid, monoxidecos in the game "Bali".
--3. There are two groups of items that you must buy for the above users. The first are items with id between 251 and 299 including.
--Second group are items with id between 501 and 539 including.
--Take off cash from each user for the bought items.
--4. Select all users in the current game ("Bali") with their items. Display username, game name, cash and item name.
--Sort the result by username alphabetically, then by item name alphabetically. 


--1
 GO
CREATE TRIGGER tr_UserGameItems_LevelRestriction ON UserGameItems
INSTEAD OF UPDATE
AS
	BEGIN
		IF((SELECT Level FROM UsersGames  -- Check if Item Level > User Level
			WHERE Id =(SELECT UserGameId FROM inserted)) 
			<
			(SELECT MinLevel FROM Items WHERE Id = (SELECT ItemId FROM inserted)
          ))
                 RAISERROR('Your current level is not enough', 16, 1)
		ELSE
			INSERT INTO UserGameItems(ItemId,UserGameId) VALUES
			((SELECT ItemId FROM inserted),(SELECT UserGameId FROM inserted))
     END
GO

--2
UPDATE UsersGames
	SET Cash += 50000
FROM UsersGames AS ug
     JOIN Users AS u ON u.Id = ug.UserId
     JOIN Games AS g ON g.Id = ug.GameId
WHERE u.Username IN('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos')
AND g.Name = 'Bali'

--3
	SELECT * FROM Items
		WHERE ID BETWEEN 251 AND 299 
	SELECT * FROM Items
		WHERE ID BETWEEN 501 AND 539 

GO
CREATE PROC usp_BuyItem(@UserId INT , @ItemId INT, @GameId INT)
AS
BEGIN
	BEGIN TRAN
		DECLARE @User INT = (SELECT Id FROM Users WHERE Id = @UserId)
		DECLARE @Item INT = (SELECT Id FROM Items WHERE Id = @ItemId)
		DECLARE @Game INT = (SELECT Id FROM Games WHERE Id = @GameId)

		IF(@User IS NULL OR @Item IS NULL OR @Game IS NULL)
			BEGIN
				ROLLBACK
				RAISERROR('Invalid user or item or game Id',16,1) -- TODO 3 different ifs ?
				RETURN
			END

		DECLARE @UserCash DECIMAL(18,2) = (SELECT Cash FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
		

		DECLARE @ItemPrice DECIMAL(18,2) = (SELECT Price FROM Items WHERE Id = @ItemId)

		IF(@UserCash - @ItemPrice < 0)
			BEGIN
				ROLLBACK
				RAISERROR('Not enough money to buy item',16,2)
				RETURN
			END

		UPDATE UsersGames
			SET CASH -= @ItemPrice
			WHERE UserId = @UserId AND GameId = @GameId  -- Bali GameId

		DECLARE @UserGameId DECIMAL(18,2) = (SELECT Id FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)

		INSERT INTO UserGameItems(ItemId,UserGameId) VALUES
			(@ItemId,@UserGameId)
	COMMIT
END
GO

SELECT * FROM Users WHERE Username IN('baleremuda', 'loosenoise', 'inguinalself', 'buildingdeltoid', 'monoxidecos') -- Ids: 12,22,37,52,61

DECLARE @Counter INT = 251 -- itemId

WHILE(@Counter <= 299)
	BEGIN
		EXEC usp_BuyItem 1,@Counter,212 -- Bali GameId

		SET @Counter += 1
	END

-- Scrapping task because I can't test in judge and im not sure if I have errors

--7.	*Massive Shopping
--1.	User Stamat in Safflower game wants to buy some items. He likes all items from Level 11 to 12 as well as all items from Level 19 to 21.
--As it is a bulk operation you have to use transactions. 
--2.	A transaction is the operation of taking out the cash from the user in the current game as well as adding up the items. 
--3.	Write transactions for each level range. If anything goes wrong turn back the changes inside of the transaction.
--4.	Extract all of Stamat’s item names in the given game sorted by name alphabetically

DECLARE @User VARCHAR(MAX) = 'Stamat'
DECLARE @GameName VARCHAR(MAX) = 'Safflower'
DECLARE @UserId INT = (SELECT Id FROM Users WHERE Username = @User)
DECLARE @GameId INT = (SELECT Id FROM Games WHERE Name = @GameName)
DECLARE @UserMoney MONEY = (SELECT Cash FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
DECLARE @ItemsBulkPrice MONEY
DECLARE @UserGameId INT = (SELECT Id FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)

BEGIN TRAN 
		SET @ItemsBulkPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 11 AND 12) --11 to 12
		IF (@UserMoney - @ItemsBulkPrice >= 0)
		BEGIN
			INSERT INTO UserGameItems(ItemId,UserGameId) -- no values?
			(SELECT i.Id, @UserGameId FROM Items AS i
			WHERE i.id IN (Select Id FROM Items WHERE MinLevel BETWEEN 11 AND 12))
			UPDATE UsersGames
			SET Cash -= @ItemsBulkPrice
			WHERE GameId = @GameId AND UserId = @UserId
			COMMIT
		END
		ELSE
		BEGIN
			ROLLBACK
		END
			

SET @UserMoney = (SELECT Cash FROM UsersGames WHERE UserId = @UserId AND GameId = @GameId)
BEGIN TRAN  
		SET @ItemsBulkPrice = (SELECT SUM(Price) FROM Items WHERE MinLevel BETWEEN 19 AND 21) --19 to 21
		IF (@UserMoney - @ItemsBulkPrice >= 0)
		BEGIN
			INSERT UserGameItems(ItemId,UserGameId)
			SELECT i.Id, @UserGameId FROM Items AS i
			WHERE i.id IN (Select Id FROM Items WHERE MinLevel BETWEEN 19 AND 21)
			UPDATE UsersGames
			SET Cash -= @ItemsBulkPrice
			WHERE GameId = @GameId AND UserId = @UserId
			COMMIT
		END
		ELSE
		BEGIN
			ROLLBACK
		END

 SELECT Name AS 'Item Name' FROM Items
 WHERE Id IN (SELECT ItemId FROM UserGameItems WHERE UserGameId = @UserGameId)
 ORDER BY [Item Name]


-- Queries for SoftUni Database

USE SoftUni

--8.	Employees with Three Projects
--Create a procedure usp_AssignProject(@emloyeeId, @projectID) that assigns projects to employee.
--If the employee has more than 3 project throw exception and rollback the changes.
--The exception message must be: "The employee has too many projects!" with Severity = 16, State = 1.

GO
CREATE PROC usp_AssignProject (@EmloyeeId INT, @ProjectID INT)
AS
BEGIN
	BEGIN TRAN
		IF ((SELECT Count(*) FROM Employees e 
			JOIN EmployeesProjects ep ON e.EmployeeID = ep.EmployeeID
			JOIN Projects p ON ep.ProjectID = p.ProjectID
			WHERE e.EmployeeID = @EmloyeeId)
			>= 3)
			BEGIN
				ROLLBACK
				RAISERROR('The employee has too many projects!', 16,1)
				RETURN
			END
		ELSE
		INSERT INTO EmployeesProjects VALUES -- columns not specified
		(@EmloyeeId, @ProjectID)
	COMMIT
END
GO


--9.	Delete Employees
--Create a table Deleted_Employees(EmployeeId PK, FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
--that will hold information about fired (deleted) employees from the Employees table.
--Add a trigger to Employees table that inserts the corresponding information about the deleted records in Deleted_Employees.

CREATE TABLE Deleted_Employees
(
 EmployeeId INT PRIMARY KEY IDENTITY,
 FirstName VARCHAR(50), 
 LastName VARCHAR(50), 
 MiddleName VARCHAR(50), 
 JobTitle VARCHAR(50), 
 DepartmentId INT, 
 Salary MONEY
)

GO
CREATE TRIGGER tr_DeleteEmployee ON Employees AFTER DELETE
AS
INSERT INTO Deleted_Employees(FirstName, LastName, MiddleName, JobTitle, DepartmentId, Salary)
SELECT d.FirstName, d.LastName, d.MiddleName, d.JobTitle, d.DepartmentID, d.Salary 
FROM deleted AS d
GO

SELECT * FROM Deleted_Employees
DELETE FROM Employees
WHERE EmployeeID = 1
