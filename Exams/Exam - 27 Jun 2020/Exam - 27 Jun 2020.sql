--Section 1. DDL 

--1.	Database design

CREATE DATABASE WMS

USE WMS

CREATE TABLE Clients
(
	ClientId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	Phone NVARCHAR(12) NOT NULL,
	
	CONSTRAINT Phone_Must_Be_12 CHECK(LEN(Phone) = 12)
)

CREATE TABLE Mechanics
(
	MechanicId INT PRIMARY KEY IDENTITY,
	FirstName VARCHAR(50) NOT NULL,
	LastName VARCHAR(50) NOT NULL,
	[Address] VARCHAR(255) NOT NULL
)

CREATE TABLE Models
(
	ModelId INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL UNIQUE
)

CREATE TABLE Jobs
(
	JobId INT PRIMARY KEY IDENTITY,
	ModelId INT NOT NULL REFERENCES Models(ModelId),
	[Status] VARCHAR(11) NOT NULL DEFAULT 'Pending',
	ClientId INT NOT NULL REFERENCES Clients(ClientId),
	MechanicId INT REFERENCES Mechanics(MechanicId),
	IssueDate DATETIME2 NOT NULL,
	FinishDate DATETIME2,

	CONSTRAINT Status_Values CHECK([Status] IN ('Pending', 'In Progress', 'Finished'))
)

CREATE TABLE Orders
(
	OrderId INT PRIMARY KEY IDENTITY,
	JobId INT NOT NULL REFERENCES Jobs(JobId),
	IssueDate DATETIME2,
	Delivered BIT DEFAULT 0
)

CREATE TABLE Vendors 
(
	VendorId INT PRIMARY KEY IDENTITY,
	[Name] VARCHAR(50) NOT NULL UNIQUE 
)

CREATE TABLE Parts
(
	PartId INT PRIMARY KEY IDENTITY,
	SerialNumber VARCHAR(50) NOT NULL UNIQUE,
	[Description] VARCHAR(255),
	Price DECIMAL(6,2) NOT NULL, 
	VendorId INT NOT NULL REFERENCES Vendors(VendorId),
	StockQty INT NOT NULL DEFAULT 0,
	
	CONSTRAINT Price_Cant_Be_Negative_Or_Zero CHECK(Price > 0),
	CONSTRAINT Stock_Cant_Be_Negative CHECK(StockQty >= 0)
)

CREATE TABLE OrderParts
(
	OrderId INT NOT NULL REFERENCES Orders(OrderId),
	PartId INT NOT NULL REFERENCES Parts(PartId),
	Quantity INT NOT NULL DEFAULT 1,

	CONSTRAINT PK_OrderId_PartId PRIMARY KEY (OrderId, PartId),
	CONSTRAINT Quantity_Cant_Be_Negative_Or_Zero CHECK(Quantity > 0)
)

CREATE TABLE PartsNeeded 
(
	JobId INT NOT NULL REFERENCES Jobs(JobId),
	PartId INT NOT NULL REFERENCES Parts(PartId),
	Quantity INT NOT NULL DEFAULT 1,

	CONSTRAINT PK_JobId_PartId PRIMARY KEY (JobId, PartId),
	CONSTRAINT Quantity_Cant_Be_Negative_Or_Zero2 CHECK(Quantity > 0)
)


--Section 2. DML

-- 2.	Insert

INSERT INTO Clients(FirstName, LastName,Phone) VALUES
	('Teri', 'Ennaco', '570-889-5187'),
	('Merlyn', 'Lawler', '201-588-7810'),
	('Georgene', 'Montezuma', '925-615-5185'),
	('Jettie', 'Mconnell', '908-802-3564'),
	('Lemuel', 'Latzke', '631-748-6479'),
	('Melodie', 'Knipp', '805-690-1682'),
	('Candida', 'Corbley', '908-275-8357')

INSERT INTO Parts(SerialNumber, Description, Price, VendorId) VALUES
	('WP8182119', 'Door Boot Seal', 117.86, 2),
	('W10780048', 'Suspension Rod', 42.81, 1),
	('W10841140', 'Silicone Adhesive', 6.77, 4),
	('WPY055980', 'High Temperature Adhesive', 13.94, 3)

--3.	Update

-- ID 3


UPDATE Jobs
	SET MechanicId = 3, Status = 'In Progress'
	WHERE Status = 'Pending'

--4.	Delete

DELETE FROM OrderParts
	WHERE OrderId = 19

