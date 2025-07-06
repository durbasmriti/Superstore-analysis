create database if not exists superstore;
use superstore;

-- 1. View all orders-- 
SELECT * FROM orders;

-- Alter columns name--
ALTER TABLE orders RENAME COLUMN `Order ID` to `Order_ID`;
ALTER TABLE orders RENAME COLUMN `Row ID` to `Row_ID`;
ALTER TABLE orders RENAME COLUMN `Ship Date` to `Ship_date`;
ALTER TABLE orders RENAME COLUMN `Ship Mode` to `Ship_mode`;
ALTER TABLE orders RENAME COLUMN `Customer ID` to `customer_ID`;
ALTER TABLE orders RENAME COLUMN `Customer Name` to `Customer_name`;
ALTER TABLE orders RENAME COLUMN `Postal Code` to `Postal_code`;
ALTER TABLE orders RENAME COLUMN `Product Name` to `Product_name`;
ALTER TABLE orders RENAME COLUMN `Order Date` to `Order_date`;

-- 2. Select specific columns
SELECT Order_ID, Order_date, Customer_name, Sales FROM orders;

-- 3. Orders with profit > 500
SELECT * FROM orders WHERE Profit > 500;

-- 4. Orders shipped with "Same Day"
SELECT * FROM orders WHERE Ship_mode = 'Same Day';

-- 5. Orders from California
SELECT * FROM orders WHERE State = 'California';

-- 6. Unique customers
SELECT DISTINCT customer_ID, customer_name FROM orders;

-- 7. Orders placed in 2017
SELECT * FROM orders WHERE YEAR(Order_date) = 2017;

-- 8. Orders with discount applied
SELECT * FROM orders WHERE Discount > 0;

-- 9. Count of orders per region
SELECT Region, COUNT(*) FROM orders GROUP BY Region;

-- 10. Total sales value
SELECT SUM(Sales) AS total_sales FROM orders;

-- 11. Orders with sales > average sales
SELECT * FROM orders WHERE Sales > (SELECT AVG(Sales) FROM orders);

-- 12. Top 10 most profitable orders
SELECT * FROM orders ORDER BY Profit DESC LIMIT 10;

-- 13. Orders with negative profit
SELECT * FROM orders WHERE Profit < 0;

-- 14. States with highest sales
SELECT State, SUM(Sales) AS total_sales
FROM orders GROUP BY state ORDER BY total_sales DESC;

-- 15. Sub-categories sold in 'Texas'
SELECT DISTINCT `Sub-Category` FROM orders WHERE State = 'Texas';

-- 16. Monthly sales trend
SELECT MONTH(Order_date) AS month, SUM(Sales) AS total_sales
FROM orders GROUP BY month;

-- 17. Yearly profit
SELECT YEAR(Order_date) AS year, SUM(Profit) AS total_profit
FROM orders GROUP BY year;

-- 18. Total quantity per category
SELECT Category, SUM(Quantity) FROM orders GROUP BY Category;

-- 19. Customers with more than 10 orders
SELECT customer_ID, COUNT(*) AS order_count
FROM orders GROUP BY customer_ID HAVING order_count > 10;

-- 20. Orders with both high sales and high profit
SELECT * FROM orders WHERE Sales > 1000 AND Profit > 500;

-- 21. Number of orders by segment
SELECT Segment, COUNT(*) FROM orders GROUP BY Segment;

-- 22. Average discount per sub-category
SELECT `Sub-Category`, AVG(Discount) FROM orders GROUP BY `Sub-Category`;

-- 23. Orders where quantity is a multiple of 5
SELECT * FROM orders WHERE MOD(Quantity, 5) = 0;

-- 24. Most profitable product per category
SELECT Category, Product_name, Profit FROM orders a
WHERE Profit = (
  SELECT MAX(Profit) FROM orders b
  WHERE a.Category = b.Category
);

-- 25. Most sold product
SELECT Product_name, SUM(Quantity) AS total_qty
FROM orders GROUP BY Product_name ORDER BY total_qty DESC LIMIT 1;

-- 26. Find duplicate orders
SELECT Order_ID, COUNT(*) FROM orders GROUP BY Order_ID HAVING COUNT(*) > 1;

-- 27. Orders shipped more than 7 days after ordering
SELECT * FROM orders
WHERE DATEDIFF(Ship_date, Order_date) > 7;

-- 28. Total profit per ship_mode
SELECT Ship_mode, SUM(Profit) FROM orders GROUP BY Ship_mode;

