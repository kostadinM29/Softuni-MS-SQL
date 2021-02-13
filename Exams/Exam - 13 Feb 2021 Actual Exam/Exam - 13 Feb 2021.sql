--Section 1. DDL (30 pts)

CREATE DATABASE Bitbucket

USE Bitbucket

--1.	Database Design

CREATE TABLE Users
(
	Id INT PRIMARY KEY IDENTITY,
	Username VARCHAR(30) NOT NULL,
	Password VARCHAR(30) NOT NULL,
	Email VARCHAR(30) NOT NULL
)

CREATE TABLE Repositories
(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(50) NOT NULL
)

CREATE TABLE RepositoriesContributors
(
	RepositoryId INT REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT REFERENCES Users(Id) NOT NULL,
	CONSTRAINT PK_RepositoriesContributors PRIMARY KEY (RepositoryId,ContributorId)
)

CREATE TABLE Issues
(
	Id INT PRIMARY KEY IDENTITY,
	Title VARCHAR(255) NOT NULL,
	IssueStatus VARCHAR(6) NOT NULL,
	RepositoryId INT REFERENCES Repositories(Id) NOT NULL,
	AssigneeId INT REFERENCES Users(Id) NOT NULL,
)

CREATE TABLE Commits
(
	Id INT PRIMARY KEY IDENTITY,
	Message VARCHAR(255) NOT NULL,
	IssueId INT REFERENCES Issues(Id),
	RepositoryId INT REFERENCES Repositories(Id) NOT NULL,
	ContributorId INT REFERENCES Users(Id) NOT NULL
)

CREATE TABLE Files
(
	Id INT PRIMARY KEY IDENTITY,
	Name VARCHAR(100) NOT NULL,
	Size DECIMAL(10,2) NOT NULL,
	ParentId INT REFERENCES Files(Id),
	CommitId INT REFERENCES Commits(Id) NOT NULL
)

--2.	Insert

INSERT INTO Files(Name,Size,ParentId,CommitId) VALUES
('Trade.idk', 2598.0, 1, 1),
('menu.net', 9238.31, 2, 2),
('Administrate.soshy', 1246.93, 3, 3),
('Controller.php', 7353.15, 4, 4),
('Find.java', 9957.86, 5, 5),
('Controller.json', 14034.87, 3, 6),
('Operate.xix', 7662.92, 7, 7)

INSERT INTO Issues(Title,IssueStatus,RepositoryId,AssigneeId) VALUES
('Critical Problem with HomeController.cs file', 'open', 1, 4),
('Typo fix in Judge.html', 'open', 4, 3),
('Implement documentation for UsersService.cs', 'closed', 8, 2),
('Unreachable code in Index.cs', 'open', 9, 8)


--3.	Update
--Make issue status 'closed' where Assignee Id is 6.

UPDATE Issues
	SET IssueStatus = 'closed'
	WHERE AssigneeId = 6


--4.	Delete
--Delete repository "Softuni-Teamwork" in repository contributors and issues.

--DELETE FROM Commits
--	WHERE RepositoryId = 3

DELETE FROM Issues
	WHERE RepositoryId = 3

DELETE FROM RepositoriesContributors
	WHERE RepositoryId = 3

--DELETE FROM Repositories
--	WHERE Id = 3

SELECT * FROM Repositories  r
	LEFT JOIN Issues i ON r.Id = i.RepositoryId
	LEFT JOIN Commits c ON r.Id = c.RepositoryId
	LEFT JOIN RepositoriesContributors rc ON r.Id = rc.RepositoryId

	WHERE r.Id = 3

	SELECT * FROM Issues WHERE RepositoryId = 3
	SELECT * FROM Commits WHERE RepositoryId = 3
	SELECT * FROM RepositoriesContributors WHERE RepositoryId = 3
	SELECT * FROM Repositories WHERE Name = 'Softuni-Teamwork'


--Section 3. Querying (40 pts)

