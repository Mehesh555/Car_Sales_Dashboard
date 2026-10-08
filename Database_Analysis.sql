-- Create the database
CREATE DATABASE car_sales_db;

USE car_sales_db;

-- Enable local file loading
SET GLOBAL local_infile = 1;

SHOW VARIABLES LIKE 'local_infile';

-- Create the table
CREATE TABLE Car_Sales (
    Sale_ID VARCHAR(100),
    Sales_Date DATE,
    Brand VARCHAR(100),
    Model VARCHAR(100),
    Year INT,
    Body_Style VARCHAR(50),
    Engine VARCHAR(50),
	Transmission VARCHAR(50),
	Fuel_Type VARCHAR(50),
    Color VARCHAR(50),
    Mileage DECIMAL(5,2),
    Price_Lakh DECIMAL(5,2),
    Units_Sold INT,
    Discount_Percent DECIMAL(5,2),
    Revenue_INR DECIMAL(18,2),
    Dealer_Region VARCHAR(100),
    Dealer_Type VARCHAR(100),
    Customer_Rating DECIMAL(5,2),
    Inventory_Days INT,
    Service_Cost_INR DECIMAL(15,2),
    Insurance_INR DECIMAL(15,2)
);

-- Import the CSV using cmd
-- run this
-- find /c /v "" "D:\power_BI\Car_Sales_Dashboard\Car_Sales.csv"
-- powershell -command "Get-Content 'D:\power_BI\Car_Sales_Dashboard\Car_Sales.csv' -TotalCount 5"
-- "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe" --local-infile=1 -u root -p
-- USE car_sales_db;

LOAD DATA LOCAL INFILE 'D:/power_BI/Car_Sales_Dashboard/Car_Sales.csv'
INTO TABLE Car_Sales
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    Sale_ID,
    @Sales_Date,
    Brand,
    Model,
    Year,
    Body_Style,
    Engine,
    Transmission,
    Fuel_Type,
    Color,
    Mileage,
    Price_Lakh,
    Units_Sold,
    Discount_Percent,
    Revenue_INR,
    Dealer_Region,
    Dealer_Type,
    Customer_Rating,
    Inventory_Days,
    Service_Cost_INR,
    Insurance_INR
)
SET Sales_Date = STR_TO_DATE(@Sales_Date, '%d-%m-%Y');

-- Data Validation

-- Total records
SELECT COUNT(*) AS Total_Rows
FROM Car_Sales;
-- Check missing values
SELECT
    COUNT(*) AS Total_Rows,
    COUNT(Brand) AS Brand_Count,
    COUNT(Model) AS Model_Count,
    COUNT(Price_Lakh) AS Price_Count,
    COUNT(Revenue_INR) AS Revenue_Count,
    COUNT(Sales_Date) AS Date_Count,
    COUNT(Customer_Rating) AS Rating_Count
FROM Car_Sales;
-- Check duplicate rows
SELECT
    Brand,
    Model,
    Sales_Date,
    Price_Lakh,
    COUNT(*) AS Duplicate_Count
FROM Car_Sales
GROUP BY
    Brand,
    Model,
    Sales_Date,
    Price_Lakh
HAVING COUNT(*) > 1
ORDER BY Duplicate_Count DESC;

-- Overall Business KPIs
-- Total cars sold
SELECT
    COUNT(*) AS Total_Cars_Sold
FROM Car_Sales;
-- Total revenue
SELECT
    SUM(Revenue_INR) AS Total_Revenue
FROM Car_Sales;
-- Average price
SELECT
    (AVG(Price_Lakh), 2) AS Average_Price
FROM Car_Sales;
-- Average customer rating
SELECT
    ROUND(AVG(Customer_Rating), 2) AS Average_Rating
