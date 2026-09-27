**US Retail Sales Project**
**-- US Retail Sales Project - SQL
-- name: Akaje Rukayat Ajibola
-- Description: Queries for Data Cleaning and Analytics Insights**

### 1.Revenue and Average Order Value (AOV) by Sales Channel
**Purpose:** This calculation groups your data by sales channel to figure out how much total revenue each channel brings in, as well as the average value of an order placed through that channel.


```sql
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