DELETE FROM Orders
	WHERE OrderId = 19

--Section 3. Querying

--5.	Mechanic Assignments

SELECT 
	CONCAT(FirstName, ' ',LastName) AS Mechanic,
	j.Status,
	IssueDate
FROM Mechanics m
	JOIN Jobs j ON m.MechanicId = j.MechanicId
	ORDER BY
		m.MechanicId ASC,
		IssueDate ASC,
		j.JobId ASC
		

--6.	Current Clients

SELECT 
	CONCAT(FirstName, ' ',LastName) AS Client,
	DATEDIFF(DAY,IssueDate,'2017-04-24') AS [Days going],
	Status
FROM Clients c
	JOIN Jobs j ON c.ClientId = j.ClientId
	WHERE [Status] != 'Finished'


--7.	Mechanic Performance

SELECT
	avg.Mechanic,
	avg.[Average Days]
FROM
(
	SELECT 
		m.MechanicId as[Id],
		CONCAT(FirstName, ' ',LastName) AS Mechanic,
		AVG(DATEDIFF(DAY,IssueDate,FinishDate)) AS [Average Days]
	FROM Mechanics m
		JOIN Jobs j ON m.MechanicId = j.MechanicId
		WHERE Status = 'Finished'
		GROUP BY FirstName, LastName, m.MechanicId -- subquery unnecessary

	) AS Avg
ORDER BY Avg.Id

--8.	Available Mechanics

SELECT Available FROM  -- Judge doesn't like STRING_AGG
(
	SELECT 
		m.MechanicId,
		CONCAT(FirstName, ' ',LastName) AS Available,
		STRING_AGG(j.Status,' ') AS String
	FROM Mechanics	m
		JOIN Jobs j ON m.MechanicId = j.MechanicId
		GROUP BY CONCAT(FirstName, ' ',LastName),m.MechanicId
) AS S
WHERE String NOT LIKE '%In Progress%'
ORDER BY S.MechanicId ASC


	SELECT ---- Stupid way 
		CONCAT(FirstName, ' ',LastName) AS Available
	FROM Mechanics	m
		LEFT JOIN Jobs j ON m.MechanicId = j.MechanicId
		WHERE j.JobId IS NULL OR (SELECT COUNT(JobId) FROM Jobs 
											WHERE Status <> 'Finished' AND MechanicId = j.MechanicId
											GROUP BY MechanicId,Status) IS NULL
	GROUP BY m.MechanicId , FirstName,LastName


--9.	Past Expenses

SELECT  -- Yet again judge strikes back with the error (Invalid object name 'PartsNeeded'.) -- After looking into I shouldn't use partsneeded anyway this is why.
	j.JobId,
	SUM(p.Price) AS Total
FROM Jobs j
	JOIN PartsNeeded pn ON j.JobId = pn.JobId
	JOIN Parts p ON pn.PartId = p.PartId
	WHERE j.Status = 'Finished'
	GROUP BY j.JobId
	ORDER BY 
		Total DESC,
		j.JobId ASC

SELECT  -- working
	o.JobId, 
	SUM(op.Quantity*p.Price) AS [Total] 
FROM Jobs j
	JOIN Orders o ON j.JobId = o.JobId
	JOIN OrderParts op ON o.OrderId = op.OrderId
	JOIN Parts p ON op.PartId = p.PartId
	WHERE j.Status = 'Finished'
GROUP BY o.JobId
ORDER BY 
	[Total] DESC, 
	o.JobId ASC
------------------------------------------------

SELECT -- working 
	j.JobId,
	IIF(Delivered IS NULL,0.00,SUM(p.Price * op.Quantity)) AS [Total]
	--CASE
	--	WHEN o.Delivered = 1 THEN SUM(p.Price * op.Quantity)
	--	WHEN o.Delivered = 0 THEN SUM(p.Price * op.Quantity)
	--	WHEN o.Delivered IS NULL THEN 0.00
	--	END AS [Total]
FROM Jobs j
	LEFT JOIN Orders o ON j.JobId = o.JobId
	LEFT JOIN OrderParts op ON o.OrderId = op.OrderId
	LEFT JOIN Parts p ON op.PartId = p.PartId
	WHERE j.Status = 'Finished'
	GROUP BY j.JobId,o.Delivered
	ORDER BY 
	[Total] DESC, 
	j.JobId ASC

-- IT IS OVER



