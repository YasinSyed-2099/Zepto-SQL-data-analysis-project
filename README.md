# Zepto-SQL-data-analysis-project

# Zepto E-Commerce Inventory Data Analysis

A comprehensive SQL-based analysis of [Zepto](https://www.zeptonow.com/) e-commerce product inventory. The project focuses on setting up a structured database, cleaning inconsistent data, exploring stock and pricing patterns, and extracting business insights related to discount trends, revenue estimation, and product availability.

---

## 1. Project Overview

This project simulates a real-world e-commerce inventory management analysis using SQL. It involves database setup, data cleaning, exploratory queries, and insight generation through analytical SQL functions.

**Objectives:**

* Build and structure the Zepto inventory database
* Clean null and invalid data entries
* Convert product prices from paise to rupees
* Perform detailed exploratory analysis
* Generate actionable insights on revenue, discount, and stock

---

## 2. Project Structure

### Database Setup

```sql
CREATE DATABASE zepto;
USE zepto;

ALTER TABLE zepto
RENAME COLUMN `ï»¿sku_id` TO sku_id;
```

- **Table Columns:**
`sku_id, name, category, mrp, discountPercent, discountedSellingPrice, availableQuantity, weightInGms, outOfStock, quantity`
- [View the Zepto Inventory Dataset CSV](https://github.com/YasinSyed-2099/Zepto-SQL-data-analysis-project/edit/main/zepto.csv)


---

## 3. Dataset & Data Exploration

- **Dataset Source:**
Kaggle dataset scraped from Zepto’s official product listings, representing real-world SKU-level data across multiple categories and packaging variations.
- [View the complete Zepto SQL Query File used for analysis](https://github.com/YasinSyed-2099/Zepto-SQL-data-analysis-project/edit/main/zepto.sql)

### Exploration Queries

```sql
-- Total records
SELECT COUNT(*) FROM zepto;

-- Sample view
SELECT * FROM zepto LIMIT 10;

-- Check for null values
SELECT * FROM zepto 
WHERE Category IS NULL OR name IS NULL OR mrp IS NULL 
OR discountPercent IS NULL OR discountedSellingPrice IS NULL
OR availableQuantity IS NULL OR weightInGms IS NULL 
OR outOfStock IS NULL OR quantity IS NULL;

-- Distinct categories
SELECT DISTINCT category FROM zepto;

-- In-stock vs out-of-stock
SELECT outOfStock, COUNT(sku_id) AS count
FROM zepto
GROUP BY outOfStock;

-- Duplicate product names
SELECT name, COUNT(sku_id) AS no_of_count
FROM zepto
GROUP BY name
HAVING COUNT(sku_id) > 1
ORDER BY no_of_count DESC;
```

---

## 4. Data Cleaning

```sql
-- Identify invalid prices
SELECT * FROM zepto WHERE mrp = 0 OR discountedSellingPrice = 0;

-- Remove invalid price records
DELETE FROM zepto WHERE mrp = 0;

-- Convert prices from paise to rupees
UPDATE zepto 
SET mrp = mrp / 100,
discountedSellingPrice = discountedSellingPrice / 100;
```

---

## 5. Data Analysis & Insights

### Q1. Top 10 Best-Value Products (Highest Discount %)

```sql
SELECT DISTINCT name, mrp, discountPercent
FROM zepto
ORDER BY discountPercent DESC
LIMIT 10;
```

### Q2. High-MRP Products Out of Stock

```sql
SELECT DISTINCT name, mrp
FROM zepto
WHERE outOfStock = 'TRUE'
ORDER BY mrp DESC;
```

### Q3. Estimated Revenue per Category

```sql
SELECT category,
SUM(discountedSellingPrice * availableQuantity) AS Total_revenue
FROM zepto
GROUP BY category
ORDER BY Total_revenue DESC;
```

### Q4. Expensive Products (MRP > ₹500) with Low Discounts (<10%)

```sql
SELECT name, mrp, discountPercent
FROM zepto
WHERE mrp > 500 AND discountPercent < 10
ORDER BY mrp DESC, discountPercent DESC;
```

### Q5. Top 5 Categories with Highest Average Discount

```sql
SELECT category,
ROUND(AVG(discountPercent),2) AS avg_discount_percentage
FROM zepto
GROUP BY category
ORDER BY avg_discount_percentage DESC
LIMIT 5;
```

### Q6. Price Per Gram (Value for Money Products)

```sql
SELECT DISTINCT name, weightInGms, discountedSellingPrice,
(discountedSellingPrice / weightInGms) AS price_per_gram
FROM zepto
WHERE weightInGms >= 100
ORDER BY price_per_gram;
```

### Q7. Product Grouping by Weight

```sql
SELECT DISTINCT name, weightInGms,
CASE
    WHEN weightInGms < 1000 THEN 'Low'
    WHEN weightInGms < 4000 THEN 'Medium'
    ELSE 'Bulk'
END AS weight_category
FROM zepto;
```

### Q8. Total Inventory Weight per Category

```sql
SELECT category,
SUM(weightInGms * availableQuantity) AS total_weight
FROM zepto
GROUP BY category
ORDER BY total_weight;
```

### Q9. Cumulative Inventory Value per Category

```sql
SELECT 
    category, 
    name,
    (discountedSellingPrice * availableQuantity) AS product_value,
    SUM(discountedSellingPrice * availableQuantity) 
        OVER (
            PARTITION BY category 
            ORDER BY (discountedSellingPrice * availableQuantity) DESC, sku_id
        ) AS total_inventory_value
FROM zepto;
```

### Q10. Top 3 Most Valuable Products per Category

```sql
WITH product_inventory_values AS (
    SELECT 
        category, 
        name,
        (discountedSellingPrice * availableQuantity) AS total_inventory_value,
        ROW_NUMBER() OVER (
            PARTITION BY category 
            ORDER BY (discountedSellingPrice * availableQuantity) DESC
        ) AS categoryRank
    FROM zepto
)
SELECT 
    category, 
    name, 
    total_inventory_value
FROM product_inventory_values
WHERE categoryRank <= 3
ORDER BY category, total_inventory_value DESC;

```

### Q11. Products in Top 10% of Stock but Below Average Discount

```sql
WITH stock_cte AS (
    SELECT 
        sku_id, 
        category, 
        name, 
        mrp, 
        discountPercent,
        availableQuantity, 
        discountedSellingPrice, 
        weightInGms,
        outOfStock, 
        quantity, 
        (availableQuantity * quantity) AS total_quantity
    FROM zepto
),
percentile_cte AS (
    SELECT 
        *,
        PERCENT_RANK() OVER (ORDER BY total_quantity DESC) AS stock_percentile,
        AVG(discountPercent) OVER() AS average_percentage
    FROM stock_cte
)
SELECT 
    sku_id, 
    category, 
    name, 
    mrp, 
    discountPercent, 
    availableQuantity,
    discountedSellingPrice, 
    weightInGms, 
    outOfStock, 
    quantity
FROM percentile_cte
WHERE stock_percentile <= 0.10 
  AND discountPercent < average_percentage
ORDER BY total_quantity DESC;
```

---

## 6. Key Findings

* Top 10 products offer the highest discount percentages.
* Multiple high-priced products are out of stock.
* Snacks and Beverages categories generate the highest estimated revenue.
* Premium products maintain low discounts despite high MRP.
* Categories with the highest average discount percentages indicate promotional focus.
* Bulk-weight products dominate total inventory weight.
* Cumulative inventory value highlights categories with potential overstock.
* Products with high stock but low discounts present opportunities for marketing campaigns.

---

## 7. Conclusion

A complete SQL-based e-commerce inventory analysis project that focuses on structured querying, data cleaning, and business interpretation. It demonstrates practical use of SQL for analyzing pricing, discount, and stock metrics in a real-world retail scenario.
