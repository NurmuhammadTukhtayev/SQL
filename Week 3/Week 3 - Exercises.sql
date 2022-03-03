
-- 1 (This Task Has 2 Questions)
-- 1-1
-- Write a query that generates 5 copies out of each employee row
-- Tables involved: TSQLV4 database, Employees and Nums tables

-- A
SELECT empid, firstname, lastname, n FROM HR.EMPLOYEES, NUMS
WHERE N BETWEEN 1 AND 5;

-- B
SELECT empid, firstname, lastname, n  FROM HR.Employees
    CROSS JOIN Nums
        WHERE n BETWEEN 1 AND 5;


--Desired output
-- empid       firstname  lastname             n
-- ----------- ---------- -------------------- -----------
-- 1           Sara       Davis                1
-- 2           Don        Funk                 1
-- 3           Judy       Lew                  1
-- 4           Yael       Peled                1
-- 5           Sven       Mortensen            1
-- 6           Paul       Suurs                1
-- 7           Russell    King                 1
-- 8           Maria      Cameron              1
-- 9           Patricia   Doyle                1
-- 1           Sara       Davis                2
-- 2           Don        Funk                 2
-- 3           Judy       Lew                  2
-- 4           Yael       Peled                2
-- 5           Sven       Mortensen            2
-- 6           Paul       Suurs                2
-- 7           Russell    King                 2
-- 8           Maria      Cameron              2
-- 9           Patricia   Doyle                2
-- 1           Sara       Davis                3
-- 2           Don        Funk                 3
-- 3           Judy       Lew                  3
-- 4           Yael       Peled                3
-- 5           Sven       Mortensen            3
-- 6           Paul       Suurs                3
-- 7           Russell    King                 3
-- 8           Maria      Cameron              3
-- 9           Patricia   Doyle                3
-- 1           Sara       Davis                4
-- 2           Don        Funk                 4
-- 3           Judy       Lew                  4
-- 4           Yael       Peled                4
-- 5           Sven       Mortensen            4
-- 6           Paul       Suurs                4
-- 7           Russell    King                 4
-- 8           Maria      Cameron              4
-- 9           Patricia   Doyle                4
-- 1           Sara       Davis                5
-- 2           Don        Funk                 5
-- 3           Judy       Lew                  5
-- 4           Yael       Peled                5
-- 5           Sven       Mortensen            5
-- 6           Paul       Suurs                5
-- 7           Russell    King                 5
-- 8           Maria      Cameron              5
-- 9           Patricia   Doyle                5
--
-- (45 row(s) affected)

-- 1-2 
-- Write a query that returns a row for each employee and day 
-- in the range June 12, 2016 � June 16 2016.
-- Tables involved: TSQLV4 database, Employees and Nums tables

SELECT empid, DATEADD(dd, N, '2016-12-06') AS [DAY]
FROM HR.Employees CROSS JOIN Nums
    WHERE n BETWEEN 0 AND 4
ORDER BY empid;

--Desired output
-- empid       dt
-- ----------- -----------
-- 1           2016-06-12
-- 1           2016-06-13
-- 1           2016-06-14
-- 1           2016-06-15
-- 1           2016-06-16
-- 2           2016-06-12
-- 2           2016-06-13
-- 2           2016-06-14
-- 2           2016-06-15
-- 2           2016-06-16
-- 3           2016-06-12
-- 3           2016-06-13
-- 3           2016-06-14
-- 3           2016-06-15
-- 3           2016-06-16
-- 4           2016-06-12
-- 4           2016-06-13
-- 4           2016-06-14
-- 4           2016-06-15
-- 4           2016-06-16
-- 5           2016-06-12
-- 5           2016-06-13
-- 5           2016-06-14
-- 5           2016-06-15
-- 5           2016-06-16
-- 6           2016-06-12
-- 6           2016-06-13
-- 6           2016-06-14
-- 6           2016-06-15
-- 6           2016-06-16
-- 7           2016-06-12
-- 7           2016-06-13
-- 7           2016-06-14
-- 7           2016-06-15
-- 7           2016-06-16
-- 8           2016-06-12
-- 8           2016-06-13
-- 8           2016-06-14
-- 8           2016-06-15
-- 8           2016-06-16
-- 9           2016-06-12
-- 9           2016-06-13
-- 9           2016-06-14
-- 9           2016-06-15
-- 9           2016-06-16
--
-- (45 row(s) affected)

