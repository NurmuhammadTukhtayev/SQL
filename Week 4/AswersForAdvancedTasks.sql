USE Northwind_SPP;

--24. How many cost changes do products generally have?
--We've worked on many problems based on the ProductCostHistory table. We know that the cost 
--for some products has changed more than for other products. Write a query that shows how 
--many cost changes that products have, in general. 
--For this query, you can ignore the fact that in ProductCostHistory, sometimes there's an 
--additional record for a product where the cost didn't actually change.

SELECT * FROM ProductCostHistory;

WITH TMP AS (
SELECT ProductID,  COUNT(StartDate) AS TOTAL
FROM ProductCostHistory
GROUP BY ProductID
)
SELECT TMP.TOTAL, COUNT(PRODUCTID) AS TP
FROM TMP
GROUP BY TOTAL;

--25. Size and base ProductNumber for products
--The ProductNumber field in the Product table comes from the vendor of the product. The size is
--sometimes a part of this field.
--We need to get the base ProductNumber (without the size), and then the size separately. Some
--products do not have a size. For those products, the base ProductNumber will be the same as the
--ProductNumber, and the size field will be null.
--Limit the results to those ProductIDs that are greater than 533. Sort by ProductID.

SELECT ProductID, ProductNumber,
	CHARINDEX('-', ProductNumber) AS HyphenLocation,
	IIF(CHARINDEX('-', ProductNumber)=0, ProductNumber, SUBSTRING(ProductNumber, 0, CHARINDEX('-', ProductNumber)))  
		AS BaseProductNumber,
	IIF(CHARINDEX('-', ProductNumber)=0, NULL, SUBSTRING(ProductNumber, CHARINDEX('-', ProductNumber)+1, LEN(ProductNumber))) 
		AS Size
FROM Product
WHERE ProductID > 533;

--26. Number of sizes for each base product number
--Now we'd like to get all the base ProductNumbers, and the number of sizes that they have.
--Use the output of the previous problem to get the results. However, do not use the filter from the
--previous problem (ProductIDs that are greater than 533). Instead of that filter, select only those
--products that are clothing (ProductCategory = 3).
--Order by the base ProductNumber.

SELECT ProductID, ProductNumber,
	CHARINDEX('-', ProductNumber) AS HyphenLocation,
	IIF(CHARINDEX('-', ProductNumber)=0, ProductNumber, SUBSTRING(ProductNumber, 0, CHARINDEX('-', ProductNumber)))  
		AS BaseProductNumber,
	IIF(CHARINDEX('-', ProductNumber)=0, NULL, SUBSTRING(ProductNumber, CHARINDEX('-', ProductNumber)+1, LEN(ProductNumber))) 
		AS Size,
	PS.ProductCategoryID
	INTO #TMP
FROM Product P
	INNER JOIN ProductSubcategory PS
		ON PS.ProductSubcategoryID = P.ProductSubcategoryID
WHERE PS.ProductCategoryID = 3;

SELECT BaseProductNumber, COUNT(BaseProductNumber) AS TOTAL
FROM #TMP
GROUP BY BaseProductNumber
ORDER BY BaseProductNumber;


