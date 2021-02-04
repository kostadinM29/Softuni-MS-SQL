--Section 1. DDL (30 pts)



CREATE DATABASE TripService

USE TripService

--1. Database design
CREATE TABLE Cities
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(20) NOT NULL,
CountryCode VARCHAR(2) NOT NULL,
)

CREATE TABLE Hotels
(
Id INT PRIMARY KEY IDENTITY,
Name NVARCHAR(30) NOT NULL,
CityId INT NOT NULL REFERENCES Cities(Id),
EmployeeCount INT NOT NULL,
BaseRate DECIMAL(18,2)
)

CREATE TABLE Rooms
(
Id INT PRIMARY KEY IDENTITY,
Price DECIMAL(18,2) NOT NULL,
Type NVARCHAR(20) NOT NULL,
Beds INT NOT NULL,
HotelId INT NOT NULL REFERENCES Hotels(Id)
)

CREATE TABLE Trips
(
Id INT PRIMARY KEY IDENTITY,
RoomId INT NOT NULL REFERENCES Rooms(Id),
BookDate DATETIME2 NOT NULL,
ArrivalDate DATETIME2 NOT NULL,
ReturnDate DATETIME2 NOT NULL,
CancelDate DATETIME2,

CONSTRAINT BookDate_ArrivalDate CHECK(BookDate < ArrivalDate),
CONSTRAINT ArrivalDate_ReturnDate CHECK(ArrivalDate < ReturnDate)
)

CREATE TABLE Accounts
(
Id INT PRIMARY KEY IDENTITY,
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(20),
LastName NVARCHAR(50) NOT NULL,
CityId INT NOT NULL REFERENCES Cities(Id),
BirthDate DATE NOT NULL,
Email VARCHAR(100) NOT NULL UNIQUE
)

CREATE TABLE AccountsTrips
(
AccountId INT NOT NULL REFERENCES Accounts(Id),
TripId INT NOT NULL REFERENCES Trips(Id),
Luggage INT NOT NULL,

CONSTRAINT Luggage_Check CHECK(Luggage >= 0),
CONSTRAINT PK_AccountTrips PRIMARY KEY (AccountId, TripId)
)

--Section 2. DML (10 pts)

--2. Insert

INSERT INTO Accounts(FirstName,MiddleName,LastName,CityId,BirthDate,Email) VALUES
('John','Smith', 'Smith', 34, '1975-07-21', 'j_smith@gmail.com'),
('Gosho', NULL, 'Petrov', 11, '1978-05-16', 'g_petrov@gmail.com'),
('Ivan', 'Petrovich', 'Pavlov', 59, '1849-09-26', 'i_pavlov@softuni.bg'),
('Friedrich', 'Wilhelm', 'Nietzsche', 2, '1844-10-15', 'f_nietzsche@softuni.bg')

INSERT INTO Trips (RoomId,BookDate,ArrivalDate,ReturnDate,CancelDate) VALUES
(101, '2015-04-12', '2015-04-14', '2015-04-20', '2015-02-02'),
(102, '2015-07-07', '2015-07-15', '2015-07-22', '2015-04-29'),
(103, '2013-07-17', '2013-07-23', '2013-07-24', NULL),
(104, '2012-03-17', '2012-03-31', '2012-04-01', '2012-01-10'),
(109, '2017-08-07', '2017-08-28', '2017-08-29', NULL)

--3. Update

UPDATE Rooms
	SET Price *= 1.14
	WHERE HotelId IN(5,7,9)

--4. Delete

DELETE FROM AccountsTrips
	WHERE AccountId = 47

DELETE FROM Accounts
	WHERE Id = 47

--Section 3. Querying (40 pts)

--5. EEE-Mails

SELECT
	FirstName,
	LastName,
	FORMAT(BirthDate,'MM-dd-yyyy') AS BirthDate,
	c.Name AS Hometown,
	Email
FROM Accounts a
	LEFT JOIN Cities c ON A.CityId = c.Id
	WHERE Email LIKE N'e%'
	ORDER BY Hometown ASC

--6. City Statistics

SELECT 
	c.Name,
	COUNT(*) as Hotels
FROM Cities c
	JOIN Hotels h ON c.Id = h.CityId
	GROUP BY c.Name
	ORDER BY 
		Hotels DESC,
		c.Name ASC


--7. Longest and Shortest Trips

SELECT
	A.Id AS AccountId,
	CONCAT(FirstName,' ',LastName) AS [FullName],
	MAX(DATEDIFF(DAY,ArrivalDate,ReturnDate)) AS LongestTrip,
	MIN(DATEDIFF(DAY,ArrivalDate,ReturnDate)) AS ShortestTrip
FROM Accounts a
	JOIN AccountsTrips at ON a.Id = at.AccountId
	JOIN Trips t ON at.TripId = t.Id
WHERE MiddleName IS NULL AND CancelDate IS NULL
	GROUP BY 
		a.Id,
		a.FirstName,
		a.LastName
	ORDER BY
		LongestTrip DESC,
		ShortestTrip ASC

--8. Metropolis

SELECT TOP 10
	c.Id,
	c.Name AS City,
	c.CountryCode AS Country,
	COUNT(A.Id) AS Accounts
FROM Cities c
	JOIN Accounts a ON c.Id = a.CityId
	GROUP BY
		c.Id,
		c.Name,
		c.CountryCode
	ORDER BY COUNT(A.Id) DESC

--9. Romantic Getaways

SELECT 
	a.Id,
	a.Email,
	c.Name AS City,
	COUNT(t.Id) AS Trips
