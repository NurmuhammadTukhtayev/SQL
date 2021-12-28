USE Northwind_SPP;
-- SHOW ALL TABLES
SELECT
  *
FROM
  INFORMATION_SCHEMA.TABLES;

-- 1. Cost changes for each product
--There's a table called ProductCostHistory which contains the history of the cost of the product. 
--Using that table, get the total number of times the product cost has changed.
--Sort the results by ProductID

SELECT DISTINCT 
ProductID, COUNT(ProductID) OVER (PARTITION BY ProductID) AS TotalPriceChanges
FROM ProductCostHistory
ORDER BY ProductID;


-- 2. Customers with total orders placed
--We want to see a list of all the customers that have made orders, and the total number of orders 
--the customer has made.
--Sort by the total number of orders, in descending order

SELECT C.CustomerID ,
       COUNT(SalesOrderID)  AS TotalOrders
FROM Customer C INNER JOIN SalesOrderHeader S on C.CustomerID = S.CustomerID
GROUP BY C.CustomerID
ORDER BY  TotalOrders DESC

--3. Products with first and last order date 
--For each product that was ordered, show the first and last date that it was ordered. 
--In the previous problem I gave you the table name to use. For this problem, look at the list of 
--tables, and figure out which ones you need to use.
--Sort the results by ProductID

SELECT ProductID,
	CONVERT(VARCHAR, MIN(ORDERDATE), 23) AS FIRSRORDER,
	CONVERT(VARCHAR, MAX(ORDERDATE), 23) AS LASTORDER
FROM SALESORDERDETAIL SOD
INNER JOIN SALESORDERHEADER SOH
	ON SOD.SALESORDERID = SOH.SALESORDERID
	GROUP BY ProductID
	ORDER BY ProductID;

--4. Products with first and last order date, including name
--For each product that was ordered, show the first and last date that it was ordered. This time, 
--include the name of the product in the output, to make it easier to understand.
--Sort the results by ProductID.

SELECT * FROM SALESORDERDETAIL;
SELECT * FROM SALESORDERHEADER;
SELECT * FROM Products;

SELECT SOD.ProductID, P.ProductName,
  CONVERT(VARCHAR, MIN(ORDERDATE), 23) AS FIRSRORDER,
  CONVERT(VARCHAR, MAX(ORDERDATE), 23) AS LASTORDER
FROM SALESORDERDETAIL SOD
 JOIN SALESORDERHEADER SOH
  ON SOD.SALESORDERID = SOH.SALESORDERID
 JOIN Product P
  ON P.ProductID = SOD.ProductID
  GROUP BY SOD.ProductID, P.ProductName
  ORDER BY ProductID;

--5. Product cost on a specific date
--We'd like to get a list of the cost of products, as of a certain date, 2012-04-15. Use the 
--ProductCostHistory to get the results.
--Sort the output by ProductID.
SELECT * FROM ProductCostHistory;

SELECT ProductID, STANDARDCOST
FROM ProductCostHistory
WHERE STARTDATE<='2012-04-15' AND  ENDDATE>='2012-04-15';

--6. Product cost on a specific date, part 2
--It turns out that the answer to the above problem has a problem. Change the date to 2014-04-15. 
--What are your results? 
--If you use the SQL from the answer above, and just change the date, you won't get the results 
--you want.
--Fix the SQL so it gives the correct results with the new date. Note that when the EndDate is null, 
--that means that price is applicable into the future.

SELECT ProductID, STANDARDCOST
FROM ProductCostHistory
WHERE (STARTDATE<='2012-04-15' AND  ENDDATE>='2012-04-15')
OR (STARTDATE<='2012-04-15' AND ENDDATE IS NULL)
ORDER BY ProductID;


--7. Product List Price: how many price changes?
--Show the months from the ProductListPriceHistory table, and the total number of changes made 
--in that month.
SELECT * FROM ProductListPriceHistory;

SELECT FORMAT(STARTDATE, 'yyyy/MM') AS ProductListPriceMonth, COUNT(*) AS TotalRows
FROM ProductListPriceHistory
GROUP BY FORMAT(STARTDATE, 'yyyy/MM');