-- 2
-- Explain what�s wrong in the following query and provide a correct alternative
SELECT Customers.custid, Customers.companyname, Orders.orderid, Orders.orderdate
FROM Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON Customers.custid = Orders.custid;

-- CORRECT ALTERNATIVE
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  INNER JOIN Sales.Orders AS O
    ON C.custid = O.custid;

-- 3
-- Return US customers, and for each customer the total number of orders 
-- and total quantities.
-- Tables involved: TSQLV4 database, Customers, Orders and OrderDetails tables

SELECT C.custid, COUNT(DISTINCT O.orderid) AS numorders, SUM(OD.qty) AS totalqty
FROM Sales.Customers C
INNER JOIN Sales.Orders O ON C.custid = O.custid
INNER JOIN Sales.OrderDetails OD ON O.orderid = OD.orderid
WHERE country = 'USA'
GROUP BY C.custid
ORDER BY custid;

--Desired output
-- custid      numorders   totalqty
-- ----------- ----------- -----------
-- 32          11          345
-- 36          5           122
-- 43          2           20
-- 45          4           181
-- 48          8           134
-- 55          10          603
-- 65          18          1383
-- 71          31          4958
-- 75          9           327
-- 77          4           46
-- 78          3           59
-- 82          3           89
-- 89          14          1063
--
-- (13 row(s) affected)

-- 4
-- Return customers and their orders including customers who placed no orders
-- Tables involved: TSQLV4 database, Customers and Orders tables

SELECT C.custid, C.companyname, O.orderid, O.orderdate
    FROM Sales.Customers C
        LEFT JOIN Sales.Orders O on C.custid = O.custid;

-- Desired output
-- custid      companyname     orderid     orderdate
-- ----------- --------------- ----------- -----------
-- 85          Customer ENQZT  10248       2014-07-04
-- 79          Customer FAPSM  10249       2014-07-05
-- 34          Customer IBVRG  10250       2014-07-08
-- 84          Customer NRCSK  10251       2014-07-08
-- ...
-- 73          Customer JMIKW  11074       2016-05-06
-- 68          Customer CCKOT  11075       2016-05-06
-- 9           Customer RTXGC  11076       2016-05-06
-- 65          Customer NYUHS  11077       2016-05-06
-- 22          Customer DTDMN  NULL        NULL
-- 57          Customer WVAXS  NULL        NULL
--
-- (832 row(s) affected)

-- 5
-- Return customers who placed no orders
-- Tables involved: TSQLV4 database, Customers and Orders tables

SELECT C.custid, C.companyname
    FROM Sales.Customers C
        LEFT JOIN Sales.Orders O
            ON C.custid = O.custid
        WHERE O.orderid IS NULL;

-- Desired output
-- custid      companyname
-- ----------- ---------------
-- 22          Customer DTDMN
-- 57          Customer WVAXS
--
-- (2 row(s) affected)

-- 6
-- Return customers with orders placed on Feb 12, 2016 along with their orders
-- Tables involved: TSQLV4 database, Customers and Orders tables

SELECT C.custid, C.companyname, O.orderid, O.orderdate
    FROM Sales.Customers C RIGHT JOIN Sales.Orders O
        ON C.custid = O.custid
            WHERE orderdate = '2016-02-12';
 
