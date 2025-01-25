CREATE DATABASE Apple_db
GO

CREATE TABLE stores(
store_id varchar(5) PRIMARY KEY,
store_name varchar(30),
city varchar(25),
country varchar(25));

CREATE TABLE category(
category_id varchar(10) PRIMARY KEY,
category_name varchar(20));

CREATE TABLE products(
product_id varchar(10) primary key,
product_name varchar(40),
category_id	varchar(10),
launch_date	DATE,
price FLOAT,
CONSTRAINT fk_category FOREIGN KEY (category_id) REFERENCES category(category_id));

ALTER TABLE products
ALTER COLUMN product_id varchar(10) NOT NULL;

ALTER TABLE products
ADD CONSTRAINT pk_product_id PRIMARY KEY(product_id);

CREATE TABLE sales(
sale_id varchar(20) primary key,
sale_date date,
store_id varchar(5),
product_id varchar(10),
quantity int,
CONSTRAINT fk_stores foreign key(store_id) references stores(store_id),
CONSTRAINT fk_products foreign key(product_id) references products(product_id));

ALTER TABLE sales
ALTER column sale_id varchar(50) not null;

CREATE TABLE warranty(
claim_id varchar(10) PRIMARY KEY,
claim_date DATE,
sale_id varchar(20),
repair_status varchar(15),
CONSTRAINT fk_sales foreign key(sale_id) references sales(sale_id));

ALTER TABLE warranty 
DROP CONSTRAINT PK__warranty__F9CC08967407EBEB;

ALTER TABLE warranty
ALTER COLUMN claim_id varchar(50) not null;

ALTER TABLE warranty
ADD CONSTRAINT PK__warranty PRIMARY KEY (claim_id);

ALTER TABLE dbo.warranty
ALTER COLUMN repair_status VARCHAR(50);

ALTER TABLE warranty
DROP constraint fk_sales;

ALTER TABLE warranty
ALTER COLUMN sale_id varchar(50);

ALTER TABLE warranty
ADD constraint fk_sales foreign key(sale_id) references sales(sale_id);

ALTER TABLE dbo.warranty NOCHECK CONSTRAINT fk_sales;

ALTER TABLE dbo.warranty CHECK CONSTRAINT fk_sales;

