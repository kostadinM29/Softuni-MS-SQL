CREATE TABLE Users
(
Id BIGINT PRIMARY KEY IDENTITY,
Username VARCHAR(30) NOT NULL,
[Password] VARCHAR(26) NOT NULL UNIQUE,  -- NOT SURE THIS IS HOW UNIQUE WORKS
ProfilePicture VARCHAR(MAX),
LastLoginTime DATETIME,
IsDeleted BIT
)
INSERT INTO Users 
(Username,[Password],ProfilePicture,LastLoginTime,IsDeleted)
VALUES
('kokodin','strongpass123','https://www.vusi.bg/wp-content/uploads/2018/04/vusi_logo_sq.jpg','1/12/2021', 0),
('kokodina','strongp2323ass123','https://www.vusi.bg/wp-content/uploads/2018/04/vusi_logo_sq.jpg','9/12/2021', 0),
('dwwe','stron242gpass123','https://www.vusi.bg/wp-content/uploads/2018/04/vusi_logo_sq.jpg','3/12/2021', 0),
('kokodinc','strongp3434ass123','https://www.vusi.bg/wp-content/uploads/2018/04/vusi_logo_sq.jpg','5/12/2021', 0),
('kokodind','strongpass12323','https://www.vusi.bg/wp-content/uploads/2018/04/vusi_logo_sq.jpg','7/12/2021', 0),
('kokdn','strongpass123235','https://www.vusi.bg/wp-content/uploads/2018/04/vusi_logo_sq.jpg',NULL, 0)

ALTER TABLE Users	
DROP CONSTRAINT PK__Users__3214EC076179F94F

ALTER TABLE Users
ADD CONSTRAINT PK_IdUsername PRIMARY KEY (Id,Username)


ALTER TABLE Users
ADD CONSTRAINT CH_PasswordIsAtLeast5Symbols CHECK( LEN([Password]) >5)

ALTER TABLE Users
ADD CONSTRAINT DF_LastLoginTime DEFAULT GETDATE() FOR LastLoginTime 

ALTER TABLE Users
ADD CONSTRAINT PK_Id PRIMARY KEY (Id)

ALTER TABLE Users
ADD CONSTRAINT CH_UsernameIsAtLeast3Symbols CHECK( LEN(Username) >3)

SELECT * FROM Users