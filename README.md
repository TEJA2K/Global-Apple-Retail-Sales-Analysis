# Global-Apple-Retail-Sales-Analysis
Analyzed over 1 million rows of Apple retail sales data globally. This project covers product categories, individual products, sales transactions, store information, and warranty claims. The goal is to extract valuable insights and answer key business questions using advanced SQL queries.
## Project Overview
This project is designed to showcase advanced SQL querying techniques through the analysis of over 1 million rows of Apple retail sales data. The dataset includes comprehensive information about products, stores, sales transactions, and warranty claims across various Apple retail locations globally.
## Dataset
The dataset consists of the following tables:

- `category`: Holds product category information.
  - `category_id`: Unique identifier for each product category.
  - `category_name`: Name of the category.

- `products`: Details about Apple products.
  - `product_id`: Unique identifier for each product.
  - `product_name`: Name of the product.
  - `category_id`: References the category table.
  - `launch_date`: Date when the product was launched.
  - `price`: Price of the product.

- `sales`: Stores sales transactions.
  - `sale_id`: Unique identifier for each sale.
  - `sale_date`: Date of the sale.
  - `store_id`: References the store table.
  - `product_id`: References the product table.
  - `quantity`: Number of units sold.

- `stores`: Contains information about Apple retail stores.
  - `store_id`: Unique identifier for each store.
  - `store_name`: Name of the store.
  - `city`: City where the store is located.
  - `country`: Country of the store.

