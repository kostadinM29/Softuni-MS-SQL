-- Geography Database Queries

USE [Geography]

-- 12. Highest Peaks in Bulgaria
--Write a query that selects:
--•	CountryCode
--•	MountainRange
--•	PeakName
--•	Elevation
--Filter all peaks in Bulgaria with elevation over 2835. Return all the rows sorted by elevation in descending order.

SELECT 
	c.[CountryCode],
	m.[MountainRange],
	p.[PeakName],
	p.[Elevation]
FROM Countries c
	JOIN MountainsCountries mc ON c.[CountryCode] = mc.[CountryCode]
	JOIN Mountains m ON mc.[MountainId] = m.[Id]
	JOIN Peaks p ON m.[Id] = p.[MountainId]
WHERE c.[CountryCode] = 'BG' AND
	p.[Elevation] > 2835
	ORDER BY p.[Elevation] DESC

-- 13. Count Mountain Ranges
--Write a query that selects:
--•	CountryCode
--•	MountainRanges
--Filter the count of the mountain ranges in the United States, Russia and Bulgaria.

SELECT [CountryCode], COUNT(MountainId) FROM MountainsCountries
	WHERE [CountryCode] IN ('US', 'BG', 'RU')
	GROUP BY CountryCode

-- 14. Countries with Rivers
--Write a query that selects:
--•	CountryName
--•	RiverName
--Find the first 5 countries with or without rivers in Africa. Sort them by CountryName in ascending order.

SELECT TOP 5 
	c.[CountryName],
	r.[RiverName]
FROM Countries c
	LEFT JOIN CountriesRivers cr ON c.[CountryCode] = cr.[CountryCode]
	LEFT JOIN Rivers r ON cr.[RiverId] = r.[Id]
		WHERE c.[ContinentCode] = 'AF'
		ORDER BY c.[CountryName] ASC

-- 15. *Continents and Currencies
--Write a query that selects:
--•	ContinentCode
--•	CurrencyCode
--•	CurrencyUsage
--Find all continents and their most used currency. Filter any currency that is used in only one country. Sort your results by ContinentCode

SELECT rc.[ContinentCode], rc.[CurrencyCode], rc.[CurrencyUsage]
	FROM
	(
	SELECT 
		[ContinentCode],
		[CurrencyCode],
		COUNT([CurrencyCode]) AS [CurrencyUsage],
		DENSE_RANK() OVER (PARTITION BY c.[ContinentCode] ORDER BY COUNT(c.[CurrencyCode]) DESC) as [Rank]
FROM Countries AS c
	GROUP BY [ContinentCode], [CurrencyCode]
	) AS rc
	WHERE rc.Rank = 1 AND rc.CurrencyUsage > 1

-- 16.? Countries Without Any Mountains
--Find all the count of all countries, which don’t have a mountain.

SELECT COUNT(*) AS [Count] FROM Countries c
	LEFT JOIN MountainsCountries mc ON c.[CountryCode] = mc.[CountryCode]
	LEFT JOIN Mountains m ON mc.[MountainId] = m.[Id]
	WHERE m.[MountainRange] IS NULL

-- 17. Highest Peak and Longest River by Country
--For each country, find the elevation of the highest peak and the length of the longest river,
--sorted by the highest peak elevation (from highest to lowest),
--then by the longest river length (from longest to smallest),
--then by country name (alphabetically).
--Display NULL when no data is available in some of the columns. Limit only the first 5 rows.

SELECT TOP 5
	c.[CountryName],
	MAX(p.[Elevation]) AS [HighestPeakElevation],
	MAX(r.[Length]) AS [LongestRiverLength]
FROM Countries c
	LEFT JOIN MountainsCountries mc ON c.[CountryCode] = mc.[CountryCode]
	LEFT JOIN Mountains m ON mc.[MountainId] = m.[Id]
	LEFT JOIN Peaks p ON m.[Id] = p.[MountainId]
	LEFT JOIN CountriesRivers cr ON c.[CountryCode] = cr.[CountryCode]
	LEFT JOIN Rivers r ON cr.[RiverId] = r.[Id]
	GROUP BY c.[CountryName]
	ORDER BY 
		[HighestPeakElevation] DESC,
		[LongestRiverLength] DESC,
		c.[CountryName] ASC

