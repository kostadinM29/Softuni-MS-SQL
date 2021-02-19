--PART I – Queries for Diablo Database

USE Diablo

--Problem 1.	Number of Users for Email Provider
--Find number of users for email provider from the largest to smallest, then by Email Provider in ascending order. 

SELECT 
	RIGHT([Email], LEN([Email]) - CHARINDEX('@',[Email])) AS [Email Provider],
	COUNT(*) AS [Number Of Users]
FROM Users
GROUP BY RIGHT([Email], LEN([Email]) - CHARINDEX('@',[Email]))
	ORDER BY 
		[Number Of Users] DESC,
		[Email Provider] ASC

--Problem 2.	All User in Games
--Find all user in games with information about them. Display the game name, game type, username, level, cash and character name.
--Sort the result by level in descending order, then by username and game in alphabetical order. 

SELECT 
	g.Name AS Game,
	gt.Name as [Game Type],
	u.Username,
	ug.Level,
	ug.Cash,
	c.Name
FROM UsersGames ug
	JOIN Characters c ON ug.CharacterId = c.Id
	JOIN Games g ON ug.GameId = g.Id
	JOIN GameTypes gt ON g.GameTypeId = gt.Id
	JOIN Users u ON ug.UserId = u.Id
ORDER BY 
	Level DESC,
	Username ASC,
	g.Name ASC

--Problem 3.	Users in Games with Their Items
--Find all users in games with their items count and items price. Display the username, game name, items count and items price.
--Display only user in games with items count more or equal to 10.
--Sort the results by items count in descending order then by price in descending order and by username in ascending order. 

SELECT 
	u.Username,
	g.Name,
	COUNT(ugi.ItemId) AS [Items Count],
	SUM(i.Price) AS[Items Price]
FROM UsersGames ug
	JOIN Users u ON ug.UserId = u.Id
	JOIN Games g ON ug.GameId = g.Id
	JOIN UserGameItems ugi ON ug.Id = ugi.UserGameId
	JOIN Items i ON ugi.ItemId = i.Id
GROUP BY u.Username, g.Name
HAVING COUNT(i.Name) >= 10
ORDER BY 
	[Items Count] DESC,
	[Items Price] DESC,
	u.Username ASC

--Problem 1.	* User in Games with Their Statistics
--Description too long

SELECT u.Username,
       g.Name AS Game,
       MAX(c.Name) AS Character,
       SUM(iStat.Strength) + MAX(gtStat.Strength) + MAX(cStat.Strength) AS Strength,
       SUM(iStat.Defence) + MAX(gtStat.Defence) + MAX(cStat.Defence) AS Defence,
       SUM(iStat.Speed) + MAX(gtStat.Speed) + MAX(cStat.Speed) AS Speed,
       SUM(iStat.Mind) + MAX(gtStat.Mind) + MAX(cStat.Mind) AS Mind,
       SUM(iStat.Luck) + MAX(gtStat.Luck) + MAX(cStat.Luck) AS Luck
FROM Users AS u
     JOIN UsersGames AS ug ON ug.UserId = u.Id
     JOIN Games AS g ON g.Id = ug.GameId
     JOIN UserGameItems AS ugi ON ugi.UserGameId = ug.Id
     JOIN Items AS i ON i.Id = ugi.ItemId
     JOIN [Statistics] AS iStat ON iStat.Id = i.StatisticId
     JOIN GameTypes AS gt ON gt.Id = g.GameTypeId
     JOIN [Statistics] AS gtStat ON gtstat.Id = gt.BonusStatsId
     JOIN Characters AS c ON c.Id = ug.CharacterId
     JOIN [Statistics] AS cStat ON cStat.Id = c.StatisticId
GROUP BY g.Name,
         Username
ORDER BY Strength DESC,
         Defence DESC,
         Speed DESC,
         Mind DESC,
         Luck DESC


--Problem 5.	All Items with Greater than Average Statistics
--Find all items with statistics larger than average.
--Display only items that have Mind, Luck and Speed greater than average Items mind, luck and speed. 
--Sort the results by item names in alphabetical order. 