- `warranty`: Contains information about warranty claims.
  - `claim_id`: Unique identifier for each warranty claim.
  - `claim_date`: Date the claim was made.
  - `sale_id`: References the sales table.
  - `repair_status`: Status of the warranty claim (e.g., Paid Repaired, Warranty Void).


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
```sql
SELECT *
FROM (
    SELECT 
        SUM(sa.quantity) AS total_quantity,
        st.country,
        DATEPART(YEAR, sa.sale_date) AS year_sold,
        p.product_name,
        DENSE_RANK() OVER (PARTITION BY st.country, DATEPART(YEAR, sa.sale_date) ORDER BY SUM(sa.quantity)) AS low_sale
    FROM sales sa
    JOIN stores st ON sa.store_id = st.store_id
    JOIN products p ON sa.product_id = p.product_id
    GROUP BY st.country, p.product_name, DATEPART(YEAR, sa.sale_date)
) t
WHERE low_sale = 1
ORDER BY year_sold, country, total_quantity;
```
### 12.Calculate how many warranty claims were filed within 180 days of a product sale
```sql
SELECT COUNT(*) AS claims_filed
FROM (
    SELECT 
        w.claim_id,
        w.claim_date,
        s.sale_date,
        DATEDIFF(DAY, s.sale_date, w.claim_date) AS days_claimed
    FROM warranty w
    JOIN sales s ON w.sale_id = s.sale_id
    WHERE DATEDIFF(DAY, s.sale_date, w.claim_date) <= 180
) t;
```
### 13.Determine how many warranty claims were filed for products launched in the last two years
```sql
SELECT COUNT(w.claim_id) AS claims, p.product_name
FROM warranty w
JOIN sales s ON w.sale_id = s.sale_id
JOIN products p ON s.product_id = p.product_id
WHERE launch_date >= DATEADD(YEAR, -2, GETDATE())
GROUP BY p.product_name;
```
### 14.List the months in the last three years where sales exceeded 5,000 units in the USA
```sql
SELECT *
FROM (
    SELECT 
        SUM(s.quantity) AS total_sales,
        FORMAT(s.sale_date, 'MM-yyyy') AS month_year
    FROM sales s
    JOIN stores st ON s.store_id = st.store_id
```
### 15.Identify the product category with the most warranty claims filed in the last two years
```sql
SELECT COUNT(*) AS claims, c.category_name
FROM warranty w
JOIN sales s ON w.sale_id = s.sale_id
JOIN products p ON s.product_id = p.product_id
JOIN category c ON p.category_id = c.category_id
WHERE w.claim_date >= DATEADD(YEAR, -2, GETDATE())
GROUP BY c.category_name;
```
### 16.Determine the percentage chance of receiving warranty claims after each purchase for each country
```sql
SELECT 
    SUM(quantity) AS total_sales,
    COUNT(claim_id) AS total_claims, 
    country,
    CAST(COALESCE((COUNT(claim_id) * 1.0) / SUM(quantity) * 100, 0) AS decimal(10,2)) AS per
FROM (
    SELECT w.claim_id, s.quantity, st.country
    FROM sales s
    JOIN stores st ON s.store_id = st.store_id
    JOIN warranty w ON s.sale_id = w.sale_id   
) T
GROUP BY country
ORDER BY per DESC;
```
### 17.Analyze the year-by-year growth ratio for each store
```sql
WITH cte AS (
    SELECT 
        DISTINCT s.store_id, st.store_name,
        YEAR(s.sale_date) AS sale_year,
        SUM(s.quantity * p.price) OVER (PARTITION BY YEAR(s.sale_date), s.store_id) AS total_sale
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    JOIN stores st ON s.store_id = st.store_id
),
cte2 AS (
    SELECT *,
    LAG(total_sale) OVER (PARTITION BY store_id ORDER BY sale_year) AS pre_sale_yr
    FROM cte
)
SELECT *,
ROUND(COALESCE((total_sale - pre_sale_yr) / pre_sale_yr, 0) * 100, 3) AS growth_ratio
FROM cte2;
```
### 18.Calculate the correlation between product price and warranty claims for products sold in the last five years, segmented by price range
```sql
SELECT CAST(COUNT(w.claim_id) AS BIGINT) AS claims,
CASE 
    WHEN p.price BETWEEN 1 AND 1000 THEN 'low-price'
    WHEN p.price BETWEEN 1001 AND 2000 THEN 'medium-price'
    WHEN p.price > 2001 THEN 'high-price'
END AS price_range
FROM warranty w
JOIN sales s ON w.sale_id = s.sale_id
JOIN products p ON s.product_id = p.product_id
WHERE s.sale_date >= DATEADD(YEAR, -5, GETDATE())
GROUP BY CASE 
    WHEN p.price BETWEEN 1 AND 1000 THEN 'low-price'
    WHEN p.price BETWEEN 1001 AND 2000 THEN 'medium-price'
    WHEN p.price > 2001 THEN 'high-price'
END;
```
### 19. Identify the store with the highest percentage of "Paid Repaired" claims relative to total claims filed
```sql
WITH cte AS (
    SELECT COUNT(st.store_id) AS total_claims, st.store_id
    FROM stores st
    JOIN sales s ON st.store_id = s.store_id
    JOIN warranty w ON s.sale_id = w.sale_id 
    GROUP BY st.store_id
),
cte2 AS (
    SELECT COUNT(st.store_id) AS claims_PR, st.store_id
    FROM stores st
    JOIN sales s ON st.store_id = s.store_id
    JOIN warranty w ON s.sale_id = w.sale_id
    WHERE w.repair_status = 'Paid Repaired'
    GROUP BY st.store_id
)
SELECT TOP 1 cte2.store_id, cte.total_claims, cte2.claims_PR,
CAST(cte2.claims_PR * 1.0 / cte.total_claims AS decimal(10,2)) AS per_claims 
FROM cte
JOIN cte2 ON cte.store_id = cte2.store_id
ORDER BY per_claims DESC;
```
### 20.Write a query to calculate the monthly running total of sales for each store over the past four years
```sql
WITH cte AS (
    SELECT 
        s.store_id,
        MONTH(s.sale_date) AS month_sale,
        YEAR(s.sale_date) AS year_sale,
        SUM(p.price * s.quantity) AS total_price
    FROM sales s
    JOIN products p ON s.product_id = p.product_id
    WHERE s.sale_date >= DATEADD(YEAR, -4, GETDATE())
    GROUP BY s.store_id, YEAR(s.sale_date), MONTH(s.sale_date)
),
Ru_to AS (
    SELECT 
        store_id,
        month_sale,
        year_sale,
        total_price,
        SUM(total_price) OVER (PARTITION BY store_id ORDER BY year_sale, month_sale) AS running_total
    FROM cte
)
SELECT *
FROM Ru_to
ORDER BY store_id, year_sale, month_sale;
```
### 21.Analyze product sales trends over time, segmented into key periods: from launch to 6 months, 6-12 months, 12-18 months, and beyond 18 months
```sql
SELECT 
    product_name,
    SUM(quantity) AS total_quantity,
    seg
FROM (
    SELECT 
        p.product_name,
        s.quantity,
        CASE 
            WHEN DATEDIFF(MONTH, p.launch_date, s.sale_date) BETWEEN 0 AND 6 THEN 'launch to 6 months'
            WHEN DATEDIFF(MONTH, p.launch_date, s.sale_date) BETWEEN 7 AND 12 THEN '7-12 months'
            WHEN DATEDIFF(MONTH, p.launch_date, s.sale_date) BETWEEN 13 AND 18 THEN '13-18 months'
            WHEN DATEDIFF(MONTH, p.launch_date, s.sale_date) > 18 THEN 'Beyond 18 months'
            ELSE 'Invalid Date'
        END AS seg
    FROM 
        products p
    JOIN 
        sales s ON p.product_id = s.product_id
    WHERE 
        s.sale_date >= p.launch_date  
) AS sales_segments
GROUP BY 
    product_name, seg
ORDER BY 
    product_name;
```