--8. Product List Price: months with no price changes?
--After reviewing the results of the previous query, it looks like price changes are made only
--in one month of the year.
--We want a query that makes this pattern very clear. Show all months 
--(within the range of StartDate values in ProductListPriceHistory). 
--This includes the months during which no prices were changed.

SELECT * FROM Calendar;

WITH TMP AS (
SELECT FORMAT(STARTDATE, 'yyyy/MM - MMM', 'en-US') AS ProductListPriceMonth, COUNT(*) AS TotalRows
FROM ProductListPriceHistory
GROUP BY FORMAT(STARTDATE, 'yyyy/MM - MMM', 'en-US')
)

SELECT DISTINCT CalendarMonth, ISNULL(TMP.TotalRows, 0)
FROM Calendar
LEFT JOIN TMP
ON Calendar.CalendarMonth = TMP.ProductListPriceMonth
WHERE CALENDARMONTH BETWEEN '2011/05' AND '2013/06'
ORDER BY CalendarMonth;


--9. Current list price of every product
--What is the current list price of every product, using the ProductListPrice history?
--Order by ProductID

SELECT DISTINCT ProductID, LISTPRICE
FROM ProductListPriceHistory
WHERE EndDate IS NULL
ORDER BY ProductID;

--10. Products without a list price history
--Show a list of all products that do not have any entries in the list price history table.
--Sort the results by ProductID

SELECT P.ProductID, P.PRODUCTNAME
FROM ProductListPriceHistory PLHP
RIGHT JOIN Product P
ON PLHP.ProductID = P.ProductID
WHERE PLHP.ProductID IS NULL;

--11. Product cost on a specific date, part 3
--In the earlier problem “Product cost on a specific date, part 2”, this answer was given:
SELECT ProductID, StandardCost
	From ProductCostHistory
Where '2014-04-15' Between StartDate and IsNull(EndDate, getdate())
	Order By ProductID;

--However, there are many ProductIDs that exist in the ProductCostHistory table that 
--don’t show up in this list.
--Show every ProductID in the ProductCostHistory table that does not appear when you run 
--the above SQL.

SELECT DISTINCT ProductID 
FROM ProductCostHistory
WHERE ProductID NOT IN (
	Select ProductID
	From ProductCostHistory
	Where '2014-04-15' Between StartDate and IsNull(EndDate, getdate())
)

--12. Products with multiple current list price records
--There should only be one current price for each product in the ProductListPriceHistory table, 
--but unfortunately some products have multiple current records.
--Find all these, and sort by ProductID

SELECT ProductID
FROM ProductListPriceHistory
WHERE EndDate IS NULL
GROUP BY ProductID
HAVING COUNT(ProductID)>1
ORDER BY ProductID;

--13. Products with their first and last order date, including name and subcategory
--In the problem “Products with their first and last order date, including name", we looked only at 
--product that have been ordered. 
--It turns out that there are many products that have never been ordered.
--This time, show all the products, and the first and last order date. Include the product 
--subcategory as well.
--Sort by the ProductName field.

SELECT * FROM Product
SELECT * FROM ProductSubcategory
SELECT * FROM SalesOrderDetail
SELECT * FROM SalesOrderHeader

SELECT  P.ProductID,
        P.ProductName,
        PSC.ProductSubCategoryName,
        ISNULL(CONVERT(varchar,MIN(OrderDate),23),NULL) AS FirstOrder,
        ISNULL(CONVERT(varchar,MAX(OrderDate),23),NULL) AS LastOrder
FROM Product P
     LEFT JOIN  SalesOrderDetail SD ON SD.ProductID = P.ProductID
     LEFT JOIN  SalesOrderHeader SOH ON SD.SalesOrderID = SOH.SalesOrderID
     LEFT JOIN  ProductSubcategory PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
GROUP BY  P.ProductID, P.ProductName,  PSC.ProductSubCategoryName
ORDER BY  P.ProductName

--14. Products with list price discrepancies 
--It's astonishing how much work with SQL and data is in finding and resolving discrepancies in 
--data. Some of the salespeople have told us that the current price in the price list history doesn't 
--seem to match the actual list price in the Product table. 
--Find all these discrepancies. Sort the results by ProductID.


SELECT * INTO #last_price FROM ProductListPriceHistory WHERE EndDate IS NULL
SELECT
    P.ProductID,
       P.ListPrice AS Prod_ListPrice ,
       #last_price.ListPrice AS Prod_ListPrice ,
       P.ListPrice-#last_price.ListPrice AS Diff
