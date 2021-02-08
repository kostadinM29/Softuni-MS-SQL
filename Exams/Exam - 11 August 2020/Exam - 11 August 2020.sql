-- Section 1. DDL 

--1.	Database design
DROP DATABASE Bakery

CREATE DATABASE Bakery

Use Bakery

CREATE TABLE Countries
(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(50) UNIQUE NOT NULL
)

CREATE TABLE Customers
(
	Id INT PRIMARY KEY IDENTITY,
	FirstName NVARCHAR(25) NOT NULL,
	LastName NVARCHAR(25) NOT NULL,
	Gender VARCHAR(1) NOT NULL CHECK (Gender IN ('M', 'F')),
	Age INT NOT NULL,
	PhoneNumber VARCHAR(10) NOT NULL CHECK(LEN(PhoneNumber) = 10),
	CountryId INT REFERENCES Countries(Id)
)

CREATE TABLE Products
(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(25) UNIQUE NOT NULL,
	Description NVARCHAR(250) NOT NULL,
	Recipe NVARCHAR(MAX) NOT NULL,
	Price DECIMAL(18,4) NOT NULL CHECK(Price >= 0)
)

CREATE TABLE Feedbacks
(
	Id INT PRIMARY KEY IDENTITY,
	Description NVARCHAR(255),
	Rate DECIMAL(18,2) NOT NULL CHECK(Rate BETWEEN 0 AND 10),
	ProductId INT REFERENCES Products(Id),
	CustomerId INT REFERENCES Customers(Id)
)

CREATE TABLE Distributors
(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(25) UNIQUE NOT NULL,
	AddressText NVARCHAR(30) NOT NULL,
	Summary NVARCHAR(200) NOT NULL,
	CountryId INT REFERENCES Countries(Id)
)

CREATE TABLE Ingredients
(
	Id INT PRIMARY KEY IDENTITY,
	Name NVARCHAR(30) NOT NULL,
	Description NVARCHAR(200) NOT NULL,
	OriginCountryId INT REFERENCES Countries(Id),
	DistributorId INT REFERENCES Distributors(Id)
)

CREATE TABLE ProductsIngredients
(
	ProductId INT NOT NULL REFERENCES Products(Id),
	IngredientId INT NOT NULL REFERENCES Ingredients(Id),

	CONSTRAINT PK_ProductsIngridients PRIMARY KEY (ProductId,IngredientId)
)

--Section 2. DML 

--2.	Insert

INSERT INTO Distributors (Name,CountryId,AddressText,Summary) VALUES
	('Deloitte & Touche', 2, '6 Arch St #9757', 'Customizable neutral traveling'),
	('Congress Title', 13, '58 Hancock St', 'Customer loyalty'),
	('Kitchen People', 1, '3 E 31st St #77', 'Triple-buffered stable delivery'),
	('General Color Co Inc', 21, '6185 Bohn St #72', 'Focus group'),
	('Beck Corporation', 23, '21 E 64th Ave', 'Quality-focused 4th generation hardware')

INSERT INTO Customers (FirstName, LastName, Age, Gender, PhoneNumber, CountryId) VALUES
	('Francoise', 'Rautenstrauch', 15, 'M', '0195698399', 5),
	('Kendra', 'Loud', 22, 'F', '0063631526', 11),
	('Lourdes', 'Bauswell', 50, 'M', '0139037043', 8),
	('Hannah', 'Edmison', 18, 'F', '0043343686', 1),
	('Tom', 'Loeza', 31, 'M', '0144876096', 23),
	('Queenie', 'Kramarczyk', 30, 'F', '0064215793', 29),
	('Hiu', 'Portaro', 25, 'M', '0068277755', 16),
	('Josefa', 'Opitz', 43, 'F', '0197887645', 17)


--3.	Update

UPDATE Ingredients
	SET DistributorId = 35
	WHERE Name IN('Bay Leaf', 'Paprika', 'Poppy')
	
