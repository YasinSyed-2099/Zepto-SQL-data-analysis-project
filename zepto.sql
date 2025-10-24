CREATE DATABASE zepto;
USE zepto;
SELECT * FROM zepto;

ALTER TABLE zepto
RENAME COLUMN `ï»¿sku_id` TO sku_id;

-- DATA EXPLORATION 
-- Count of Rows 
SELECT COUNT(*) FROM Zepto;

-- Sample data 
SELECT * FROM zepto
LIMIT 10;

-- Checking for null values 
SELECT * FROM zepto 
WHERE Category IS NULL
OR 
`name` IS NULL
OR 
mrp IS NULL
OR 
discountPercent IS NULL
OR 
availableQuantity IS NULL
OR 
discountedSellingPrice IS NULL
OR 
weightInGms IS NULL
OR 
outOfStock IS NULL
OR 
quantity IS NULL
;

-- Differenct Product category
SELECT DISTINCT category 
FROM zepto;

-- Product instock vs outstock
SELECT outOfStock , COUNT(sku_id) As count
FROM zepto
GROUP BY outOfStock;

-- product names present multiple type 
SELECT `name`, COUNT(sku_id) AS no_of_count
FROM zepto 
GROUP BY `name`
HAVING 2
ORDER BY 2 DESC
;

-- DATA CLEANING 
-- Product prize with mrp = 0
SELECT * FROM zepto
WHERE mrp = 0 OR discountedSellingPrice = 0
;

DELETE FROM zepto 
WHERE mrp = 0
;

-- Convert Paise into Rupees
UPDATE zepto 
SET mrp = mrp/100,
discountedSellingPrice =discountedSellingPrice/100
;

-- querys
-- Q1.  Find the top 10 best-value products based on the discount percentage.
SELECT 
DISTINCT `name`,
mrp,
discountPercent
FROM zepto
ORDER BY discountPercent DESC 
LIMIT 10;

-- Q2.  What are the Products with High MRP but Out of Stock
SELECT
DISTINCT `name`,
mrp
FROM zepto
WHERE outOfStock = 'TRUE'
ORDER BY mrp DESC
;

-- Q3.  Calculate Estimated Revenue for each category.
 SELECT
 Category,
 SUM(discountedSellingPrice * availableQuantity) AS Total_revenue
 FROM zepto
 GROUP BY Category
 ORDER BY Total_revenue DESC
 ;
 
-- Q4.  Find all products where MRP is greater than ₹500 and discount is less than 10%.
SELECT `name`,
mrp,
discountPercent
FROM zepto
WHERE mrp > 500 
AND discountPercent < 10 
ORDER BY mrp DESC , discountPercent DESC
;

-- Q5.  Identify the top 5 categories offering the highest average discount percentage.
SELECT Category,
ROUND(AVG(discountPercent),2) AS avg_discount_percentage 
FROM zepto
GROUP BY Category
ORDER BY avg_discount_percentage DESC 
LIMIT 5;

-- Q6.  Find the price per gram for products above 100g and sort by best value.
SELECT DISTINCT name,
weightInGms, 
discountedSellingPrice,
(discountedSellingPrice/weightInGms) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;

-- Q7.  Group the products into categories like Low, Medium, Bulk.
SELECT DISTINCT name, 
weightInGms,
CASE WHEN weightInGms < 1000 THEN 'Low'
	WHEN weightInGms < 4000 THEN 'Medium'
	ELSE 'Bulk'
	END AS weight_category
FROM zepto;

-- Q8.  What is the **Total Inventory Weight Per Category**
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;


-- Q9. Calculate the cumulative inventory value for each category, ordered by highest selling price. 
SELECT 
category,
name,
(discountedSellingPrice * availableQuantity) AS product_value,
SUM(discountedSellingPrice * availableQuantity ) 
	OVER(PARTITION BY Category 
		ORDER BY (discountedSellingPrice * availableQuantity) DESC,
			sku_id ) AS total_inventory_value
FROM zepto;

-- Q10.  Top 3 Most Valuable Products Per Category.
   WITH Product_inventory_values AS(
   SELECT Category,
   name,
   (discountedSellingPrice * availableQuantity ) AS Total_inventory_value,
   ROW_NUMBER() OVER(PARTITION BY category 
		ORDER BY (discountedSellingPrice * availableQuantity) DESC ) AS categoryRank
   FROM zepto)
	SELECT category,
    name,
    total_inventory_value
    FROM product_inventory_values
    WHERE categoryRank <= 3
    ORDER BY category ASC,
				total_inventory_value DESC
	;

-- Q11. Identify products in the top 10% of stock quantity but below the overall average discount.
WITH stock_cte AS(
	SELECT
    sku_id,
	Category,
	name,
	mrp,
	discountPercent,
	availableQuantity,
	discountedSellingPrice,
	weightInGms,
	outOfStock,
	quantity,
	(availableQuantity*quantity) AS total_quantity
From zepto
),
percentile_cte AS(
	SELECT *,
    PERCENT_RANK() OVER(ORDER BY total_quantity DESC) AS stock_percentile,
    AVG(discountpercent) OVER() AS average_percentage
    FROM stock_cte
)
SELECT 
	sku_id,
	Category,
	name,
	mrp
	discountPercent,
	availableQuantity,
	discountedSellingPrice,
	weightInGms,
	outOfStock,
	quantity
FROM percentile_cte
WHERE stock_percentile <= 0.10 
	AND discountPercent < average_percentage 
ORDER BY total_quantity DESC ;

-- Q11. Identify products with above-average revenue per unit and rank them by category.
    
















