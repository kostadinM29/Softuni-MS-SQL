CREATE DATABASE Softuni


CREATE TABLE Towns
(
Id INT IDENTITY PRIMARY KEY,
[Name] NVARCHAR(50) NOT NULL
)

CREATE TABLE Adresses
(
Id INT IDENTITY PRIMARY KEY,
AdressText NVARCHAR(100) NOT NULL,
TownId INT FOREIGN KEY REFERENCES Towns(Id)
)

CREATE TABLE Departments
(
Id INT IDENTITY PRIMARY KEY,
Name NVARCHAR(50) NOT NULL
)

--•	Towns (Id, Name)
--•	Addresses (Id, AddressText, TownId)
--•	Departments (Id, Name)
--•	Employees (Id, FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary, AddressId)

CREATE TABLE Employees
(
Id INT IDENTITY PRIMARY KEY,
FirstName NVARCHAR(30) NOT NULL,
MiddleName NVARCHAR(30) NOT NULL,
LastName NVARCHAR(30) NOT NULL,
JobTitle NVARCHAR(30) NOT NULL,
DepartmentId INT FOREIGN KEY REFERENCES Departments(Id),
HireDate DATE NOT NULL,
Salary DECIMAL(10,4) NOT NULL,
AdressId INT FOREIGN KEY REFERENCES Adresses(Id)
)

INSERT INTO Towns (Name) VALUES
('Sofia'),
('Plovdiv'),
('Varna'),
('Burgas')

--Engineering, Sales, Marketing, Software Development, Quality Assurance
INSERT INTO Departments(Name) VALUES
('Engineering'),
('Sales'),
('Marketing'),
('Software Development'),
('Quality Assurance')


INSERT INTO Employees(FirstName, MiddleName, LastName, JobTitle, DepartmentId, HireDate, Salary) VALUES
('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013-02-01', 3500),
('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004-03-02', 4000),
('Maria', 'Petrova', 'Ivanova', 'Intern', 5, '2016-08-28', 525.25),
('Georgi', 'Terzeiv', 'Ivanov', 'CEO', 2, '2007-12-09', 3000),
('Peter', 'Pan', 'Pan', 'Intern', 2, '2016-08-28', 599.88)



SELECT * FROM Towns
SELECT * FROM Departments
SELECT * FROM Employees



SELECT * FROM Towns
ORDER BY [Name]

SELECT * FROM Departments
ORDER BY [Name] ASC

SELECT * FROM Employees
ORDER BY Salary DESC



  
SELECT [Name] 
FROM Towns
ORDER BY [Name]

SELECT [Name] 
FROM Departments
ORDER BY [Name] ASC

SELECT FirstName, LastName, JobTitle, Salary 
FROM Employees
ORDER BY SALARY DESC



UPDATE Employees
SET Salary *= 1.10

SELECT Salary
FROM Employees



 