-- 18. *Highest Peak Name and Elevation by Country
--For each country, find the name and elevation of the highest peak, along with its mountain.
--When no peaks are available in some country, display elevation 0,
--"(no highest peak)" as peak name and "(no mountain)" as mountain name.
--When multiple peaks in some country have the same elevation, display all of them.
--Sort the results by country name alphabetically, then by highest peak name alphabetically.
--Limit only the first 5 rows.

-- Solution 1

SELECT TOP 5
	[Country],
	CASE
		WHEN [PeakName] IS NULL THEN '(no highest peak)'
		ELSE [PeakName]
	END AS [Highest Peak Name],
	CASE
		WHEN [Elevation] IS NULL THEN 0
		ELSE [Elevation]
	END AS [Highest Peak Elevation],
	CASE
			WHEN [MountainRange] IS NULL THEN '(no mountain)' 
			ELSE [MountainRange]
	END AS [Mountain]
FROM 
(
	SELECT *,	
	DENSE_RANK() OVER (PARTITION BY [Country] ORDER BY [Elevation] DESC) AS [Rank]
	FROM
		(
		SELECT 
			c.[CountryName] AS [Country],
			p.[PeakName],
			p.[Elevation],
			m.[MountainRange]
		FROM
			Countries c
				LEFT JOIN MountainsCountries mc ON c.[CountryCode] = mc.[CountryCode]
				LEFT JOIN Mountains m ON mc.[MountainId] = m.[Id]
				LEFT JOIN Peaks p ON m.[Id] = p.[MountainId]
		) AS [FullInfo]
) AS [RankingQuery]
WHERE [Rank] = 1
	ORDER BY 
	[Country] ASC,
	[Highest Peak Name] ASC

-- Solution 2

SELECT TOP 5
c.[CountryName] AS [Country],
ISNULL(p.[PeakName], '(no highest peak)') AS [HighestPeakName],
ISNULL(MAX(p.[Elevation]), 0) AS [HighestPeakElevation],
ISNULL(m.[MountainRange], '(no mountain)')
FROM Countries  c
	LEFT JOIN MountainsCountries mc ON c.[CountryCode] = mc.[CountryCode]
	LEFT JOIN Mountains m ON mc.[MountainId] = m.[Id]
	LEFT JOIN Peaks p ON m.[Id] = p.[MountainId]
GROUP BY 
	c.[CountryName],
	p.[PeakName],
	m.[MountainRange]
ORDER BY 
	c.[CountryName] ASC,
	p.[PeakName] ASC		

-- Solution 3 -- Scrapped solution, not good enough with groups

--SELECT TOP 5
--	c.[CountryName] AS [Country],
--	CASE
--		WHEN [PeakName] IS NULL THEN '(no highest peak)'
--		ELSE [PeakName]
--	END AS [Highest Peak Name],
--	CASE
--		WHEN [Elevation] IS NULL THEN 0
--		ELSE MAX(p.[Elevation])
--	END AS [Highest Peak Elevation],
--	CASE
--		WHEN [MountainRange] IS NULL THEN '(no mountain)' 
--		ELSE [MountainRange]
--	END AS [Mountain]
--FROM Countries  c
--	LEFT JOIN MountainsCountries mc ON c.[CountryCode] = mc.[CountryCode]
--	LEFT JOIN Mountains m ON mc.[MountainId] = m.[Id]
--	LEFT JOIN Peaks p ON m.[Id] = p.[MountainId]
--GROUP BY 
--	c.[CountryName],
--	p.[PeakName],
--	m.[MountainRange]
	
--ORDER BY
--	[Country] ASC,
--	[Highest Peak Name] ASC