FROM Car_Sales;
-- Complete KPI summary
SELECT
    COUNT(*) AS Total_Cars_Sold,
    ROUND(SUM(Revenue_INR), 2) AS Total_Revenue,
    CONCAT(ROUND(AVG(Price_Lakh), 2)," L") AS Average_Price,
    ROUND(AVG(Customer_Rating), 2) AS Average_Rating,
    ROUND(AVG(Discount_Percent), 2) AS Average_Discount
FROM Car_Sales;

-- Brand Analysis
-- Sales by brand
SELECT
    Brand,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY Brand
ORDER BY Cars_Sold DESC;
-- Revenue by brand
SELECT
    Brand,
    ROUND(SUM(Revenue_INR), 2) AS Total_Revenue
FROM Car_Sales
GROUP BY Brand
ORDER BY Total_Revenue DESC;
-- Average price by brand
SELECT
    Brand,
    CONCAT(ROUND(AVG(Price_Lakh), 2),"  L") AS Average_Price
FROM Car_Sales
GROUP BY Brand
ORDER BY Average_Price DESC;
-- Average rating by brand
SELECT
    Brand,
    ROUND(AVG(Customer_Rating), 2) AS Average_Rating
FROM Car_Sales
GROUP BY Brand
ORDER BY Average_Rating DESC;

-- Best Performing Brands
-- Top 5 brands by sales
SELECT
    Brand,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY Brand
ORDER BY Cars_Sold DESC
LIMIT 5;
-- Top 5 brands by revenue
SELECT
    Brand,
    ROUND(SUM(Revenue_INR), 2) AS Revenue
FROM Car_Sales
GROUP BY Brand
ORDER BY Revenue DESC
LIMIT 5;

-- Brand Revenue Ranking
SELECT
    Brand,
    ROUND(SUM(Revenue_INR), 2) AS Revenue,
    RANK() OVER (
        ORDER BY SUM(Revenue_INR) DESC
    ) AS Revenue_Rank
FROM Car_Sales
GROUP BY Brand
ORDER BY Revenue_Rank;

-- Brand Sales Percentage
SELECT
    Brand,
    COUNT(*) AS Cars_Sold,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS Sales_Percentage
FROM Car_Sales
GROUP BY Brand
ORDER BY Sales_Percentage DESC;

-- Body Style Analysis
-- Sales by body style
SELECT
    Body_Style,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY Body_Style
ORDER BY Cars_Sold DESC;
-- Revenue by body style
SELECT
    Body_Style,
    ROUND(SUM(Revenue_INR), 2) AS Revenue
FROM Car_Sales
GROUP BY Body_Style
ORDER BY Revenue DESC;
-- Body style percentage
SELECT
    Body_Style,
    COUNT(*) AS Cars_Sold,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS Sales_Percentage
FROM Car_Sales
GROUP BY Body_Style
ORDER BY Sales_Percentage DESC;

-- Engine Analysis
SELECT
    Engine,
    COUNT(*) AS Cars_Sold,
    CONCAT(ROUND(AVG(Price_Lakh), 2),"  L") AS Average_Price,
    ROUND(SUM(Revenue_INR), 2) AS Revenue
FROM Car_Sales
GROUP BY Engine
ORDER BY Cars_Sold DESC;
-- Most popular engine
SELECT
    Engine,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY Engine
ORDER BY Cars_Sold DESC
LIMIT 1;

-- Transmission Analysis
SELECT
    Transmission,
    COUNT(*) AS Cars_Sold,
    CONCAT(ROUND(AVG(Price_Lakh), 2),"  L") AS Average_Price
FROM Car_Sales
GROUP BY Transmission
ORDER BY Cars_Sold DESC;
-- Most popular transmission
SELECT
    Transmission,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY Transmission
ORDER BY Cars_Sold DESC
LIMIT 1;

-- Fuel Type Analysis
SELECT
    Fuel_Type,
    COUNT(*) AS Cars_Sold,
    ROUND(SUM(Revenue_INR), 2) AS Revenue,
    CONCAT(ROUND(AVG(Price_Lakh), 2),"  L") AS Average_Price
