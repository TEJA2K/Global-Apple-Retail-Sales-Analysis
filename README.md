# Global-Apple-Retail-Sales-Analysis
Analyzed over 1 million rows of Apple retail sales data globally. This project covers product categories, individual products, sales transactions, store information, and warranty claims. The goal is to extract valuable insights and answer key business questions using advanced SQL queries.
## Project Overview
This project showcases advanced SQL querying techniques through the analysis of over 1 million rows of Apple retail sales data. The dataset includes information about products, stores, sales transactions, and warranty claims across various Apple retail locations globally.
## Dataset
The dataset consists of the following tables:
- `category`
- `products`
- `sales`
- `stores`
- `warranty`

## SQL Queries
### 1. Find the number of stores in each country
```sql
SELECT country, COUNT(DISTINCT(store_id)) AS [Total_Stores]
FROM stores
GROUP BY country
ORDER BY COUNT(DISTINCT(store_id)) DESC, country;
```
### 2.Calculate the total number of units sold by each store
```sql
SELECT st.store_id, st.store_name, SUM(sa.quantity) AS total_units
FROM sales sa
JOIN stores st ON st.store_id = sa.store_id
GROUP BY st.store_name, st.store_id
ORDER BY SUM(sa.quantity) DESC;
```
### 3.Identify how many sales occurred in December 2023
```sql
SELECT COUNT(sale_id) AS sales_dec
FROM sales
WHERE sale_date >= '2023-12-01'
  AND sale_date < '2024-01-01';
```
### 4.Determine how many stores have never had a warranty claim filed
```sql
SELECT *
FROM stores
WHERE store_id NOT IN(
    SELECT DISTINCT(s.store_id)
    FROM warranty w
    LEFT JOIN sales s ON w.sale_id = s.sale_id
    WHERE s.store_id IS NOT NULL
);
```
### 5.Calculate the percentage of warranty claims marked as "Warranty Void"
```sql
SELECT CAST(ROUND(
    (COUNT(claim_id) * 1.0 / (SELECT COUNT(claim_date) FROM warranty)) * 100, 2
) AS decimal(10,2)) AS warranty_void
FROM warranty
WHERE repair_status = 'Warranty Void';
```
### 6.Identify which store had the highest total units sold in the last year
```sql
SELECT TOP 1
    s.store_id,
    st.store_name,
    SUM(s.quantity) AS sold
FROM sales s
JOIN stores st ON s.store_id = st.store_id
WHERE YEAR(s.sale_date) = YEAR(GETDATE()) - 1
GROUP BY s.store_id, st.store_name
ORDER BY sold DESC;
```
### 7.Count the number of unique products sold in the last year
```sql
SELECT COUNT(DISTINCT(s.product_id)) AS num_of_prod, p.product_name
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE YEAR(s.sale_date) = YEAR(GETDATE()) - 1
GROUP BY p.product_name;
```
### 8.Find the average price of products in each category
```sql
SELECT p.category_id, c.category_name, ROUND(AVG(p.price), 2) AS avg_price
FROM products p
JOIN category c ON p.category_id = c.category_id
GROUP BY p.category_id, c.category_name
ORDER BY avg_price DESC;
```
### 9.How many warranty claims were filed in 2020
```sql
SELECT COUNT(*) AS claimed
FROM warranty
WHERE YEAR(claim_date) = 2020;
```
### 10.For each store, identify the best-selling day based on highest quantity sold
```sql
SELECT * FROM (
    SELECT 
        SUM(quantity) AS sold_quantity, DATENAME(WEEKDAY, sale_date) AS day_sale, store_id,
        DENSE_RANK() OVER (PARTITION BY store_id ORDER BY SUM(quantity) DESC) AS hig
    FROM sales
    GROUP BY DATENAME(WEEKDAY, sale_date), store_id
) t
WHERE hig = 1
ORDER BY sold_quantity DESC;
```
### 11.Identify the least selling product in each country for each year based on total units sold