FROM Accounts a
	JOIN AccountsTrips at ON a.Id = at.AccountId
	JOIN Trips t ON at.TripId = t.Id
	JOIN Rooms r ON t.RoomId = r.Id
	JOIN Hotels h ON r.HotelId = h.Id
	JOIN Cities c ON h.CityId = c.Id AND a.CityId = c.Id
GROUP BY
	a.Id,
	a.Email,
	c.Name
ORDER BY 
	Trips DESC,
	a.Id ASC

--10. GDPR Violation

SELECT 
	t.Id,
	CONCAT(a.FirstName,' ',ISNULL(a.MiddleName, ''),a.LastName) AS [Full Name],
	c.Name AS [From],
	(
	SELECT cc.Name FROM  Trips tt
		JOIN AccountsTrips atat ON t.Id = atat.TripId
		JOIN Accounts aa ON atat.AccountId = aa.Id
		JOIN Rooms rr ON tt.RoomId = rr.Id
		JOIN Hotels hh ON rr.HotelId = hh.Id
		JOIN Cities cc ON hh.CityId = cc.Id
		WHERE tt.Id = t.Id AND aa.Id = a.Id AND hh.Id = h.Id
		) AS [To],
	CASE 
		WHEN CancelDate IS NOT NULL THEN 'Canceled' -- if not null it means its cancelled
		ELSE CONVERT(NVARCHAR ,DATEDIFF(DAY,ArrivalDate,ReturnDate)) + ' days'
	END AS [Duration]
FROM Trips t
	JOIN AccountsTrips at ON t.Id = at.TripId
	JOIN Accounts a ON at.AccountId = a.Id
	JOIN Rooms r ON t.RoomId = r.Id
	JOIN Hotels h ON r.HotelId = h.Id
	JOIN Cities c ON h.CityId = c.Id
	ORDER BY 
		[Full Name] ASC, 
		t.Id ASC
	
--Section 4. Programmability (14 pts)

--11. Available Room

GO
CREATE FUNCTION udf_GetAvailableRoom(@HotelId INT, @Date DATE, @People INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @RoomId INT =
	(
	SELECT TOP 1 r.Id FROM Trips t
		JOIN Rooms r ON t.RoomId = r.Id
		JOIN Hotels h ON r.HotelId = h.Id
		WHERE h.Id = @HotelId
			AND @Date NOT BETWEEN t.ArrivalDate AND t.ReturnDate 
			AND t.CancelDate IS NULL
			AND r.Beds >= @People 
			AND YEAR(@Date) = YEAR(t.ArrivalDate) -- No idea what this does to the logic, but ok ( I think it checks if the room is available to be rented (from other trip records???)
			ORDER BY r.Price DESC
	)

	IF @RoomId IS NULL
	BEGIN
		RETURN 'No rooms available'
	END

	DECLARE @RoomPrice DECIMAL(18,2) = (SELECT Price FROM Rooms WHERE Id = @RoomId)

	DECLARE @RoomType VARCHAR(50) = (SELECT [Type] FROM Rooms WHERE Id = @RoomId)

	DECLARE @BedsCount INT = (SELECT Beds FROM Rooms WHERE Id = @RoomId)

	DECLARE @HotelBaseRate DECIMAL(18,2) = (SELECT BaseRate FROM Hotels WHERE Id = @HotelId)

	DECLARE @TotalPrice DECIMAL(18,2) = (@HotelBaseRate + @RoomPrice) * @People

	-- •	“Room {Room Id}: {Room Type} ({Beds} beds) - ${Total Price}”
	RETURN CONCAT
	(
		'Room ', CONVERT(VARCHAR(20),@RoomId),
		': ', @RoomType, 
		' (', CONVERT(VARCHAR(20),@BedsCount), ' beds)',
		' - $', CONVERT(VARCHAR(50),@TotalPrice)
	)
END
GO


SELECT dbo.udf_GetAvailableRoom(112, '2011-12-17', 2)

SELECT dbo.udf_GetAvailableRoom(94, '2015-07-26', 3)

SELECT * FROM Hotels h
	JOIN Rooms r ON h.Id = r.HotelId
	JOIN Trips t ON r.Id = t.RoomId
	WHERE h.Id= 112
	SELECT * FROM Hotels h
	JOIN Rooms r ON h.Id = r.HotelId
	JOIN Trips t ON r.Id = t.RoomId
	WHERE h.Id= 94


--12. Switch Room

GO
CREATE PROC usp_SwitchRoom(@TripId INT, @TargetRoomId INT)
AS
BEGIN
	-- CHECK 

	DECLARE @CurrentRoomId INT = (	SELECT TOP 1 r.HotelId FROM Trips t
									JOIN Rooms r ON t.RoomId = r.Id
									JOIN Hotels h ON r.HotelId = h.Id
									WHERE t.Id = 10) 
	DECLARE @RequestedHotelId INT = (SELECT HotelId FROM Rooms WHERE Id = @TargetRoomId)

	DECLARE @RequestedHotelBeds INT = (SELECT Beds FROM Rooms WHERE Id = @TargetRoomId)

	DECLARE @TripAccounts INT = (SELECT COUNT(*) FROM AccountsTrips WHERE TripId = @TripId) -- people on the trip

	IF @RequestedHotelId != @CurrentRoomId
	BEGIN
        ;THROW 50001, 'Target room is in another hotel!', 1
	END  

	ELSE IF @RequestedHotelBeds < @TripAccounts      
	BEGIN
		;THROW 50002, 'Not enough beds in target room!', 1
	END

	ELSE
	BEGIN
		 UPDATE Trips
            SET RoomId = @TargetRoomId
            WHERE Id = @TripId
	END
END
GO

EXEC usp_SwitchRoom 10, 11
SELECT RoomId FROM Trips WHERE Id = 10

EXEC usp_SwitchRoom 10, 7

EXEC usp_SwitchRoom 10, 8