-- Desired output
-- custid      companyname     orderid     orderdate
-- ----------- --------------- ----------- ----------
-- 48          Customer DVFMB  10883       2016-02-12
-- 45          Customer QXPPT  10884       2016-02-12
-- 76          Customer SFOGW  10885       2016-02-12
--
-- (3 row(s) affected)

-- 7 
-- Write a query that returns all customers in the output, but matches
-- them with their respective orders only if they were placed on February 12, 2016
-- Tables involved: TSQLV4 database, Customers and Orders tables

WITH TMP AS (
    SELECT DISTINCT C.custid, C.companyname, O.orderid, O.orderdate
    FROM Sales.Customers C
        RIGHT JOIN Sales.Orders O on C.custid = O.custid
            WHERE orderdate = '2016-02-12'
)
SELECT C.custid, C.companyname, orderid, orderdate
    FROM TMP
        RIGHT JOIN Sales.Customers C
            ON C.custid = TMP.custid;

-- Desired output
-- custid      companyname     orderid     orderdate
-- ----------- --------------- ----------- ----------
-- 72          Customer AHPOP  NULL        NULL
-- 58          Customer AHXHT  NULL        NULL
-- 25          Customer AZJED  NULL        NULL
-- 18          Customer BSVAR  NULL        NULL
-- 91          Customer CCFIZ  NULL        NULL
-- 68          Customer CCKOT  NULL        NULL
-- 49          Customer CQRAA  NULL        NULL
-- 24          Customer CYZTN  NULL        NULL
-- 22          Customer DTDMN  NULL        NULL
-- 48          Customer DVFMB  10883       2016-02-12
-- 10          Customer EEALV  NULL        NULL
-- 40          Customer EFFTC  NULL        NULL
-- 85          Customer ENQZT  NULL        NULL
-- 82          Customer EYHKM  NULL        NULL
-- 79          Customer FAPSM  NULL        NULL
-- ...
-- 51          Customer PVDZC  NULL        NULL
-- 52          Customer PZNLA  NULL        NULL
-- 56          Customer QNIVZ  NULL        NULL
-- 8           Customer QUHWH  NULL        NULL
-- 67          Customer QVEPD  NULL        NULL
-- 45          Customer QXPPT  10884       2016-02-12
-- 7           Customer QXVLA  NULL        NULL
-- 60          Customer QZURI  NULL        NULL
-- 19          Customer RFNQC  NULL        NULL
-- 9           Customer RTXGC  NULL        NULL
-- 76          Customer SFOGW  10885       2016-02-12
-- 69          Customer SIUIH  NULL        NULL
-- 86          Customer SNXOJ  NULL        NULL
-- 88          Customer SRQVM  NULL        NULL
-- 54          Customer TDKEG  NULL        NULL
-- 20          Customer THHDP  NULL        NULL
-- ...
--
-- (91 row(s) affected)

-- 8 
-- Explain why the following query isn�t a correct solution query for exercise 7.
SELECT C.custid, C.companyname, O.orderid, O.orderdate
FROM Sales.Customers AS C
  LEFT OUTER JOIN Sales.Orders AS O
    ON O.custid = C.custid
WHERE O.orderdate = '20160212'
   OR O.orderid IS NULL;


--======================================================================================--
--                                     ANSWER
--
-- That query will display customers and orders only including order date
-- which is 2016-01-12 or NULL
-- but we need to display all customers with orders if there is orderdate='2016-01-12'
-- or if does not - null
--======================================================================================--


-- 9 
-- Return all customers, and for each return a Yes/No value
-- depending on whether the customer placed an order on Feb 12, 2016
-- Tables involved: TSQLV4 database, Customers and Orders tables

-- A

WITH tmp AS (
SELECT C.custid, C.companyname, O.orderdate
FROM sales.customers C
INNER JOIN sales.orders O
    ON C.custid = O.custid
    )
SELECT DISTINCT custid, companyname, HasOrderOn20160212 = 
    CASE
        WHEN orderdate = '2016-02-12' THEN 'YES'
        ELSE 'NO'
    END