FROM Car_Sales
GROUP BY Fuel_Type
ORDER BY Cars_Sold DESC;

-- Model Analysis
-- Top 10 models by sales
SELECT
    Model,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY Model
ORDER BY Cars_Sold DESC
LIMIT 10;
-- Top 10 models by revenue
SELECT
    Model,
    ROUND(SUM(Revenue_INR), 2) AS Revenue
FROM Car_Sales
GROUP BY Model
ORDER BY Revenue DESC
LIMIT 10;

-- Region Analysis
SELECT
    Dealer_Region,
    COUNT(*) AS Cars_Sold,
    ROUND(SUM(Revenue_INR), 2) AS Revenue,
    CONCAT(ROUND(AVG(Price_Lakh), 2),"  L") AS Average_Price
FROM Car_Sales
GROUP BY Dealer_Region
ORDER BY Revenue DESC;
-- Top region
SELECT
    Dealer_Region,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY Dealer_Region
ORDER BY Cars_Sold DESC
LIMIT 1;

-- Dealer Type Analysis
SELECT
    Dealer_Type,
    COUNT(*) AS Cars_Sold,
    ROUND(SUM(Revenue_INR), 2) AS Revenue,
    CONCAT(ROUND(AVG(Price_Lakh), 2),"  L") AS Average_Price
FROM Car_Sales
GROUP BY Dealer_Type
ORDER BY Revenue DESC;

-- Color Analysis
SELECT
    Color,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY Color
ORDER BY Cars_Sold DESC;

-- Price Analysis
-- Minimum, maximum and average price
SELECT
    CONCAT(MIN(Price_Lakh),"  L") AS Minimum_Price,
    CONCAT(MAX(Price_Lakh),"  L") AS Maximum_Price,
    CONCAT(ROUND(AVG(Price_Lakh), 2),"  L") AS Average_Price
FROM Car_Sales;
-- Price categories
SELECT
    CASE
        WHEN Price_Lakh < 10.00 THEN 'Budget'
        WHEN Price_Lakh < 30.00 THEN 'Mid Range'
        WHEN Price_Lakh < 50.00 THEN 'Premium'
        ELSE 'Luxury'
    END AS Price_Category,
    COUNT(*) AS Cars_Sold,
    ROUND(SUM(Revenue_INR), 2) AS Revenue
FROM Car_Sales
GROUP BY
    CASE
        WHEN Price_Lakh < 10.00 THEN 'Budget'
        WHEN Price_Lakh < 30.00 THEN 'Mid Range'
        WHEN Price_Lakh < 50.00 THEN 'Premium'
        ELSE 'Luxury'
    END
ORDER BY Revenue DESC;

-- Discount Analysis
-- Average discount by brand
SELECT
    Brand,
    ROUND(AVG(Discount_Percent), 2) AS Average_Discount
FROM Car_Sales
GROUP BY Brand
ORDER BY Average_Discount DESC;
-- Discount vs revenue
SELECT
    Brand,
    ROUND(AVG(Discount_Percent), 2) AS Average_Discount,
    ROUND(SUM(Revenue_INR), 2) AS Revenue,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY Brand
ORDER BY Revenue DESC;

-- Customer Rating Analysis
-- Rating by brand
SELECT
    Brand,
    ROUND(AVG(Customer_Rating), 2) AS Average_Rating,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY Brand
ORDER BY Average_Rating DESC;
-- Highly rated cars
SELECT
    Brand,
    Model,
    Customer_Rating,
    Price_Lakh
FROM Car_Sales
WHERE Customer_Rating >= 4.5
ORDER BY Customer_Rating DESC;

-- Date / Monthly Analysis
-- Monthly sales
SELECT
    YEAR(Sales_Date) AS Year,
    MONTH(Sales_Date) AS Month,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY
    YEAR(Sales_Date),
    MONTH(Sales_Date)