FROM  Product p INNER JOIN  #last_price on P.ProductID = #last_price.ProductID
WHERE P.ListPrice<>#last_price.ListPrice


--15. Orders for products that were unavailable 
--It looks like some products were sold before or after they were supposed to be sold, based on the 
--SellStartDate and SellEndDate in the Product table. Show a list of these orders, with details.
--Sort the results by ProductID, then OrderDate.

WITH tmp AS (
    SELECT OrderQty,OrderDate,ProductID FROM SalesOrderHeader
        INNER JOIN SalesOrderDetail SOD on SalesOrderHeader.SalesOrderID = SOD.SalesOrderID
),
ans AS (
SELECT
       P.ProductID,
       FORMAT(OrderDate,'yyyy-MM-dd') AS OrderDate,
       ProductName,
       OrderQty AS Qty,
       SellStartDate,
       SellEndDate
FROM Product P
    INNER JOIN tmp ON tmp.ProductID = P.ProductID
WHERE OrderDate NOT BETWEEN  P.SellStartDate  AND ISNULL(SellEndDate,getdate())
    )
SELECT * FROM ans  ORDER BY  ProductID, OrderDate


--16. Orders for products that were unavailable: details 
--We'd like to get more details on when products that were supposed to be unavailable were 
--ordered. 
--Create a new column that shows whether the product was ordered before the sell start date, or 
--after the sell end date. 
--Sort the results by ProductID and OrderDate.

WITH tmp AS (
    SELECT OrderQty,OrderDate,ProductID FROM SalesOrderHeader
        INNER JOIN SalesOrderDetail SOD on SalesOrderHeader.SalesOrderID = SOD.SalesOrderID
)
SELECT P.ProductID,
       FORMAT(OrderDate,'yyyy-MM-dd') AS OrderDate,
       ProductName,
       OrderQty AS Qty,
       SellStartDate,
       SellEndDate,
       CASE
         WHEN OrderDate<P.SellStartDate  THEN 'Sold after start date'
         ELSE 'Sold before end date'
       END AS ProblemType
FROM Product P
    INNER JOIN tmp ON tmp.ProductID = P.ProductID
WHERE OrderDate NOT BETWEEN  P.SellStartDate  AND ISNULL(SellEndDate,getdate())
ORDER BY  ProductID,OrderDate;


--17. OrderDate with time component
--How many OrderDate values in SalesOrderHeader have a time component to them? 
--Show the results as below.

--DECLARE @tot INT
DECLARE @tot INT = (SELECT count(*) FROM SalesOrderHeader
WHERE DATEDIFF(SECOND,OrderDate, FORMAT(OrderDate,'yyyy-MM-dd'))<>0)
DECLARE @to INT = (SELECT count(*) FROM SalesOrderHeader)
DECLARE @pot float = 1.0*@tot/@to;

SELECT @tot AS TotalOrderWithTime, @to AS TotalOrders, @pot AS PercentOrdersWithTime;

--18. Fix this SQL! Number 1 
--We want to show details about certain products (name, subcategory, first order date, last order 
--date), similar to what we did in a previous query.
--This time, we only want to show the data for products that have Silver in the color field. You 
--know, by looking at the Product table directly, that there are many products that have that color.
--A colleague sent you this query, and asked you to look at it. It seems correct, but it returns no 
--rows. What's wrong with it? 
Select 
 Product.ProductID
 ,ProductName
 ,ProductSubCategoryName 
 ,FirstOrder = Convert(date, Min(OrderDate))
 ,LastOrder = Convert(date, Max(OrderDate))
From Product 
 Left Join SalesOrderDetail Detail
 on Product.ProductID = Detail.ProductID
 Left Join SalesOrderHeader Header
 on Header.SalesOrderID = Detail .SalesOrderID
 Left Join ProductSubCategory 
 on ProductSubCategory .ProductSubCategoryID = Product.ProductSubCategoryID 
Where 
 'Color' = 'Silver'
Group by
 Product.ProductID
 ,ProductName
 ,ProductSubCategoryName 
Order by LastOrder desc

