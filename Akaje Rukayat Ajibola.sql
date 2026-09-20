-------------------------------------------------
-- US Retail Sales Project - sql
-- name: Akaje Rukayat Ajibola
-- Dscription: Queries fot Data Cleaning and Analytics Insights



use oyinkansola;

rename table `original customer_usa 2` to customer_usa;
select * from customer_usa ;

select count(*) from customer_usa;

rename table `original region_usa` to region_usa;

select * from region_usa;

select count(*) from region_usa;

rename table `original sales_team_usa` to sales_team_usa;

select * from sales_team_usa;

select count(*) from sales_team_usa;

RENAME TABLE `orignial store_sales_usa 3` TO store_sales_usa;

select count(*) from store_sales_usa;
select * from store_sales_usa;

RENAME TABLE `original sales_order_usa` TO sales_order_usa;

select count(*) from sales_order_usa;

select * from sales_order_usa limit 10;

use oyinkansola;
show tables;

describe sales_order_usa;

select * from sales_order_usa limit 10;


UPDATE sales_order_usa 
SET orderDate = STR_TO_DATE(orderDate, '%d/%m/%Y')
where orderDate like '%/%';

set sql_safe_updates = 0; # to switch off safe mode


ALTER TABLE sales_order_usa 
MODIFY COLUMN orderDate DATE;

UPDATE sales_order_usa 
SET ProcuredDate = STR_TO_DATE(procuredDate, '%d/%m/%Y')
where procuredDate like '%/%';

ALTER TABLE sales_order_usa 
MODIFY COLUMN procuredDate DATE;

UPDATE sales_order_usa 
SET shipDate = STR_TO_DATE(shipDate, '%d/%m/%Y')
where shipDate like '%/%';

ALTER TABLE sales_order_usa 
MODIFY COLUMN shipDate DATE;

UPDATE sales_order_usa 
SET deliveryDate = STR_TO_DATE(deliveryDate, '%d/%m/%Y')
where deliveryDate like '%/%';

ALTER TABLE sales_order_usa 
MODIFY COLUMN deliveryDate DATE;

alter table sales_order_usa
modify column unit_price decimal(10,2),
modify column unit_cost decimal(10,2),
modify column discount_applied decimal(5,4);

alter table sales_order_usa
rename column `unit price` to unit_price;


alter table sales_order_usa
rename column `Discount applied` to Discount_applied;

ALTER TABLE store_sales_usa
  MODIFY COLUMN StateCode CHAR(2),
  MODIFY COLUMN State VARCHAR(50),
  MODIFY COLUMN Type VARCHAR(100),
  MODIFY COLUMN Latitude DECIMAL(9, 6),
  MODIFY COLUMN Longitude DECIMAL(9, 6),
  MODIFY COLUMN AreaCode INT,
  MODIFY COLUMN Population INT,
  MODIFY COLUMN Household_income INT,
  MODIFY COLUMN Median_Income INT,
  MODIFY COLUMN Land_Area int,
  MODIFY COLUMN Water_Area int,
  MODIFY COLUMN Time_Zone VARCHAR(50);
  
  alter table store_sales_usa
rename COLUMN `household income` to Household_income;

alter table store_sales_usa
rename column `median income` to median_income;

alter table store_sales_usa
rename column `land area` to land_area;

alter table store_sales_usa
rename column `water area` to water_area;

alter table store_sales_usa
rename column `time zone` to time_zone;

-- Convert text (DD/MM/YYYY) to DATE
SELECT STR_TO_DATE('31/05/2018', '%d/%m/%Y');

-- Format a DATE column to string display (e.g., '2018-05-31' or 'May 31, 2018')
SELECT DATE_FORMAT(OrderDate, '%Y-%m-%d') AS FormattedDate FROM sales_order_usa;

alter table sales_order_usa
rename column `_storeID` to storeID;

alter table sales_order_usa
rename column `_customerid` to customerID;

alter table sales_order_usa
rename column `_SALESTEAMid` to SALES_TEAMID;


-- revenue & average order value by(AOV) by sales channel 1