--27. How many cost changes has each product really had?
--A sharp-eyed analyst has pointed out that the total number of product cost changes (from the
--problem “Cost changes for each product” is not right. Why? Because sometimes, even when
--there's a new record in the ProductCostHistory table, the cost is not actually different from the
--previous record!
--This eventually will require a fix to the database, to make sure that we do not allow a record like
--this to be entered. This could be done as a table constraint, or a change to the code used to insert
--the row.
--However, for now, let's just get an accurate count of cost changes per product, where the cost has
--actually changed. Also include the initial row for a product, even if there's only 1 record.
--Sort the output by ProductID.

WITH tmp AS (
   SELECT ProductID,
          StandardCost,
          LAG(StandardCost) over (PARTITION BY ProductID ORDER BY StartDate) AS ncost
   FROM ProductCostHistory
)
SELECT  tmp.ProductID,
        P.ProductName,
        count(tmp.StandardCost) AS TotalCostChanges
FROM tmp INNER JOIN  Product P ON P.ProductID = tmp.ProductID
WHERE tmp.StandardCost<>ncost OR ncost IS NULL
GROUP BY tmp.ProductID , P.ProductName;


--28. Which products had the largest increase in cost?
--We'd like to show which products have had the largest, one time increases in cost. Show all of
--the price increases (and decreases), in decreasing order of difference.
--Don't show any records for which there is no price difference. For instance, if a product only has
--1 record in the cost history table, you would not show it in the output, because there has been no
--change in the cost history.

WITH tmp AS (
   SELECT ProductID,
          StandardCost,
          StartDate,
          LAG(StandardCost) over (PARTITION BY ProductID ORDER BY ProductID) AS COST
   FROM ProductCostHistory
)
SELECT  tmp.ProductID,
        tmp.StartDate,
        P.ProductName ,
        tmp.COST-tmp.StandardCost AS PriceDifference
FROM tmp INNER JOIN  Product P ON P.ProductID = tmp.ProductID
WHERE tmp.StandardCost<>COST
ORDER BY PriceDifference DESC;


--29. Fix this SQL! Number 3
--There's been some problems with fraudulent transactions. The data science team has requested,
--for a machine learning job, a unusual set of records. It should include data for 11 CustomerIDs
--that are specifically identified as fraudulent. It should also include a set of 100 random
--customers. The set of 100 random customers must exclude the 11 customers suspected of fraud.
--The SQL below solves the problem. However, there's a problem with this SQL, which is that the
--list of bad customers is repeated twice. Having hard-coded numbers or lists of numbers in SQL is
--not a good idea in general. But duplicating them is even worse, because of the potential that they
--will get out of sync.
--Improve this SQL by not repeating the hard-coded list of CustomerIDs that are fraud suspects.

with FraudSuspects as (
	Select *
From Customer
	Where
CustomerID in (29401,11194,16490,22698,26583,12166,16036,25110,18172,11997,26731))
, SampleCustomers as (
Select top 100 *
From Customer
Where
CustomerID not in (29401,11194,16490,22698,26583,12166,16036,25110,18172,11997,26731)
Order by
NewID()
)
Select * From FraudSuspects
Union
Select * From SampleCustomers

--30. History table with start/end date overlap
--There is a product that has an overlapping date ranges in the ProductListPriceHistory table.
--Find the products with overlapping records, and show the dates that overlap.

SELECT * FROM ProductListPriceHistory;

SELECT * FROM Calendar;

WITH TMP AS (
SELECT ProductID,
           CalendarDate
    FROM ProductListPriceHistory,
         Calendar
    WHERE CalendarDate BETWEEN StartDate AND EndDate
	)
	SELECT CalendarDate, ProductID, COUNT(*) AS TOTAL
	FROM TMP
	GROUP BY CalendarDate, ProductID
	HAVING COUNT(*) = 2;

--31. History table with start/end date overlap, part 2
--It turns out that the SQL that was provided in the Answer section for the previous problem has an
--error. It's missing a ProductID that also has a date range overlap.
--If you wrote SQL that actually showed 2 separate ProductIDs—great job!
--If you didn't, then fix the SQL for the previous problem to show all date range overlaps
--Sort the results by ProductID and CalendarDate.

WITH TMP AS (
SELECT ProductID,
           CalendarDate
    FROM ProductListPriceHistory,
         Calendar
    WHERE CalendarDate BETWEEN StartDate AND EndDate
	)
	SELECT CalendarDate, ProductID, COUNT(*) AS TOTAL
	FROM TMP
	GROUP BY CalendarDate, ProductID
	HAVING COUNT(*) = 2;

--32. Running total of orders in last year
--For the company dashboard we'd like to calculate the total number of orders, by month, as well
--as the running total of orders.
--Limit the rows to the last year of orders. Sort by calendar month.

SELECT * FROM SalesOrderHeader;

DECLARE @dn date;
SET @dn='2014-06-30';
SELECT CalendarMonth,
       COUNT(DISTINCT  SalesOrderID) AS TotalOrders,
       SUM(COUNT(DISTINCT  SalesOrderID)) OVER(ORDER BY CalendarMonth) AS  RunningTotal
FROM  SalesOrderHeader
    INNER JOIN  Calendar ON CalendarMonth = FORMAT(OrderDate,'yyyy/MM - MMM')
WHERE OrderDate BETWEEN DATEADD(YEAR,-1,@dn) and @dn
GROUP BY  CalendarMonth
ORDER BY CalendarMonth;


--33. Total late orders by territory
--Show the number of total orders, and the number of orders that are late.
--For this problem, an order is late when the DueDate is before the ShipDate.
--Group and sort the rows by Territory.

SELECT ST.TerritoryID, ST.TerritoryName, CountryCode, COUNT(SalesOrderID) AS TotalOrders,
COUNT(IIF(ShipDate>DueDate,0,NULL)) AS TotalLateOrders
FROM SalesOrderHeader SOH
	INNER JOIN SalesTerritory ST
	ON ST.TerritoryID = SOH.TerritoryID
	GROUP BY ST.TerritoryID, ST.TerritoryName, CountryCode
	ORDER BY ST.TerritoryID;

--34. OrderDate with time component—performance aspects
--We don't go often get into performance issues in these practice problems. But there's many
--different ways of getting the answer to the problem “OrderDate with time component”. Looking
--at the different answers gives us a good opportunity to look at the performance implications of
--different strategies.
--Below are 4 SQL statements to solve the problem of how many OrderDate values in the
--SalesOrderHeader table have a time component.
--Figure out which of the below solutions is the most efficient in terms of performance.
--Performance testing has many different aspects, but for this problem, use the “logical reads”
--output that you get when using the “STATISTICS IO” option. The number of logical reads used
--by a SQL statement is a good metric for the amount of resources used.
--First, read up on “STATISTICS IO” and “logical reads” online. Then, turn on Statistics IO in
--your query. 

-----------------------------------------
-- Solution #1
-----------------------------------------
SET STATISTICS IO ON
Select
 OrdersWithTime.TotalOrderWithTime
 ,TotalOrders.TotalOrders
 ,PercentOrdersWithTime =
 OrdersWithTime.TotalOrderWithTime * 1.0
 /
 TotalOrders.TotalOrders
From
 (Select TotalOrderWithTime = Count(*)
 from SalesOrderHeader
 where OrderDate <> Convert(date, OrderDate))
 OrdersWithTime
 full outer join
 (Select TotalOrders = Count(*)
 from SalesOrderHeader )
 TotalOrders
 on 1 = 1 

--The SalesOrderHeader table. 2 scans, 40 logical reads, 0 physical reads, page server reads 0,
--lookahead reads 0, page server reads ahead of 0, LOB logical reads 0, physical LOB reads 0, 
--Page server LOB 0 reads, 0 lookahead LOB reads, 0 page server LOB reads lookahead.

-----------------------------------------
-- Solution #2
-----------------------------------------
with OrdersWithTime as (
 Select TotalOrderWithTime = Count(*)
 from SalesOrderHeader
 where OrderDate <> Convert(date, OrderDate)
)
, TotalOrders as (
 Select TotalOrders = Count(*)
 from SalesOrderHeader
)
Select
 OrdersWithTime.TotalOrderWithTime
 ,TotalOrders.TotalOrders
 ,PercentOrdersWithTime =
 OrdersWithTime.TotalOrderWithTime * 1.0
 /
 TotalOrders.TotalOrders
from OrdersWithTime
 full outer join TotalOrders
 on 1=1 

 --The SalesOrderHeader table. 2 scans, 40 logical reads, 0 physical reads, page server reads 0, 
 --lookahead reads 0, page server reads ahead of 0, LOB logical reads 0, physical LOB reads 0, 
 --Page server LOB 0 reads, 0 lookahead LOB reads, 0 page server LOB reads lookahead.

 -----------------------------------------
-- Solution #3
-----------------------------------------
Select
TotalOrderWithTime = (Select Count(*)
 from SalesOrderHeader
 where OrderDate <> Convert(date, OrderDate))
 ,TotalOrders =
 (Select Count(*) from SalesOrderHeader )
 ,PercentOrdersWithTime =
 (Select Count(*) from
 SalesOrderHeader
 where OrderDate <> Convert(date, OrderDate)) * 1.0
 /
 (Select Count(*)
 from SalesOrderHeader )

 --The SalesOrderHeader table. 4 scans, logical reads 80, physical reads 0, page server reads 0, 
 --reads ahead of 0, page server reads ahead of 0, logical LOB reads 0, physical LOBs 0,
 --Page server LOB 0 reads, 0 lookahead LOB reads, Page server LOB reads 0.

 -----------------------------------------
-- Solution #4
-----------------------------------------
;with Main as (
 Select
 SalesOrderID
 ,HasTimeComponent =
 case
 When OrderDate <> Convert(date, OrderDate)
 then 1
 else 0
 end
 From SalesOrderHeader
)
Select
 TotalOrdersWithTime =Sum(HasTimeComponent )
 ,TotalOrders = Count(*)
 ,PercentOrdersWithTime =
 Sum(HasTimeComponent ) * 1.0
 /
 Count(*)
From Main;

--The SalesOrderHeader table. Scans 1, logical reads 20, physical reads 0, page server reads 0, 
--reads ahead of 0, page server reads ahead of 0, logical LOB reads 0, physical LOBs 0, 
--Page server LOB 0 reads, 0 lookahead LOB reads, Page server LOB reads 0.


--35. Customer's last purchase—what was the product subcategory?
--For a limited list of customers, we need to show the product subcategory of their last purchase. If
--they made more than one purchase on a particular day, then show the one that cost the most. 

WITH P AS (
    SELECT P.ProductID,
           PS.ProductSubCategoryName
    FROM Product P
        INNER JOIN ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
),
 O AS (
   SELECT SOD.ProductID ,
          SOD.LineTotal,
          SalesOrderHeader.*
   FROM SalesOrderHeader
        inner join SalesOrderDetail SOD ON SalesOrderHeader.SalesOrderID = SOD.SalesOrderID
),tmp AS (
SELECT O.CustomerID,
       O.OrderDate ,
       O.SalesOrderID,
       P.ProductID,
       O.LineTotal ,
       P.ProductSubCategoryName,
       ROW_NUMBER() over (PARTITION BY O.CustomerID ORDER BY  C.CustomerID,OrderDate DESC, LineTotal DESC) AS r
FROM O
 INNER JOIN Customer C on O.CustomerID = C.CustomerID
 INNER JOIN P ON O.ProductID = P.ProductID
WHERE O.CustomerID IN (19500,19792,24409,26785)
    )

SELECT tmp.CustomerID,
       Customer.FirstName+' '+Customer.LastName,
       tmp.ProductSubCategoryName
FROM tmp INNER JOIN  Customer ON Customer.CustomerID = tmp.CustomerID
WHERE r=1

--36. Order processing: time in each stage
--When an order is placed, it goes through different stages, such as processed, readied for pick up,
--in transit, delivered, etc.
--How much time does each order spend in the different stages?
--To figure out which tables to use, take a look at the list of tables in the database. You should be
--able to figure out the tables to use from the table names.
--Limit the orders to these SalesOrderIDs:
--68857
--70531
--70421
--Sort by the SalesOrderID, and then the date/time.

SELECT OT.SalesOrderID,
       TE.EventName ,
       OT.EventDateTime AS TrackingEventDate,
       LEAD(EventDateTime) over (PARTITION BY SalesOrderID ORDER BY EventDateTime) AS NextTrackingEventDate
INTO #TMP
FROM OrderTracking OT INNER JOIN  TrackingEvent TE on OT.TrackingEventID = TE.TrackingEventID
WHERE SalesOrderID IN (68857,70531,70421)

SELECT *,
       DATEDIFF(hour ,TrackingEventDate,NextTrackingEventDate) HoursInStage
FROM #TMP;

--37. Order processing: time in each stage, part 2
--Now we want to show the time spent in each stage of order processing. But instead of showing
--information for specific orders, we want to show aggregate data, by online vs offline orders.
--Sort first by OnlineOfflineStatus, and then TrackingEventID.

WITH TMP AS (
    SELECT OT.SalesOrderID, TE.EventName, TE.TrackingEventID,
    OT.EventDateTime AS TrackingEventDate,
            LEAD(EventDateTime) OVER (PARTITION BY SalesOrderID ORDER BY EventDateTime) AS NextTrackingEventDate
    FROM OrderTracking OT
        INNER JOIN TrackingEvent TE 
        ON OT.TrackingEventID = TE.TrackingEventID
        )
SELECT OnlineOfflineStatus = 
    CASE
    WHEN OnlineOrderFlag = 0 THEN 'OFFLINE' ELSE 'ONLINE' END,
    TMP.EventName, AVG(DATEDIFF(HOUR, TMP.TrackingEventDate, TMP.NextTrackingEventDate)) AS AverageHoursSpentInStage
FROM TMP
    INNER JOIN SalesOrderHeader ON TMP.SalesOrderID = SalesOrderHeader.SalesOrderID
    GROUP BY 
    CASE
        WHEN OnlineOrderFlag = 0 THEN 'OFFLINE' ELSE 'ONLINE' END,TMP.TrackingEventID, TMP.EventName
    ORDER By OnlineOfflineStatus, TMP.TrackingEventID;


--38. Order processing: time in each stage, part 3
--The previous query was very helpful to the operations manager, to help her get an overview of
--differences in order processing between online and offline orders.
--Now she has another request, which is to have the averages for online/offline status on the same
--line, to make it easier to compare.

WITH TMP AS (
    SELECT OT.SalesOrderID, TE.EventName, TE.TrackingEventID,
    OT.EventDateTime AS TrackingEventDate,
            LEAD(EventDateTime) OVER (PARTITION BY SalesOrderID ORDER BY EventDateTime) AS NextTrackingEventDate
    FROM OrderTracking OT
        INNER JOIN TrackingEvent TE 
        ON OT.TrackingEventID = TE.TrackingEventID
        )
SELECT OnlineOfflineStatus = 
    CASE
    WHEN OnlineOrderFlag = 0 THEN 'OFFLINE' ELSE 'ONLINE' END,
    TMP.EventName, AVG(DATEDIFF(HOUR, TMP.TrackingEventDate, TMP.NextTrackingEventDate)) AS AverageHoursSpentInStage
FROM TMP
    INNER JOIN SalesOrderHeader ON TMP.SalesOrderID = SalesOrderHeader.SalesOrderID
    GROUP BY 
    CASE
        WHEN OnlineOrderFlag = 0 THEN 'OFFLINE' ELSE 'ONLINE' END,TMP.TrackingEventID, TMP.EventName, OnlineOrderFlag
    HAVING OnlineOrderFlag = 1
    ORDER By OnlineOfflineStatus, TMP.TrackingEventID;

--39. Top three product subcategories per customer
--The marketing department would like to have a listing of customers, with the top 3 product
--subcategories that they've purchased.
--To define “top 3 product subcategories”, we'll order by the total amount purchased for those
--subcategories (i.e. the line total).
--Normally we'd run the query for all customers, but to make it easier to view the results, please
--limit to just the following customers:
--13763
--13836
--20331
--21113
--26313
--Sort the results by CustomerID

WITH  Cus AS (
    SELECT *FROM Customer
       WHERE CustomerID IN (13763,13836,20331,21113,26313)
),
 CusOrd AS (
     SELECT C.CustomerID,
            C.FirstName+' '+C.LastName As CustomerName,
            SOH.SalesOrderID
     FROM SalesOrderHeader AS SOH
         INNER JOIN Cus C on SOH.CustomerID = C.CustomerID
 ),
 CusOrdOD AS (
     SELECT CO.* ,
            SOD.ProductID,
            SOD.LineTotal
     FROM SalesOrderDetail SOD
         INNER JOIN  CusOrd CO ON CO.SalesOrderID=SOD.SalesOrderID
 ),ProSub AS (
     SELECT ProductID,
            PS.ProductSubCategoryName
     FROM Product
       INNER JOIN ProductSubcategory PS on Product.ProductSubcategoryID = PS.ProductSubcategoryID
),CusPro AS (
    SELECT CusOrdOD.CustomerID,
           CusOrdOD.CustomerName,
           ProSub.ProductSubCategoryName,
           MAX(CusOrdOD.LineTotal) As LineTotal
    FROM CusOrdOD
        INNER JOIN ProSub ON CusOrdOD.ProductID = ProSub.ProductID
    GROUP BY CusOrdOD.CustomerID,CusOrdOD.CustomerName,ProSub.ProductSubCategoryName
), ans AS(
SELECT CusPro.* ,
       row_number() over (PARTITION BY CustomerID ORDER BY CustomerID,LineTotal DESC) r
FROM CusPro
)

SELECT CustomerID,
       CustomerName,
       [1] AS TopProdSubCat1,
       [2] AS TopProdSubCat1 ,
       [3] AS TopProdSubCat1
FROM (
    SELECT CustomerID,
           CustomerName,
           ProductSubCategoryName,
           r
    FROM ans
) as t
PIVOT (
    max(t.ProductSubCategoryName)
    for r in([1],[2],[3])
) as sv
ORDER BY CustomerID

--40. History table with date gaps
--It turns out that, in addition to overlaps, there are also some gaps in the ProductListPriceHistory
--table. That is, there are some date ranges for which there are no list prices. We need to find the
--products and the dates for which there are no list prices.
--This is one of the most challenging and fun problems in this book, so take your time and enjoy it!
--Try doing it first without any hints, because even if you don't manage to solve the problem, you
--will have learned much more.

WITH PD AS (
    SELECT ProductID,
           Min(StartDate)                     AS FirstStartDate,
           Max(IsNull(EndDate, '2014-05-29')) AS LastEndDate
    FROM ProductListPriceHistory
    GROUP BY ProductID
) ,
ptmp AS (
SELECT ProductID,
       CalendarDate
FROM PD full join Calendar
ON CalendarDate>=FirstStartDate AND CalendarDate<=LastEndDate
)

SELECT ptmp.ProductID,
       CalendarDate AS DateWithMissingPrice
FROM ProductListPriceHistory PLH RIGHT JOIN ptmp
ON ptmp.ProductID=PLH.ProductID AND
   ptmp.CalendarDate BETWEEN StartDate AND  IsNull(EndDate, '2014-05-29')
WHERE PLH.ProductID IS NULL and ptmp.ProductID is not NULL
ORDER BY ProductID