ORDER BY
    Year,
    Month;
    
-- Monthly revenue
SELECT
    YEAR(Sales_Date) AS Year,
    MONTH(Sales_Date) AS Month,
    ROUND(SUM(Revenue_INR), 2) AS Revenue
FROM Car_Sales
GROUP BY
    YEAR(Sales_Date),
    MONTH(Sales_Date)
ORDER BY
    Year,
    Month;
-- Yearly revenue
SELECT
    YEAR(Sales_Date) AS Year,
    ROUND(SUM(Revenue_INR), 2) AS Revenue
FROM Car_Sales
GROUP BY YEAR(Sales_Date)
ORDER BY Year;

-- Brand + Body Style Analysis
SELECT
    Brand,
    Body_Style,
    COUNT(*) AS Cars_Sold,
    ROUND(SUM(Revenue_INR), 2) AS Revenue
FROM Car_Sales
GROUP BY
    Brand,
    Body_Style
ORDER BY Cars_Sold DESC;
-- Top 10 combinations
SELECT
    Brand,
    Body_Style,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY
    Brand,
    Body_Style
ORDER BY Cars_Sold DESC
LIMIT 10;

-- Brand + Engine Analysis
SELECT
    Brand,
    Engine,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY
    Brand,
    Engine
ORDER BY Cars_Sold DESC;

-- Brand + Transmission Analysis
SELECT
    Brand,
    Transmission,
    COUNT(*) AS Cars_Sold
FROM Car_Sales
GROUP BY
    Brand,
    Transmission
ORDER BY Cars_Sold DESC;

-- CTE Analysis
-- Find brands with revenue above the average brand revenue:
WITH Brand_Revenue AS (
    SELECT
        Brand,
        SUM(Revenue_INR) AS Revenue
    FROM Car_Sales
    GROUP BY Brand
)
SELECT
    Brand,
    ROUND(Revenue, 2) AS Revenue
FROM Brand_Revenue
WHERE Revenue > (
    SELECT AVG(Revenue)
    FROM Brand_Revenue
)
ORDER BY Revenue DESC;

-- Top 3 Models Within Each Brand
-- This is an advanced SQL window-function query:
WITH Model_Sales AS (
    SELECT
        Brand,
        Model,
        COUNT(*) AS Cars_Sold
    FROM Car_Sales
    GROUP BY
        Brand,
        Model
),
Ranked_Models AS (
    SELECT
        Brand,
        Model,
        Cars_Sold,
        DENSE_RANK() OVER (
            PARTITION BY Brand
            ORDER BY Cars_Sold DESC
        ) AS Model_Rank
    FROM Model_Sales
)
SELECT
    Brand,
    Model,
    Cars_Sold,
    Model_Rank
FROM Ranked_Models
WHERE Model_Rank <= 3
ORDER BY Brand, Model_Rank;

-- Highest Revenue Car
SELECT
    Brand,
    Model,
    Price_Lakh,
    Revenue_INR
FROM Car_Sales
ORDER BY Revenue_INR DESC
LIMIT 1;

-- Highest Priced Car
SELECT
    Brand,
    Model,
    Price_Lakh,
    Customer_Rating
FROM Car_Sales
ORDER BY Price_Lakh DESC
LIMIT 1;

-- Final Business Summary Query
-- This gives you a compact brand performance table that is excellent for your project:
SELECT
    Brand,
    COUNT(*) AS Cars_Sold,
    ROUND(SUM(Revenue_INR), 2) AS Revenue,
    CONCAT(ROUND(AVG(Price_Lakh), 2),"  L") AS Average_Price,
    ROUND(AVG(Customer_Rating), 2) AS Average_Rating,
    ROUND(AVG(Discount_Percent), 2) AS Average_Discount
FROM Car_Sales
GROUP BY Brand
ORDER BY Revenue DESC;