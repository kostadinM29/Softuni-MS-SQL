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

SELECT mm.Available FROM 
(
	SELECT
		j.MechanicId,
		CONCAT(FirstName, ' ',LastName) AS Available
	FROM Mechanics	m
		LEFT JOIN Jobs j ON m.MechanicId = j.MechanicId
		WHERE j.Status = 'Finished'
		GROpUP BY m.FirstName, m.LastName, j.MechanicId
) as mm
ORDER BY mm.MechanicId

-- ************************************************************************* unfinished work to be done

--9.	Past Expenses

SELECT  -- Yet again judge strikes back with the error (Invalid object name 'PartsNeeded'.)
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

-- ************************************************************************* unfinished work to be done

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
		JOIN Orders o ON op.OrderId= o.OrderId
		WHERE 
			j.Status != 'Finished'
			AND o.Delivered = 0
			AND pn.Quantity > (p.StockQty + op.Quantity)
		ORDER BY p.PartId ASC
		
) i
WHERE i.[Required] > (i.Ordered + i.[In Stock])
ORDER BY i.Id ASC

-- Im scrapping the prep exam for now. Need to solve 8,9,10