-- 29. Customer with highest lifetime value
SELECT Customer_name, SUM(Profit) AS total_profit
FROM orders GROUP BY Customer_name ORDER BY total_profit DESC LIMIT 1;

-- 30. Orders sorted by highest discount
SELECT * FROM orders ORDER BY Discount DESC LIMIT 5;

-- 31. Most profitable state per region
SELECT Region, State, SUM(Profit) AS state_profit
FROM orders GROUP BY Region, State
ORDER BY Region, state_profit DESC;

-- 32. Top 5 customers per year
SELECT * FROM (
  SELECT Customer_name, YEAR(Order_date) AS yr, SUM(Sales) AS yearly_sales,
         RANK() OVER (PARTITION BY YEAR(Order_date) ORDER BY SUM(Sales) DESC) AS rnk
  FROM orders GROUP BY Customer_name, YEAR(Order_date)
) AS ranked WHERE rnk <= 5;

-- 33. Cities with more than $100k sales
SELECT City, SUM(Sales) AS total_sales
FROM orders GROUP BY City HAVING total_sales > 100000;

-- 34. % Discounted Orders
SELECT 
    ROUND(100.0 * SUM(CASE WHEN Discount > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS pct_discounted
FROM orders;

-- 35. First order per customer
SELECT * FROM (
  SELECT *, RANK() OVER (PARTITION BY customer_ID ORDER BY Order_date) AS rnk
  FROM orders
) ranked WHERE rnk = 1;

-- 36. Moving average of monthly sales (3-month window)
SELECT order_month, AVG(monthly_sales) OVER (
    ORDER BY order_month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
) AS moving_avg
FROM (
  SELECT DATE_FORMAT(Order_date, '%Y-%m') AS order_month,
         SUM(Sales) AS monthly_sales
  FROM orders GROUP BY order_month
) AS monthly;

-- 37. Total profit by category and sub-category
SELECT Category, `Sub-Category`, SUM(Profit) FROM orders
GROUP BY Category, `Sub-Category`;

-- 38. State with max order count per region
SELECT * FROM (
  SELECT Region, State, COUNT(*) AS order_count,
         RANK() OVER (PARTITION BY Region ORDER BY COUNT(*) DESC) AS rnk
  FROM orders GROUP BY Region, State
) ranked WHERE rnk = 1;

-- 39. Average order size per customer
SELECT Customer_name, AVG(Sales) AS avg_order_value
FROM orders GROUP BY Customer_name;

-- 40. Max discount given per region
SELECT Region, MAX(Discount) AS max_discount FROM orders GROUP BY Region;

-- 41. Most frequently sold product per sub-category
SELECT * FROM (
  SELECT `Sub-Category`, Product_name, COUNT(*) AS freq,
         RANK() OVER (PARTITION BY `Sub-Category` ORDER BY COUNT(*) DESC) AS rnk
  FROM orders GROUP BY `Sub-Category`, Product_name
) ranked WHERE rnk = 1;

-- 42. Profit margin (profit/sales)
SELECT Product_name, ROUND(100 * SUM(Profit)/SUM(Sales), 2) AS margin
FROM orders GROUP BY Product_name ORDER BY margin DESC;

-- 43. Order frequency per customer
SELECT Customer_name, COUNT(*) AS order_count
FROM orders GROUP BY Customer_name ORDER BY order_count DESC;

-- 44. Customers from more than one region
SELECT customer_ID FROM orders
GROUP BY customer_ID HAVING COUNT(DISTINCT Region) > 1;

-- 45. Top products by sales-to-quantity ratio
SELECT Product_name, SUM(Sales)/SUM(Quantity) AS unit_price
FROM orders GROUP BY Product_name ORDER BY unit_price DESC LIMIT 5;

-- 46. Monthly profit trend for a specific state
SELECT DATE_FORMAT(Order_date, '%Y-%m') AS month, SUM(Profit) AS profit
FROM orders WHERE State = 'California' GROUP BY month;

-- 47. Percentage of sales by each region
SELECT Region, ROUND(100 * SUM(Sales) / (SELECT SUM(Sales) FROM orders), 2) AS pct_sales
FROM orders GROUP BY Region;

-- 48. Discounted vs non-discounted revenue
SELECT
  SUM(CASE WHEN Discount > 0 THEN Sales ELSE 0 END) AS discounted_sales,
  SUM(CASE WHEN Discount = 0 THEN Sales ELSE 0 END) AS regular_sales
FROM orders;

-- 49. Product with highest average profit
SELECT Product_name, AVG(Profit) AS avg_profit
FROM orders GROUP BY Product_name ORDER BY avg_profit DESC LIMIT 1;

-- 50. Identify returns (assume returns = negative profit)
SELECT * FROM orders WHERE Profit < 0;

-- 51. Time to ship (avg by category)
SELECT Category, AVG(DATEDIFF(Ship_date, Order_date)) AS avg_ship_days
FROM orders GROUP BY Category;

-- 52. Orders with Sales > 2x average Sales in same Category
SELECT * FROM orders o
WHERE Sales > 2 * (
    SELECT AVG(Sales) FROM orders WHERE Category = o.Category
);

-- 53. Top Sub-Category per Region by revenue
SELECT * FROM (
  SELECT Region, `Sub-Category`, SUM(Sales) AS total_sales,
         RANK() OVER (PARTITION BY Region ORDER BY SUM(Sales) DESC) AS rnk
  FROM orders GROUP BY Region, `Sub-Category`
) ranked WHERE rnk = 1;

-- 54. Repeat customers (more than one order)
SELECT Customer_name, COUNT(*) FROM orders
GROUP BY Customer_name HAVING COUNT(*) > 1;

-- 55. Revenue lost due to discount
SELECT SUM(Sales * Discount) AS revenue_lost FROM orders;

-- 56. Average order value by Ship Mode
SELECT Ship_mode, AVG(Sales) FROM orders GROUP BY Ship_mode;

-- 57. Year-on-Year Profit growth
SELECT
  YEAR(Order_date) AS year,
  SUM(Profit) AS yearly_profit,
  SUM(Profit) - LAG(SUM(Profit)) OVER (ORDER BY YEAR(Order_date)) AS growth
FROM orders GROUP BY year;

-- 59. Product combinations bought together (frequent pairs)
SELECT a.Product_name AS product1, b.Product_name AS product2, COUNT(*) AS freq
FROM orders a JOIN orders b ON a.Order_ID = b.Order_ID AND a.`Product ID` < b.`Product ID`
GROUP BY product1, product2 ORDER BY freq DESC LIMIT 10;

-- 60. Product not sold in some regions
SELECT DISTINCT Product_name FROM orders
WHERE Product_name NOT IN (
    SELECT Product_name FROM orders WHERE Region = 'Central'
);

-- 61. Total Sales by quarter
SELECT QUARTER(Order_date) AS qtr, SUM(Sales) FROM orders GROUP BY qtr;

-- 62. Day of week with highest Sales
SELECT DAYNAME(Order_date) AS day, SUM(Sales)
FROM orders GROUP BY day ORDER BY SUM(Sales) DESC;

-- 63. Top performing product each year
SELECT * FROM (
  SELECT Product_name, YEAR(Order_date) AS yr, SUM(Profit) AS yearly_profit,
         RANK() OVER (PARTITION BY YEAR(Order_date) ORDER BY SUM(Profit) DESC) AS rnk
  FROM orders GROUP BY Product_name, YEAR(Order_date)
) ranked WHERE rnk = 1;

-- 64. Revenue per customer Segment
SELECT Segment, SUM(Sales) FROM orders GROUP BY Segment;

-- 65. State-wise profit margin
SELECT State, ROUND(100 * SUM(Profit)/SUM(Sales), 2) AS margin
FROM orders GROUP BY State ORDER BY margin DESC;

-- 66. Daily average orders
SELECT DATE(Order_date) AS date, COUNT(*) AS num_orders
FROM orders GROUP BY date ORDER BY date;

-- 67. Most profitable customer per State
SELECT * FROM (
  SELECT State, Customer_name, SUM(Profit) AS state_profit,
         RANK() OVER (PARTITION BY State ORDER BY SUM(Profit) DESC) AS rnk
  FROM orders GROUP BY State, Customer_name
) ranked WHERE rnk = 1;

-- 68. -- Median Sales Calculation using Row Numbers
WITH ordered_sales AS (
  SELECT Sales,
         ROW_NUMBER() OVER (ORDER BY Sales) AS rn,
         COUNT(*) OVER () AS total_rows
  FROM orders
)
SELECT
AVG(Sales) AS median_sales
FROM ordered_sales
WHERE rn IN (FLOOR((total_rows + 1) / 2), CEIL((total_rows + 1) / 2));

-- 69. Top 3 profitable Sub-Categories in 'Technology'
SELECT `Sub-Category`, SUM(Profit) AS total_profit
FROM orders WHERE Category = 'Technology'
GROUP BY `Sub-Category` ORDER BY total_profit DESC LIMIT 3;

-- 70. Longest time between order and shipping
SELECT * FROM orders ORDER BY DATEDIFF(Ship_date, Order_date) DESC LIMIT 1;