FROM tmp;

-- B
WITH TMP AS (
    SELECT DISTINCT C.custid, C.companyname, O.orderid, O.orderdate
    FROM Sales.Customers C
        RIGHT JOIN Sales.Orders O on C.custid = O.custid
            WHERE orderdate = '2016-02-12'
)
SELECT C.custid, C.companyname, HasOrderOn20160212 = IIF(orderdate IS NULL, 'No', 'Yes')
    FROM TMP
        RIGHT JOIN Sales.Customers C
            ON C.custid = TMP.custid;


-- Desired output
-- custid      companyname     HasOrderOn20160212
-- ----------- --------------- ------------------
-- ...
-- 40          Customer EFFTC  No
-- 41          Customer XIIWM  No
-- 42          Customer IAIJK  No
-- 43          Customer UISOJ  No
-- 44          Customer OXFRU  No
-- 45          Customer QXPPT  Yes
-- 46          Customer XPNIK  No
-- 47          Customer PSQUZ  No
-- 48          Customer DVFMB  Yes
-- 49          Customer CQRAA  No
-- 50          Customer JYPSC  No
-- 51          Customer PVDZC  No
-- 52          Customer PZNLA  No
-- 53          Customer GCJSG  No
-- ...
--
-- (91 row(s) affected)
------------------------------------------------------------------------------


--NOTE!!! : You dont need TSQLV4 for solving the below questions.


-- 10
-- Explain the difference between the UNION ALL and UNION operators
-- In what cases are they equivalent?
-- When they are equivalent, which one should you use?

--SOLUTOIN: 
--================================================================================--
--                                    ANSWER
-- UNION displays distinct values
-- UNION ALL includes all values with duplicates
-- NOTE: in case, when there's no duplicates it is perfect to use UNION ALL in order to
-- UNION, because it is faster when no filter
--================================================================================--
/*
11. Find the movie details where Tom and Bob acted together and their role is actor.
*/

--Create a sample movie table
CREATE TABLE [Movie]
(
 
[MName] [varchar] (10) NULL,
[AName] [varchar] (10) NULL,
[Roles] [varchar] (10) NULL
)
 
GO
 
--Insert data in the table
 
INSERT INTO Movie(MName,AName,Roles)
SELECT 'A','Tom','Actor'
UNION ALL
SELECT 'A','Bob','Villan'
UNION ALL
SELECT 'B','Tom','Actor'
UNION ALL
SELECT 'B','Bob','Actor'
UNION ALL
SELECT 'D','Tom','Actor'
UNION ALL
SELECT 'E','Bob','Actor'
 
--Check your data
SELECT MName , AName , Roles FROM Movie;

-- Expected Output

-- MName	AName	Roles
-- B		Tom		Actor
-- B		Bob		Actor


--Solution 
-- A
WITH TMP AS (
    SELECT *,
           COUNT(IIF(AName='Tom' OR MName='Bob', 1, 0)) OVER ( PARTITION BY MName ORDER BY MName) AS  CActors,
            SUM(IIF(Roles='Actor', 1, 0)) OVER ( PARTITION BY MName ORDER BY  MName) AS CRoles
             FROM Movie
)  SELECT MName, AName, Roles FROM TMP
WHERE CActors = 2 AND CRoles = 2;

-- B
SELECT MName
FROM Movie
    WHERE Roles = 'Actor'
    GROUP BY MName
    HAVING COUNT(DISTINCT AName) > 1

/*
12. Find maximum value from multiple columns of the table, not from muliple rows!
You dont need to use joins here
*/

--Sample Input
-- Year1	Max1	Max2	Max3
-- 2001	10		101		87
-- 2002	103		19		88
-- 2003	21		23		89
-- 2004	27		28		91

--Expected Output
-- Year1	MaxValue
-- 2001	101
-- 2002	103
-- 2003	89
-- 2004	91