-- 10.	Missing Parts
SELECT * FROM
(
	SELECT 
		p.PartId AS Id,
		p.[Description],
		pn.Quantity AS [Required],
		p.StockQty AS [In Stock],
		op.Quantity AS [Ordered]
	FROM Jobs j
		JOIN PartsNeeded pn ON j.JobId = pn.JobId
		JOIN Parts p ON pn.PartId = p.PartId
		JOIN OrderParts op ON p.PartId = op.PartId
		LEFT JOIN Orders o ON op.OrderId= o.OrderId
		WHERE 
			j.Status <> 'Finished'
			AND o.Delivered = 0
			AND pn.Quantity > (p.StockQty + op.Quantity)
		
) i
WHERE i.[Required] > (i.Ordered + i.[In Stock])
ORDER BY i.Id ASC

SELECT  -- working
		p.PartId AS Id,
		p.[Description],
		pn.Quantity AS [Required],
		p.StockQty AS [In Stock],
		IIF(o.Delivered = 0,op.Quantity, 0) AS [Ordered]
FROM Parts p
	LEFT JOIN PartsNeeded pn ON pn.PartId = p.PartId
	LEFT JOIN OrderParts op ON p.PartId = op.PartId
	LEFT JOIN Jobs j ON pn.JobId = j.JobId
	LEFT JOIN Orders o ON j.JobId = o.JobId
	WHERE j.Status != 'Finished' 
		AND p.StockQty + IIF(o.Delivered = 0,op.Quantity, 0) < pn.Quantity 
	ORDER BY p.PartId ASC
		


-- Section 4. Programmability

--11.	Place Order

GO
CREATE PROC usp_PlaceOrder
(
	@JobId INT,
	@SerialNumber VARCHAR(50),
	@Quantity INT
)
AS
BEGIN TRANSACTION
DECLARE @Status VARCHAR(20) = (SELECT Status FROM Jobs WHERE JobId = @JobId)

DECLARE @PartId VARCHAR(20) = (Select PartId FROM Parts WHERE SerialNumber = @SerialNumber)

IF(@Status = 'Finished')
	BEGIN
		ROLLBACK;
		THROW 50011, 'This job is not active!', 1
	END
ELSE IF(@Quantity <= 0)
	BEGIN
		ROLLBACK;
		THROW 50012, 'Part quantity must be more than zero!', 1
	END
ELSE IF(@Status IS NULL)
	BEGIN
		ROLLBACK;
		THROW 50013, 'Job not found!',1 
	END
ELSE IF(@PartId IS NULL)
	BEGIN
		ROLLBACK;
		THROW 50014, 'Part not found!', 1
	END

DECLARE @OrderId INT	

IF EXISTS(SELECT TOP(1)OrderId FROM Orders WHERE JobId = @JobId AND IssueDate IS NULL)  -- if order already exists
	BEGIN
		SET @OrderId = (SELECT TOP(1)o.OrderId FROM Orders o
							WHERE JobId = @JobId AND IssueDate IS NULL)

		IF NOT EXISTS(SELECT PartId FROM OrderParts WHERE OrderId = @OrderId AND PartId = @PartId) -- if part not already in order
			BEGIN
				INSERT INTO OrderParts(OrderId,PartId,Quantity) VALUES
				(@OrderId, @PartId,@Quantity)
			END
		ELSE -- if part is already in order
			BEGIN
				UPDATE OrderParts
				SET Quantity += @Quantity
				WHERE OrderId = @OrderId AND PartId = @PartId
			END
	END
ELSE  -- order does not exist
	BEGIN
		INSERT INTO Orders(JobId,IssueDate) VALUES
		(@JobId, NULL)

		SET @OrderId = (SELECT OrderId FROM Orders WHERE @JobId = JobId AND IssueDate IS NULL)

		INSERT INTO OrderParts(OrderId,PartId,Quantity) VALUES
		(@OrderId, @PartId,@Quantity)
	END
COMMIT
GO

--12.	Cost Of Order 

GO
CREATE FUNCTION udf_GetCost(@JobId INT)
RETURNS DECIMAL(18,2)
AS
BEGIN
	DECLARE @Result DECIMAL(18,2)
	SET @Result =
	(
		SELECT 
			SUM(p.Price * op.Quantity)
		FROM Jobs j
			JOIN Orders o ON j.JobId = o.JobId
			JOIN OrderParts op ON o.OrderId = op.OrderId
			JOIN Parts p ON op.PartId = p.PartId
			WHERE j.JobId = @JobId

	)
	IF (@Result IS NULL)
		SET @Result = 0

	RETURN @Result
END
GO
