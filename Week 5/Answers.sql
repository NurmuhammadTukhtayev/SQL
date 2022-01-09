﻿-- PART I.
-- VIEWS

--1. JOIN CUSTOMERS AND ORDERS TABLE
CREATE VIEW V_SHIPREG AS (
SELECT CompanyName, Country, ShipName, ShipRegion, OrderDate, RequiredDate
FROM Customers C
INNER JOIN Orders O
	ON C.CustomerID = O.CustomerID
WHERE ShipRegion IS NOT NULL);

SELECT * FROM V_SHIPREG;

-- 2. GET PRODUCTS AND CATEGORYNAMES
CREATE VIEW V_PROD AS
SELECT ProductName, CategoryName, [Description]
FROM Products P
JOIN Categories C
ON P.CategoryID = C.CategoryID;

SELECT * FROM V_PROD;

-- 3. JOIN SalesPerson AND SalesTerritory TABLES WITH COUNT OF SALES PERSONS
SELECT * FROM SalesPerson;
SELECT * FROM SalesTerritory;

CREATE VIEW V_COUNT AS
SELECT CountryGroup, CountryCode, TerritoryName, COUNT(SALESPERSONEMPLOYEEID) AS [COUNT OF SALES PERSONS]
FROM SalesTerritory ST
JOIN SalesPerson SP
ON ST.TerritoryID = SP.TerritoryID
GROUP BY CountryGroup, CountryCode, TerritoryName

SELECT * FROM V_COUNT


-- PART II 
--•Stored Procedure 
--1. GET EMPLOYEES WITH ORDERS

SELECT * FROM Employees;
SELECT * FROM Orders;

CREATE PROCEDURE GET_EMPLOYEES
AS
BEGIN
	SELECT 
	TitleOfCourtesy, LastName, FirstName, [Address], COUNT(ORDERID) AS MAXORDERS
	FROM Employees E
	INNER JOIN Orders O
		ON E.EmployeeID=O.EmployeeID
	GROUP BY TitleOfCourtesy, LastName, FirstName, [Address]
	ORDER BY MAXORDERS DESC
END

EXECUTE GET_EMPLOYEES;

--2. GET EMPLOYEES BY GENDER
--FIRSTLY CREATE HELPER VIEW
CREATE VIEW EMP
AS
SELECT 
	LastName, FirstName, [Address], GENDER=CASE
	WHEN TitleOfCourtesy LIKE 'Mrs.' THEN 'FEMALE'
	WHEN TitleOfCourtesy LIKE 'Ms.' THEN 'MALE'
	ELSE 'UNKNOWN' END
	FROM Employees

-- THEN PROCEDURE
CREATE PROC GET_EMPLOYEES_BY_GENDER
@G NVARCHAR(10)
AS
BEGIN
	SELECT * FROM EMP
	WHERE GENDER=@G
END

EXEC GET_EMPLOYEES_BY_GENDER 'MALE'

-- 3. PRINT COUNT OF EMPLOYEES FROM ORDERS

CREATE PROC COUNTOFEMPLOYEES
@C INT OUT
AS
BEGIN
	SELECT @C = COUNT(EmployeeID)
	FROM Orders;
END

DECLARE @C INT
EXEC COUNTOFEMPLOYEES @C OUT;
PRINT(@C)


-- PART III functions
--	In-line Table valued UDF

-- 1. FUNCTION RETURNS TABLE
CREATE FUNCTION F()
RETURNS TABLE
AS
	RETURN (
		SELECT CompanyName, Country, City, COUNT(EmployeeID) AS EMPLOYESS
	FROM Orders O
	INNER JOIN Customers C
		ON O.CustomerID=C.CustomerID
	GROUP BY CompanyName, Country, City
	)

SELECT * FROM F()

-- Scalar UDF
--2. CATEGORY DESCRIPTION

CREATE FUNCTION CATDES(@CAT NVARCHAR(20))
RETURNS NVARCHAR(50)
AS
BEGIN
	DECLARE @R NVARCHAR(20)
	SET @R = ( SELECT [Description] FROM Categories
	WHERE CategoryName = @CAT )
	IF @R IS NULL RETURN 'There no category with that name!'
	RETURN @R
END

SELECT dbo.CATDES('Produce')

-- Multi-Statement UDF
--3. SELECT LIVE PRICE

CREATE FUNCTION F2()
RETURNS @TABLE TABLE(ProductID INT, StartDate DATE, ListPrice NUMERIC, ModifiedDate DATE)
AS
BEGIN
	INSERT INTO @TABLE
	SELECT ProductID, StartDate, ListPrice, ModifiedDate FROM ProductListPriceHistory
	WHERE EndDate IS NULL

	RETURN
END

SELECT * FROM F2()

-- PART 4 DML(DATA MANIPULATION LANGUAGE) TRIGGERS
--1. 

CREATE DATABASE EXAMPLE;

USE EXAMPLE;

CREATE TABLE FT
(
	ID INT PRIMARY KEY,
	[Name] VARCHAR(20),
	Cash NUMERIC,
	[Address] VARCHAR(40)
)

CREATE TABLE HISTORY
(
	ID INT PRIMARY KEY, 
	[CHANGES] NVARCHAR(100)
)

INSERT INTO FT VALUES(1, 'John', 200, 'London')
INSERT INTO FT VALUES(2, 'Lana', 500, 'California')
INSERT INTO FT VALUES(3, 'Liya', 600, 'Moscow')

select * from FT;
select * from ST;

CREATE TRIGGER HIS
ON FT
FOR UPDATE
AS
BEGIN
	DECLARE @ID INT
	DECLARE @OLDCASH NUMERIC, @NEWCASH NUMERIC
	DECLARE @OLDNAME NVARCHAR(30), @NEWNAME NVARCHAR(30)
	DECLARE @OLDADDRESS NVARCHAR(50), @NEWADDRESS NVARCHAR(30)

	DECLARE @HISTORY NVARCHAR(MAX)

	SELECT * INTO #TMP FROM INSERTED;

	WHILE(EXISTS(SELECT ID FROM #TMP))
	BEGIN
		SET @HISTORY = ''

		SELECT TOP 1 @ID=ID, @NEWNAME=[NAME], @NEWCASH=CASH, @NEWADDRESS=[ADDRESS]
		FROM #TMP

		SELECT @OLDNAME=[NAME], @OLDCASH=CASH, @OLDADDRESS=[ADDRESS]
		FROM DELETED WHERE ID=@ID

		SET @HISTORY='Employee with id ' + CAST(@ID AS nvarchar(4)) + ' changed '
		IF(@OLDNAME<>@NEWNAME)
			SET @HISTORY = @HISTORY + ' Name from ' + @OLDNAME + ' to ' + @NEWNAME
		IF(@OLDCASH<>@NEWCASH)
			SET @HISTORY = @HISTORY + ' cash from ' + CAST(@OLDCASH AS NVARCHAR(10)) + ' to ' + @NEWCASH
		IF(@OLDADDRESS<>@NEWADDRESS)
			SET @HISTORY = @HISTORY + ' address from ' + @OLDADDRESS + ' to ' + @NEWADDRESS

		DECLARE @HID INT
		SET @HID = (SELECT MAX(ID) FROM HISTORY)
		IF @HID IS NULL SET @HID=1
		ELSE SET @HID = @HID + 1
		INSERT INTO HISTORY VALUES(@HID, @HISTORY)

		DELETE FROM #TMP WHERE ID=@ID

	END

END

UPDATE FT SET [Name]='Jake' WHERE ID=1

SELECT * FROM HISTORY