--Create table
CREATE TABLE TestMax
(
Year1 INT
,Max1 INT
,Max2 INT
,Max3 INT
)
GO
 
--Insert data
INSERT INTO TestMax 
VALUES
 (2001,10,101,87)
,(2002,103,19,88)
,(2003,21,23,89)
,(2004,27,28,91)
 
--Select data
Select Year1,Max1,Max2,Max3 FROM TestMax;


--Solutons
-- A
SELECT year1, MAXVALUE =
CASE
    WHEN Max1>Max2 AND Max1>Max3 THEN Max1
    WHEN Max3>Max2 AND Max3>Max1 THEN Max3
    WHEN Max2>Max1 AND Max2>Max3 THEN Max2
END
FROM TestMax;

-- B WITH UNPIVOT
 WITH TMP AS (
    SELECT Year1, Mn, Vals
    FROM TestMax
        UNPIVOT (
            Vals
        FOR Mn IN (Max1, Max2, Max3)
             )
        AS RES
)
SELECT Year1, MAX(Vals) AS MaxVal
FROM TMP
    GROUP BY Year1;

 /*
13.Using joins, find the employees with salary greater than their manager.
 */

 --Sample Input
-- EmpID	EmpName	EmpSalary	MgrID
-- 1		Pawan	80000		4
-- 2		Dheeraj	70000		4
-- 3		Isha	100000		4
-- 4		Joteep	90000		NULL
-- 5		Suchita	110000		4
--
-- --Expected Output
-- EmpID	EmpName	EmpSalary	MgrID
-- 3		Isha	100000		4
-- 5		Suchita	110000		4


--Create table
CREATE TABLE [dbo].[Person]
(
[EmpID] [int] NULL,
[EmpName] [varchar](50) NULL,
[EmpSalary] [bigint] NULL,
[MgrID] [int] NULL
)
GO
 
--Insert Data
INSERT INTO [Person](EmpID,EmpName,EmpSalary,MgrID)
VALUES
(1,    'Pawan',      80000, 4),
(2,    'Dheeraj',    70000, 4),
(3,    'Isha',       100000,       4),
(4,    'Joteep',     90000, NULL),
(5,    'Suchita',    110000,       4)
 
--Verify Data
SELECT * FROM [dbo].[Person];

--Solution
SELECT S.EMPID, S.EMPNAME, S.EmpSalary, S.MgrID
FROM dbo.Person F
    INNER JOIN dbo.Person S
    ON F.EmpID = S.MgrID
    WHERE F.EmpSalary < S.EmpSalary;

-- B
WITH TMP AS (
    SELECT P.EmpID, P.EmpName, P.EmpSalary, T.EmpName AS ManName
    FROM Person P
        LEFT JOIN Person T ON P.MgrID=T.EmpID
)
SELECT EmpID, EmpName, EmpSalary FROM TMP
    WHERE EmpSalary > (SELECT EmpSalary FROM TMP WHERE ManName IS NULL);



/* Here you have to give 3 ways of solving this problem, using PIVOT, GROUP BY and JOINS

14. Using PIVOT OPERATOR,  count all different fruits per person.
Please see the sample input and expected output for udernstanding better.

NOTE: DO YOU THINK WE CAN ACHIEVE THIS RESULT USING GROUP BY AND JOINS?? 
THE ANSWER IS YES, please provide the same solution using Group by and Joins
*/