-- FIXED VERSION
SELECT Product.ProductID, ProductName, ProductSubCategoryName, 
       FirstOrder = CONVERT(DATE, MIN(OrderDate)), LastOrder = CONVERT(DATE, MAX(OrderDate))
FROM Product
LEFT JOIN SalesOrderDetail Detail
    ON Product.ProductID = Detail.ProductID
LEFT JOIN SalesOrderHeader Header
    ON Header.SalesOrderID = Detail .SalesOrderID
LEFT JOIN ProductSubCategory
    ON ProductSubCategory.ProductSubCategoryID = Product.ProductSubCategoryID
WHERE Color = 'Silver'
GROUP BY
    Product.ProductID, ProductName, ProductSubCategoryName
ORDER BY LastOrder DESC;

--19. Raw margin quartile for products
--The product manager would like to show information for all products about the raw margin –
--that is, the price minus the cost. Create a query that will show this information, as well as the raw 
--margin quartile. 
--For this problem, the quartile should be 1 if the raw margin of the product is in the top 25%, 2 if 
--the product is in the second 25%, etc.
--Sort the rows by the product name.

SELECT ProductID, ProductName, StandardCost, ListPrice, ListPrice-StandardCost AS RawMargin,
    NTILE(4)  OVER (ORDER BY ListPrice-StandardCost DESC) AS Quartile
FROM Product
    WHERE ListPrice-StandardCost<>0
ORDER BY ProductName


--20. Customers with purchases from multiple sales people
--Show all the customers that have made purchases from multiple sales people. 
--Sort the results by the customer name (first name plus last name).

SELECT C.CustomerID,
      CONCAT(FirstName,' ',LastName) AS CustomerName,
      COUNT(SalesPersonEmployeeID) AS TotalDifferentSalesPeople
FROM SalesOrderHeader
     INNER JOIN Customer C on SalesOrderHeader.CustomerID = C.CustomerID
GROUP BY C.CustomerID , CONCAT(FirstName,' ',LastName)
HAVING  COUNT(SalesPersonEmployeeID)>1
ORDER BY  CustomerName;

--21. Fix this SQL! Number 2
--A colleague has sent you the following SQL, which causes an error:
Select top 100 
 Customer.CustomerID
 ,CustomerName = FirstName + ' ' + LastName 
 ,OrderDate
 ,SalesOrderHeader.SalesOrderID 
 ,SalesOrderDetail.ProductID
 ,Product.ProductName
 ,LineTotal
From SalesOrderHeader 
 Join Product
 on Product.ProductID = SalesOrderDetail .ProductID
 Join SalesOrderDetail 
 on SalesOrderHeader .SalesOrderID = SalesOrderDetail .SalesOrderID 
 Join Customer
 on Customer.CustomerID = SalesOrderHeader.CustomerID
Order by 
 CustomerID
 ,OrderDate 

--The error it gives is this:
--Msg 4104, Level 16, State 1, Line 11
--The multi-part identifier "SalesOrderDetail.ProductID" could not be bound.
--Fix the SQL so it returns the correct results without error.

--FIXED QUERY
SELECT TOP 100
   Customer.CustomerID, CustomerName = FirstName + ' ' + LastName, OrderDate,
   SalesOrderHeader.SalesOrderID, SalesOrderDetail.ProductID, Product.ProductName, LineTotal
From SalesOrderHeader
INNER JOIN SalesOrderDetail
    ON SalesOrderHeader .SalesOrderID = SalesOrderDetail .SalesOrderID
INNER JOIN Product
    ON Product.ProductID = SalesOrderDetail.ProductID
INNER JOIN Customer
    ON Customer.CustomerID = SalesOrderHeader.CustomerID
ORDER BY CustomerID,OrderDate;

--22. Duplicate product
--It looks like the Product table may have duplicate records. Find the names of the products that 
--have duplicate records (based on having the same ProductName).

SELECT ProductName FROM Product
GROUP BY ProductName
HAVING COUNT(ProductName)>1;

--23. Duplicate product: details
--We'd like to get some details on the duplicate product issue. For each product that has duplicates, 
--show the product name and the specific ProductID that we believe to be the duplicate (the one 
--that's not the first ProductID for the product name).

SELECT MAX(ProductID) AS ProductID,
       ProductName FROM Product
GROUP BY  ProductName
HAVING  COUNT(ProductName)>1;