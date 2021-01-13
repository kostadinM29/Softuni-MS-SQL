CREATE TABLE People 
(
    ID int PRIMARY KEY IDENTITY NOT NULL,
    [Name] nvarchar(200) NOT NULL,
    Picture VARCHAR(MAX),
	Height DECIMAL(5,2),
	[Weight] DECIMAL(5,2),
	Gender nvarchar(5) NOT NULL,
	Birthdate DATETIME,
    Biography nvarchar(MAX)
);
INSERT INTO People 
([Name],Picture,Height,[Weight],Gender,Birthdate,Biography)
VALUES
('Koko','https://www.vusi.bg/wp-content/uploads/2018/04/vusi_logo_sq.jpg',1.75,123.45,'m',5/12/1995, 'Da'),
('Kokod','https://www.vusi.bg/wp-content/uploads/2018/04/vusi_logo_sq.jpg',1.55,523.45,'m',8/12/1995, 'Daew'),
('Kokodw','https://www.vusi.bg/wp-content/uploads/2018/04/vusi_logo_sq.jpg',1.15,423.15,'f',5/12/1195, 'Dawa'),
('Kokdwo','https://www.vusi.bg/wp-content/uploads/2018/04/vusi_logo_sq.jpg',1.25,123.12,'f',12/12/1995, 'Daew'),
('Kokoaw','https://www.vusi.bg/wp-content/uploads/2018/04/vusi_logo_sq.jpg',1.35,173.45,'m',5/12/1925, 'Daw')

SELECT * FROM People