SELECT 
    `Sales Channel`,
    ROUND(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Total_Revenue,
    ROUND(AVG(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Average_Order_Value
FROM sales_order_usa
GROUP BY `Sales Channel`
ORDER BY Total_Revenue DESC;

-- month-over-month trend 2019 2

SELECT 
    DATE_FORMAT(orderDate, '%Y-%m') AS YearMonth,
    ROUND(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Monthly_Revenue
FROM sales_order_usa
GROUP BY YearMonth
ORDER BY YearMonth ASC;

-- revenue profit by region 3

SELECT 
    region.Region,
    ROUND(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Total_Revenue,
    ROUND(SUM((`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)) - (`Unit_Cost` * `Order Quantity`)), 2) AS Total_Profit
FROM sales_order_usa 
JOIN store_sales_usa store ON  `StoreID` = `StoreID`
JOIN region_usa region ON store.StateCode = region.StateCode
GROUP BY region.Region
ORDER BY Total_Revenue DESC;

-- Top 10 Customers by Revenue & Share of Total Revenue 4

SELECT 
    `Customer Names`,
    ROUND(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Customer_Revenue,
    ROUND(SUM((`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)) / 
          (SELECT SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)) FROM sales_order_usa)) * 100, 2) AS Pct_Of_Total_Revenue
FROM sales_order_usa 
JOIN customer_usa  ON `_CustomerID` = `_CustomerID`
GROUP BY `Customer Names`
ORDER BY Customer_Revenue DESC
LIMIT 10;               

-- Top and Bottom Performing Sales Reps  5

      WITH RepPerformance AS (
    SELECT 
        `Sales Team` AS Rep_Name,
        Region,
        ROUND(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Total_Revenue,
        DENSE_RANK() OVER (ORDER BY SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)) DESC) AS Top_Rank,
        DENSE_RANK() OVER (ORDER BY SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)) ASC) AS Bottom_Rank
    FROM sales_order_usa 
    JOIN sales_team_usa t ON `Sales_TeamID` = `Sales_TeamID`
    GROUP BY t.`Sales Team`, Region
)
SELECT Rep_Name, Region, Total_Revenue, Top_Rank
FROM RepPerformance
WHERE Top_Rank <= 5 OR Bottom_Rank <= 5
ORDER BY Total_Revenue DESC;

-- Average Discount & Impact on Order Value per Channel   6

 SELECT 
    `Sales Channel`,
    ROUND(AVG(`Discount_Applied`) * 100, 2) AS Avg_Discount_Percent,
    ROUND(AVG(`Order Quantity`), 2) AS Avg_Units_Per_Order,
    ROUND(AVG(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Avg_Order_Value
FROM sales_order_usa
GROUP BY `Sales Channel`
ORDER BY Avg_Discount_Percent DESC;  

-- Average Delivery Lead Time by Warehouse 7

SELECT 
    WarehouseCode,
    COUNT(OrderNumber) AS Total_Orders,
    ROUND(AVG(DATEDIFF(DeliveryDate, orderdate)), 2) AS Avg_Delivery_Days
FROM sales_order_usa
GROUP BY WarehouseCode
ORDER BY Avg_Delivery_Days ASC;

-- Cumulative Running Total Revenue by Region 8

SELECT 
    r.Region,
    ROUND(SUM(`Unit_Price` * s.`Order Quantity` * (1 - `Discount_Applied`)), 2) AS Region_Revenue,
    ROUND(
        SUM(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`))) 
        OVER (ORDER BY r.Region), 
        2
    ) AS Cumulative_Running_Total
FROM sales_order_usa s
JOIN store_sales_usa st ON StoreID = StoreID
JOIN region_usa r ON st.StateCode = r.StateCode
GROUP BY r.Region
ORDER BY r.Region;



-- Top 3 Stores Per Region 9

WITH MonthlyRegionSales AS (
    SELECT 
        Region,
        DATE_FORMAT(OrderDate, '%Y-%m') AS SalesMonth,
        ROUND(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Monthly_Revenue
    FROM sales_order_usa s
    JOIN store_sales_usa st  ON StoreID = StoreID
    JOIN region_usa r ON st.StateCode = r.StateCode
    GROUP BY Region, SalesMonth
)
SELECT 
    Region,
    SalesMonth,
    Monthly_Revenue,
    SUM(Monthly_Revenue) OVER (PARTITION BY Region ORDER BY SalesMonth) AS Cumulative_Revenue
FROM MonthlyRegionSales
ORDER BY Region, SalesMonth;
  

set session net_read_timeout = 600;
set session net_write_timeout = 600;
set session max_execution_time = 600;




-- Profit Margin % by Product (Comparing Profit vs. Revenue) 10

SELECT 
    CONCAT('Product ', `_ProductID`) AS Product_ID,
    ROUND(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Total_Revenue,
    ROUND(SUM((`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)) - (`Unit_Cost` * `Order Quantity`)), 2) AS Total_Profit,
    ROUND((SUM((`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)) - (`Unit_Cost` * `Order Quantity`)) / 
           SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`))) * 100, 2) AS Profit_Margin_Pct
FROM sales_order_usa
GROUP BY `_ProductID`
ORDER BY Profit_Margin_Pct DESC;





