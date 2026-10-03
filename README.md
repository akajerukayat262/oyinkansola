**US Retail Sales Project**
**-- US Retail Sales Project - SQL
-- name: Akaje Rukayat Ajibola
-- Description: Queries for Data Cleaning and Analytics Insights**

### Executive Summary
This project delivers a comprehensive end-to-end data analysis of a US retail sales dataset, transforming raw operational files into structured business intelligence. By leveraging **MySQL** for data cleaning, staging, and complex exploratory data analysis (EDA), alongside **Power BI** for interactive visual storytelling, this repository evaluates key performance metrics across sales channels, regional profitability, product demand, and supply chain fulfillment. 
The primary purpose of this analysis is to bridge raw database records with strategic decision-making—uncovering revenue drivers, identifying top-performing product lines and sales representatives, examining customer spending behavior, and highlighting operational bottlenecks to help management optimize overall retail strategy.

### Project Objectives & Business Goals
The primary objective of this project is to leverage modern data analytics tools to answer critical business questions and evaluate overall retail performance. Specific goals include:
**Evaluating Financial Health:** Calculating total revenue, production costs, and net profits to determine overall profit margins.
**Channel & Regional Analysis:** Assessing which sales channels and geographical regions drive the highest volume and financial return.
**Customer Segmentation:** Identifying high-value customers, spending tiers, and purchasing patterns.
**Operational Optimization:** Analyzing delivery lead times across various warehouses and monitoring sales representative effectiveness.

### SQL ANALYSIS

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


### 1.Revenue and Average Order Value (AOV) by Sales Channel
**Purpose:** This calculation groups your data by sales channel to figure out how much total revenue each channel brings in, as well as the average value of an order placed through that channel.

SELECT
    `Sales Channel`,
    ROUND(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Total_Revenue,
    ROUND(AVG(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Average_Order_Value
FROM sales_order_usa
GROUP BY `Sales Channel`
ORDER BY Total_Revenue DESC;

### 2.Month-over-Month Trend
**Purpose:** This tracks how your sales performance changes over time on a monthly basis.

SELECT 
    DATE_FORMAT(orderDate, '%Y-%m') AS YearMonth,
    ROUND(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Monthly_Revenue
FROM sales_order_usa
GROUP BY YearMonth
ORDER BY YearMonth ASC;

### 3.Revenue and Profit by Region
**Purpose:** This breaks down total financial performance geographically by region.

SELECT 
    region.Region,
    ROUND(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Total_Revenue,
    ROUND(SUM((`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)) - (`Unit_Cost` * `Order Quantity`)), 2) AS Total_Profit
FROM sales_order_usa 
JOIN store_sales_usa store ON  `StoreID` = `StoreID`
JOIN region_usa region ON store.StateCode = region.StateCode
GROUP BY region.Region
ORDER BY Total_Revenue DESC;


### 4.Top 10 Customers by Revenue & Share of Total Revenue
**Purpose:** This identifies your highest-value customers and shows what percentage of your overall business revenue each one accounts for.

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

### 5.Top and Bottom Performing Sales Reps
**Purpose:** This highlights your best-performing sales representatives as well as those needing improvement.

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

### 6.Average Discount & Impact on Order Value per Channel
**Purpose:** This evaluates how discounts affect order sizes and overall pricing strategy across different sales channels.

SELECT 
    `Sales Channel`,
    ROUND(AVG(`Discount_Applied`) * 100, 2) AS Avg_Discount_Percent,
    ROUND(AVG(`Order Quantity`), 2) AS Avg_Units_Per_Order,
    ROUND(AVG(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Avg_Order_Value
FROM sales_order_usa
GROUP BY `Sales Channel`
ORDER BY Avg_Discount_Percent DESC;

### 7.Average Delivery Lead Time by Warehouse
**Purpose:** This measures supply chain and shipping efficiency by calculating how long it takes warehouses to ship orders.

SELECT 
    WarehouseCode,
    COUNT(OrderNumber) AS Total_Orders,
    ROUND(AVG(DATEDIFF(DeliveryDate, orderdate)), 2) AS Avg_Delivery_Days
FROM sales_order_usa
GROUP BY WarehouseCode
ORDER BY Avg_Delivery_Days ASC;

### 8.Cumulative Running Total Revenue by Region
**Purpose:** This shows how revenue accumulates over time or across regions sequentially.

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

### 9.Top 3 Stores Per Region
**Purpose:** This highlights the top-performing physical or digital stores within each geographic region based on monthly sales figures.

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

### 10.Profit Margin % by Product (Comparing Profit vs. Revenue)
**Purpose:** This evaluates the profitability of individual products relative to how much total revenue they generate.

SELECT 
    CONCAT('Product ', `_ProductID`) AS Product_ID,
    ROUND(SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)), 2) AS Total_Revenue,
    ROUND(SUM((`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)) - (`Unit_Cost` * `Order Quantity`)), 2) AS Total_Profit,
    ROUND((SUM((`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`)) - (`Unit_Cost` * `Order Quantity`)) / 
           SUM(`Unit_Price` * `Order Quantity` * (1 - `Discount_Applied`))) * 100, 2) AS Profit_Margin_Pct
FROM sales_order_usa
GROUP BY `_ProductID`
ORDER BY Profit_Margin_Pct DESC;

### Key Analytical Insights

Revenue & Profitability: Total revenue generation reached strong double-digit millions, supported by a healthy overall profit margin across core product categories.   
Brand & Product Performance: Flagship product lines (such as Cedarline) led total revenue contributions, significantly outperforming secondary product tiers. 
Order Volumes & AOV: High order frequencies combined with robust average order values indicate healthy customer purchasing power and basket sizes. 
Regional Disparities: Performance varied noticeably across regions and sales channels, pointing out specific geographic target areas for future business expansion. 

   Conclusion
   The combination of advanced SQL data engineering and Power BI storytelling successfully converted chaotic raw records into an intuitive, polished portfolio asset. The findings offer clear visibility into revenue drivers, pricing constraints, and operational bottlenecks, giving stakeholders the insights needed for future retail strategy.   

###   Power BI Dashboard Preview

<img width="854" height="481" alt="Screenshot 2026-10-03 at 11 54 20" src="https://github.com/user-attachments/assets/139f553d-a0e4-4549-9671-258d108c6009" />

<img width="847" height="491" alt="Screenshot 2026-10-03 at 11 55 22" src="https://github.com/user-attachments/assets/2f8c0ede-33ae-4e89-b197-4d4e1726c2ba" />

<img width="852" height="489" alt="Screenshot 2026-10-03 at 11 56 30" src="https://github.com/user-attachments/assets/222eca4f-b95f-49f3-9bf7-1fab8450bf8b" />

<img width="844" height="477" alt="Screenshot 2026-10-03 at 11 57 24" src="https://github.com/user-attachments/assets/8b721f7f-c849-4804-9bbe-26cb9468b3cf" />

<img width="848" height="482" alt="Screenshot 2026-10-03 at 11 58 22" src="https://github.com/user-attachments/assets/08681fbf-7e2b-432d-ab43-91e615d83761" />
