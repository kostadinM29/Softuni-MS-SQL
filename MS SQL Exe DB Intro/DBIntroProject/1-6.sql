CREATE DATABASE Minions


CREATE TABLE Minions
(
Id INT PRIMARY KEY,
[Name] NVARCHAR(50),
Age INT,
)

CREATE TABLE Towns
(
Id INT PRIMARY KEY,
[Name] NVARCHAR(50)
)

ALTER TABLE Minions	
ADD TownId INT

ALTER TABLE Minions
ADD FOREIGN KEY (TownId) REFERENCES Towns(Id)

INSERT INTO Towns (Id,Name) VALUES
(1,'Sofia'),
(2,'Plovdiv'),
(3,'Varna')
INSERT INTO Minions(ID,[Name],Age,TownId) VALUES
(1,'Kevin',22,1),
(2,'Bob',15,3),
(3,'Steward',NULL,2)


DELETE FROM Minions
DROP TABLE Minions
DROP TABLE Towns