UPDATE Ingredients
	SET OriginCountryId = 14
	WHERE OriginCountryId = 8

--4.	Delete

	DELETE FROM Feedbacks
	WHERE CustomerId = 14 OR ProductId = 5

--Section 3. Querying 

--5.	Products by Price

SELECT Name,Price,Description FROM Products
	ORDER BY Price DESC,Name ASC

--6.	Negative Feedback

SELECT
	ProductId,
	Rate,
	Description,
	CustomerId,
	Age,
	Gender
FROM Feedbacks f
	JOIN Customers c on f.CustomerId = c.Id
WHERE Rate < 5
	ORDER BY ProductId DESC, Rate ASC

--7.	Customers without Feedback

SELECT 
	CONCAT(FirstName, ' ', LastName) AS CustomerName,
	PhoneNumber,
	Gender
FROM Customers c
	FULL JOIN Feedbacks f ON c.Id = f.CustomerId
WHERE  f.Id IS NULL
	ORDER BY CustomerId ASC -- not required for judge somehow 

--8.	Customers by Criteria

SELECT 
	FirstName,
	Age,
	PhoneNumber
FROM Customers
	WHERE 
		(AGE >= 21 AND
		FirstName LIKE N'%an%')
		OR
		(PhoneNumber LIKE N'%38' AND
		CountryId != 31)
	ORDER BY FirstName ASC, Age DESC

--9.	Middle Range Distributors


SELECT 
	d.Name AS DistributorName,
	i.Name AS IngredientName,
	p.Name AS ProductName,
	AVG(Rate) AS [AverageRate]
FROM Distributors d
	JOIN Ingredients i ON d.Id = i.DistributorId
	JOIN ProductsIngredients pi ON i.Id = pi.IngredientId
	JOIN Products p ON pi.ProductId = p.Id
	JOIN Feedbacks f ON p.Id = f.ProductId
	GROUP BY 
		d.Name,
		i.Name,
		p.Name
	HAVING AVG(Rate) BETWEEN 5 AND 8
	ORDER BY 
		d.Name ASC,
		i.Name ASC,
		p.Name ASC

--10.	Country Representative
SELECT 
	CountryName,
	DistributorName
FROM 
(
SELECT 
	c.Name AS CountryName,
	d.Name AS DistributorName,
	DENSE_RANK() OVER (PARTITION BY c.Name ORDER BY COUNT(i.Id) DESC) as [Rank]
FROM Countries c
	JOIN Distributors d ON c.Id = d.CountryId
	LEFT JOIN Ingredients i ON d.Id = i.DistributorId
	GROUP BY c.Name,d.Name
) as RankQuery
WHERE Rank = 1
ORDER BY 
	CountryName,
	DistributorName

--Section 4. Programmability 

--11.	Customers with Countries

GO
CREATE VIEW v_UserWithCountries
AS
(
SELECT 
	CONCAT(FirstName, ' ', LastName) AS CustomerName,
	Age,
	Gender,
	cc.Name
FROM Customers c
	JOIN Countries cc ON c.CountryId = cc.Id
)
GO
	--GROUP BY
	--	FirstName,
	--	LastName,
	--	Age,
	--	Gender,
	--	cc.Name

--12.	Delete Products

GO
CREATE TRIGGER tr_DeleteAllProductRelations
ON Products
INSTEAD OF DELETE
AS
BEGIN
	DECLARE @Product INT = (SELECT p.Id FROM Products p
								JOIN deleted d ON p.Id = d.Id)
	DELETE FROM Feedbacks
		WHERE ProductId = @Product	-- delete relations first

	DELETE FROM ProductsIngredients 
		WHERE ProductId = @Product

	DELETE FROM Products
		WHERE Id = @Product
END
GO


SELECT * FROM Products WHERE Id = 7

SELECT * FROM ProductsIngredients WHERE ProductId = 7

SELECT * FROM Feedbacks WHERE ProductId = 7
	
	
