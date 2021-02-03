-- 3.	Queries for Diablo Database
USE Diablo


-- 13.	*Scalar Function: Cash in User Games Odd Rows
--Create a function ufn_CashInUsersGames that sums the cash of odd rows. Rows must be ordered by cash in descending order.
--The function should take a game name as a parameter and return the result as table.
--Submit only your function in.

GO
CREATE FUNCTION ufn_CashInUsersGames(@GameName NVARCHAR(50))
RETURNS TABLE 
AS
RETURN
(
	SELECT SUM(Cash) AS [SumCash] FROM
	(
		SELECT 
			g.Name,
			ug.Cash,
			ROW_NUMBER() OVER (ORDER BY Cash DESC) AS [Row Number]
		FROM Games g
		JOIN UsersGames ug ON g.Id = ug.GameId -- not sure if inner or left join
		WHERE g.Name = @GameName
	) AS [RowQuery]
	WHERE [Row Number] % 2 != 0 
)
GO

SELECT * FROM  dbo.ufn_CashInUsersGames('Istanbul')