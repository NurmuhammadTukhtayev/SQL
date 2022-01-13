USE EXAMPLE;


--1)	Refer to the CSV - HW2ExerciseSample1. 
--Insert the Data in the CSV file into a table in the Database
--•	Table Name – User Details
--•	Use Import Wizard to Create table and Copy Data
--Expected Output – Screenshot of the select * from [User Details] with result

SELECT * FROM [USER DETAILS];

--2)	Refer to the CSV – HW2ExerciseSample2
--Insert the Data in the CSV into a table in the Database
--•	Create a table with script 
--o	Table Name – ProductDetails
--•	Use Bulk Insert statement to copy data to the above created Table
--Expected Output – Script of Create table and Bulk Insert statement

DROP TABLE ProductDetails
CREATE TABLE [ProductDetails]
(
	--ID INT PRIMARY KEY IDENTITY(1, 1),
	Product NVARCHAR(50) NOT  NULL,
	Customer NVARCHAR(50) NOT NULL,
	[Qtr 1] VARCHAR(50) NULL,
	[Qtr 2] VARCHAR(50) NULL,
	[Qtr 3] VARCHAR(50) NULL,
	[Qtr 4] VARCHAR(50) NULL
)

BULK INSERT ProductDetails
FROM 'C:\Projects\SQL\SQL\SSIS\HW2ExerciseSample2.csv'
WITH 
(
	DATAFILETYPE='char',
    FIELDTERMINATOR='","',
	ROWTERMINATOR='0x0a',
	FIRSTROW=2
)

UPDATE [ProductDetails]
SET Product = REPLACE(Product, CHAR(34), '')

UPDATE [ProductDetails]
SET [Qtr 4] = REPLACE([Qtr 4], CHAR(34), '')

UPDATE ProductDetails
SET [Qtr 4] = NULL WHERE [Qtr 4] = ''

SELECT * FROM [ProductDetails];


--3)	Select the Max Salary from [User Details] Table
--a.	Output Column - MaximumSalary

-- RENAME COLUMN
EXEC sp_RENAME 'User Details.[ Salary]' , 'Salary', 'COLUMN'

SELECT MAX(Salary) FROM [User Details];


--4)	Select the total number of records in the ProductDetails table
--a.	Output Column – TotalCount

SELECT COUNT(*) FROM ProductDetails;

--5)	Select Distinct Products from the ProductDetails table and Order by Product in Descending Order
--a.	Output Column - Products

SELECT DISTINCT Product 
FROM ProductDetails
ORDER BY Product DESC

--6)	Select the Products purchased by Customer ‘Queen’
--a.	Output Column – Product, Customer, Qtr1, Qtr2, Qtr3, Qtr4

SELECT * FROM ProductDetails
WHERE Customer = 'Queen'

--7)	Find how many customers purchased each Product with least Customers at the top
--a.	Eg : Product Alice Mutton has 13 Customers
--b.	Output Column – Product, CustomerCount

SELECT Product, COUNT(Product) AS CustomerCount FROM ProductDetails
GROUP BY Product;

--8)	Select sum of Qtr1, Qtr2, Qtr3, Qtr4 for each Product
--a.	Output Column - Product TotalQtr1, TotalQtr2, TotalQtr3, TotalQtr4

-- HELPER VIEW
CREATE VIEW ProdDet
AS
SELECT  Product, IIF([Qtr 1] IS NULL, 0, CONVERT(MONEY, [QTR 1], 1)) AS QTR1, 
		IIF([Qtr 2] IS NULL, 0, CONVERT(MONEY, [QTR 2], 1)) AS QTR2,
		IIF([Qtr 3] IS NULL, 0, CONVERT(MONEY, [QTR 3], 1)) AS QTR3, 
		IIF([Qtr 4] IS NULL, 0, CONVERT(MONEY, [QTR 4], 1)) QTR4 FROM ProductDetails

SELECT Product, SUM(QTR1) AS TotalQtr1, SUM(QTR2) AS TotalQtr2,
	   SUM(QTR3) AS TotalQtr3, SUM(QTR4) AS TotalQtr4 FROM ProdDet
GROUP BY Product;

--9)	Select Products which has Sum of Qtr1 greater than 300 and sort Qtr1 Asc
--a.	Output Columns – Product, Qtr1

SELECT Product, SUM(QTR1) AS Qtr1 FROM ProdDet
GROUP BY Product
HAVING SUM(QTR1) > 300
ORDER BY Qtr1;


--10)	Select columns that have null value in any tuple/column
--a.	Output Columns – Select * 

SELECT * FROM ProductDetails
WHERE [Qtr 1] IS NULL AND [Qtr 2] IS NULL AND [Qtr 3] IS NULL AND [Qtr 4] IS NULL;