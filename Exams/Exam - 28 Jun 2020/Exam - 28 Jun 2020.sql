--Section 1. DDL 
CREATE DATABASE ColonialJourney

GO
--1.	Database Design
CREATE TABLE Planets
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(30) NOT NULL
)

CREATE TABLE Spaceports
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL,
PlanetId INT FOREIGN KEY REFERENCES Planets(Id)
)

CREATE TABLE Spaceships
(
Id INT PRIMARY KEY IDENTITY,
Name VARCHAR(50) NOT NULL,
Manufacturer VARCHAR(30) NOT NULL,
LightSpeedRate INT DEFAULT 0
)

CREATE TABLE Colonists
(
Id INT PRIMARY KEY IDENTITY,
FirstName VARCHAR(20) NOT NULL,
LastName VARCHAR(20) NOT NULL,
Ucn VARCHAR(10) UNIQUE NOT NULL,
BirthDate DATE NOT NULL
)

CREATE TABLE Journeys
(
Id INT PRIMARY KEY IDENTITY,
JourneyStart DATETIME2 NOT NULL,
JourneyeND DATETIME2 NOT NULL,
Purpose VARCHAR(11),
CHECK(Purpose IN ('Medical', 'Technical', 'Educational', 'Military')),
DestinationSpaceportId INT NOT NULL FOREIGN KEY REFERENCES Spaceports(Id),
SpaceshipId INT NOT NULL FOREIGN KEY REFERENCES Spaceships(Id),
)

CREATE TABLE TravelCards
(
Id INT PRIMARY KEY IDENTITY,
CardNumber VARCHAR(10) UNIQUE NOT NULL,
JobDuringJourney VARCHAR(8),
CHECK (JobDuringJourney IN ('Pilot', 'Engineer', 'Trooper', 'Cleaner', 'Cook')),
ColonistId INT NOT NULL FOREIGN KEY REFERENCES Colonists(Id),
JourneyId INT NOT NULL  FOREIGN KEY REFERENCES Journeys(Id),
)

--Section 2. DML

--2.	Insert
INSERT INTO Planets(Name) VALUES
('Mars'),
('Earth'),
('Jupiter'),
('Saturn')


INSERT INTO Spaceships(Name,Manufacturer,LightSpeedRate) VALUES
('Golf','VW',3),
('WakaWaka','Wakanda',4),
('Falcon9', 'SpaceX', 1),
('Bed', 'Vidolov', 6)


--3.	Update

UPDATE Spaceships
	SET LightSpeedRate +=1
	WHERE Id BETWEEN 8 AND 12

--4.	Delete

DELETE FROM TravelCards
	WHERE JourneyId IN (1,2,3)
DELETE FROM Journeys 
	WHERE Id IN (1,2,3)

--Section 3. Querying 

--5.	Select all military journeys

SELECT
	Id,
	FORMAT(JourneyStart,'dd/MM/yyyy') AS JourneyStart,
	FORMAT(JourneyEnd,'dd/MM/yyyy') AS JourneyEnd
FROM Journeys
WHERE Purpose = 'Military'
ORDER BY JourneyStart ASC

--6.	Select all pilots

SELECT c.Id, CONCAT(c.FirstName, ' ',c.LastName) AS full_name FROM Colonists c
	JOIN TravelCards t ON c.Id = t.ColonistId
	WHERE t.JobDuringJourney = 'Pilot'
	ORDER BY c.Id ASC

--7.	Count colonists

SELECT COUNT(*) AS count FROM Colonists C
	JOIN TravelCards t ON c.Id = t.ColonistId
	JOIN Journeys j ON t.JourneyId = j.Id
	WHERE j.Purpose = 'Technical'

--8.	Select spaceships with pilots younger than 30 years

SELECT s.Name,s.Manufacturer FROM Spaceships s
	LEFT JOIN Journeys j ON s.Id = j.SpaceshipId
	LEFT JOIN TravelCards t ON j.Id = t.JourneyId
	LEFT JOIN Colonists c ON t.ColonistId = c.Id
	WHERE DATEDIFF(YEAR, c.Birthdate, '01/01/2019') < 30 AND t.JobDuringJourney = 'Pilot'
	ORDER BY s.Name ASC

--9.	Select all planets and their journey count

SELECT p.Name, COUNT(*) AS [JourneysCount] FROM Planets p
	JOIN Spaceports sp ON P.Id = sp.PlanetId
	JOIN Journeys j ON sp.Id = j.DestinationSpaceportId
	GROUP BY p.Name
	ORDER BY 
		JourneysCount DESC,
		p.Name ASC
		
--10.	Select Second Oldest Important Colonist

SELECT * FROM
(
	SELECT 
		tc.JobDuringJourney,
		CONCAT(c.FirstName,' ', c.LastName) AS [FullName],
		RANK() OVER (PARTITION BY tc.JobDuringJourney ORDER BY c.BirthDate ASC) as [JobRank]
	FROM TravelCards tc
		JOIN Colonists c ON tc.ColonistId = c.Id
) as [RankQuery]
WHERE JobRank = 2


--Section 4. Programmability

--11.	Get Colonists Count

GO
CREATE FUNCTION dbo.udf_GetColonistsCount(@PlanetName VARCHAR (30)) 
RETURNS INT
AS
BEGIN
		RETURN
		(
			SELECT COUNT(*) FROM Planets p
				JOIN Spaceports sp ON p.Id = sp.PlanetId
				JOIN Journeys j ON sp.Id = j.DestinationSpaceportId
				JOIN TravelCards tc ON j.Id = tc.JourneyId
				JOIN Colonists c ON tc.ColonistId = c.Id
			WHERE p.Name = @PlanetName
		)
END
GO

--12.	Change Journey Purpose

GO
CREATE PROC usp_ChangeJourneyPurpose(@JourneyId INT, @NewPurpose VARCHAR(20))
AS
BEGIN

	IF (NOT EXISTS(SELECT j.Purpose FROM Journeys AS j WHERE j.Id = @journeyId)
		)
		THROW 50001, 'The journey does not exist!', 1

	DECLARE @CurrentPurpose VARCHAR(20) = (SELECT j.Purpose FROM Journeys AS j WHERE j.Id = @journeyId)

	IF (@CurrentPurpose = @NewPurpose)
		THROW 50002, 'You cannot change the purpose!', 1

	UPDATE Journeys
		SET Purpose = @NewPurpose
		WHERE Id = @JourneyId
END
GO

-- Old solution
--GO
--CREATE PROC usp_ChangeJourneyPurpose2(@JourneyId INT, @NewPurpose VARCHAR(20))
--AS
--BEGIN
--BEGIN TRANSACTION
--BEGIN TRY
--	IF (NOT EXISTS(SELECT j.Purpose FROM Journeys AS j WHERE j.Id = @journeyId)
--		)
--	BEGIN
--			ROLLBACK
--			RAISERROR('The journey does not exist!', 16, 1)
--			RETURN
--	END

--	DECLARE @CurrentPurpose VARCHAR(20) = (SELECT j.Purpose FROM Journeys AS j WHERE j.Id = @journeyId)

--	IF (@CurrentPurpose = @NewPurpose)
--	BEGIN
--			ROLLBACK
--			RAISERROR('You cannot change the purpose!', 16,1)
--			RETURN
--	END
--	COMMIT
--END TRY
--BEGIN CATCH
--	SELECT ERROR_MESSAGE() AS [Error Message] 
--END CATCH
--	UPDATE Journeys
--		SET Purpose = @NewPurpose
--		WHERE Id = @JourneyId
--END
--GO