--Sample Input
--
-- Name	Fruit
-- Neeraj	MANGO
-- Neeraj	MANGO
-- Neeraj	MANGO
-- Neeraj	APPLE
-- Neeraj	ORANGE
-- Neeraj	LICHI
-- Neeraj	LICHI
-- Neeraj	LICHI
-- Isha	MANGO
-- Isha	MANGO
-- Isha	APPLE
-- Isha	ORANGE
-- Isha	LICHI
-- Gopal	MANGO
-- Gopal	MANGO
-- Gopal	APPLE
-- Gopal	APPLE
-- Gopal	APPLE
-- Gopal	ORANGE
-- Gopal	LICHI
-- Mayank	MANGO
-- Mayank	MANGO
-- Mayank	APPLE
-- Mayank	APPLE
-- Mayank	ORANGE
-- Mayank	LICHI
--
--
-- -- Expected Output
-- Name	MangoCount	APPLECount	LICHICount	ORANGECount
-- Gopal		2			3			1			1
-- Isha		2			1			1			1
-- Mayank		2			2			1			1
-- Neeraj		3			1			3			1


--Create table
CREATE TABLE tblFruit
(
Name VARCHAR(20)
,Fruit VARCHAR(25)
)
GO
 
--Insert Data
INSERT INTO tblFruit(Name,Fruit) VALUES
('Neeraj'    ,'MANGO'),
('Neeraj'    ,'MANGO'),
('Neeraj'    ,'MANGO'),
('Neeraj'    ,'APPLE'),
('Neeraj'    ,'ORANGE'),
('Neeraj'    ,'LICHI'),
('Neeraj'    ,'LICHI'),
('Neeraj'    ,'LICHI'),
('Isha'     ,'MANGO'),
('Isha'     ,'MANGO'),
('Isha'     ,'APPLE'),
('Isha'     ,'ORANGE'),
('Isha'     ,'LICHI'),
('Gopal' ,'MANGO'),
('Gopal' ,'MANGO'),
('Gopal' ,'APPLE'),
('Gopal' ,'APPLE'),
('Gopal' ,'APPLE'),
('Gopal' ,'ORANGE'),
('Gopal' ,'LICHI'),
('Mayank'  ,'MANGO'),
('Mayank'  ,'MANGO'),
('Mayank'  ,'APPLE'),
('Mayank'  ,'APPLE'),
('Mayank'  ,'ORANGE'),
('Mayank'  ,'LICHI')
 
--Verify Data
SELECT Name,Fruit FROM tblFruit;

--Sotution:
-- PIVOT OPERATOR
SELECT Name, Mango AS MangoCount, Apple AS AppleCount, Orange AS OrangeCount, Lichi AS LichiCount
FROM tblFruit
    PIVOT (
        COUNT(Fruit)
        FOR Fruit IN (Mango, Apple, Orange, Lichi)
    ) AS F;

-- WITHOUT PIVOT, USING GROUP BY

SELECT [NAME], MangoCount = SUM(IIF(Fruit = 'Mango', 1, 0)),
       AppleCount = SUM(IIF(Fruit = 'Apple', 1, 0)),
       OrangeCount = SUM(IIF(Fruit = 'Orange', 1, 0)),
       LichiCount = SUM(IIF(Fruit = 'Lichi', 1, 0))
       FROM tblFruit
           GROUP BY [Name];

-- WITHOUT PIVOT, USING JOINS

SELECT A.[Name], AppleCount, MangoCount, OrangeCount, LichiCount FROM
              (
              SELECT DISTINCT [Name], COUNT(IIF(Fruit='APPLE', 1, 0)) AS AppleCount
                    FROM tblFruit
                        GROUP BY [NAME]
                  ) A
INNER JOIN (
    SELECT DISTINCT [Name], COUNT(IIF(Fruit='Mango', 1, 0)) AS MangoCount
FROM tblFruit
GROUP BY [NAME]
                  ) M
                ON A.Name = M.Name
INNER JOIN (
    SELECT DISTINCT [Name], COUNT(IIF(Fruit='Orange', 1, 0)) AS OrangeCount
FROM tblFruit
GROUP BY [NAME]
                  ) O
            ON A.Name = O.Name
INNER JOIN (
    SELECT DISTINCT [Name], COUNT(IIF(Fruit='Lichi', 1, 0)) AS LichiCount
FROM tblFruit
GROUP BY [NAME]
                  ) L
            ON A.Name = L.Name;