--5.	Commits
--Select all commits from the database. Order them by id (ascending), message (ascending), repository id (ascending) and contributor id (ascending).

SELECT 
	Id,
	Message,
	RepositoryId,
	ContributorId
FROM Commits
ORDER BY 
	Id ASC,
	Message ASC,
	RepositoryId ASC,
	ContributorId ASC


--6.	Front-end
--Select all of the files, which have size, greater than 1000, and a name containing "html".
--Order them by size (descending), id (ascending) and by file name (ascending).

SELECT 
	Id,
	Name,
	Size
FROM Files
	WHERE  Size > 1000 AND Name LIKE '%html%'
ORDER BY
	Size DESC,
	Id ASC,
	Name ASC

--7.	Issue Assignment
--Select all of the issues, and the users that are assigned to them, so that they end up in the following format: {username} : {issueTitle}. 
--Order them by issue id (descending) and issue assignee (ascending).

SELECT
	i.Id,
	CONCAT(Username, ' : ', i.Title) AS IssueAssignee
FROM Users u
	JOIN Issues i ON U.Id = i.AssigneeId
ORDER BY
	i.Id DESC,
	IssueAssignee ASC

--8.	Single Files
--Select all of the files, which are NOT a parent to any other file. Select their size of the file and add "KB" to the end of it.
--Order them file id (ascending), file name (ascending) and file size (descending).

SELECT 
	f1.Id,
	f1.Name,
	CONCAT(f1.Size, 'KB')
FROM Files f1
	LEFT JOIN Files f2 ON f1.Id = f2.ParentId
	WHERE f2.ParentId IS NULL
ORDER BY 
	f1.Id ASC,
	f1.Name ASC,
	f1.Size DESC


--9.	Commits in Repositories
--Select the top 5 repositories in terms of count of commits.
--Order them by commits count (descending), repository id (ascending) then by repository name (ascending).

SELECT TOP 5
	r.Id,
	r.Name,
	COUNT(r.Name) AS Commits
FROM RepositoriesContributors rc
	LEFT JOIN Repositories r ON rc.RepositoryId = r.Id
	LEFT JOIN Commits c ON r.Id = c.RepositoryId
GROUP BY 
	r.Id,
	r.Name
ORDER BY 
	Commits DESC,
	r.Id ASC,
	r.Name ASC
	

--Section 4. Programmability (20 pts)

--10.	Average Size
--Select all users which have commits. Select their username and average size of the file, which were uploaded by them.
--Order the results by average upload size (descending) and by username (ascending).

SELECT 
	Username,
	AVG(f.Size) AS Size
FROM Users u
	JOIN Commits c ON u.Id = c.ContributorId
	JOIN Files f ON c.Id = f.CommitId
GROUP BY Username
ORDER BY 
	AVG(f.Size) DESC,
	Username ASC


--11.	All User Commits
--Create a user defined function, named udf_AllUserCommits(@username) that receives a username.
--The function must return count of all commits for the user.

GO
CREATE FUNCTION udf_AllUserCommits(@Username VARCHAR(50))
RETURNS INT
AS
BEGIN
RETURN (
	SELECT COUNT(*) FROM Users u
		JOIN Commits c ON u.Id = c.ContributorId
	WHERE Username = @Username
	   )
END
GO

SELECT dbo.udf_AllUserCommits('UnderSinduxrein')


--12.	 Search for Files
--Create a user defined stored procedure, named usp_SearchForFiles(@fileExtension), that receives files extensions.
--The procedure must print the id, name and size of the file. Add "KB" in the end of the size.
--Order them by id (ascending), file name (ascending) and file size (descending)

GO
CREATE PROC usp_SearchForFiles(@fileExtension VARCHAR(50))
AS
BEGIN
	SELECT 
	Id,
	Name,
	CONCAT(Size, 'KB')
FROM Files 
	WHERE Name LIKE '%' + @fileExtension
ORDER BY 
	Id ASC,
	Name ASC,
	Size DESC
END
GO


EXEC dbo.usp_SearchForFiles 'txt'
