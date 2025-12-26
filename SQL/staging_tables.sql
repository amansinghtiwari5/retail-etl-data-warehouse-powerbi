create database superstore;

use superstore;

CREATE TABLE stg_customers (
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50)
);

CREATE TABLE stg_products (
    product_id VARCHAR(50),
    product_name VARCHAR(150),
    category VARCHAR(50),
    sub_category VARCHAR(50)
);

CREATE TABLE stg_regions (
    region_id INT,
    country VARCHAR(50),
    region VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    postal_code VARCHAR(20)
);

CREATE TABLE stg_orders (
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    product_id VARCHAR(50),
    region_id INT,
    sales DECIMAL(10,2)
);

alter table stg_orders modify order_date varchar(20);

alter table stg_orders modify ship_date varchar(20);

SELECT ship_date FROM stg_orders LIMIT 5;

UPDATE stg_orders SET order_date = STR_TO_DATE(order_date, '%d/%m/%Y');

UPDATE stg_orders
SET ship_date = STR_TO_DATE(order_date, '%Y-%m-%d');

ALTER TABLE stg_orders
MODIFY order_date DATE;

ALTER TABLE stg_orders
MODIFY ship_date DATE;


SELECT * FROM stg_orders LIMIT 5;

SELECT COUNT(*) FROM stg_customers;
SELECT COUNT(*) FROM stg_products;
SELECT COUNT(*) FROM stg_regions;
SELECT COUNT(*) FROM stg_orders;

SELECT
    SUM(order_id IS NULL) AS order_id_nulls,
    SUM(customer_id IS NULL) AS customer_id_nulls,
    SUM(product_id IS NULL) AS product_id_nulls,
    SUM(sales IS NULL) AS sales_nulls
FROM stg_orders;

SELECT order_id, COUNT(*)
FROM stg_orders
GROUP BY order_id
HAVING COUNT(*) > 1;

SELECT *
FROM stg_orders
WHERE order_date IS NULL OR ship_date IS NULL;

DELETE FROM stg_orders
WHERE order_date IS NULL;

ALTER TABLE stg_orders
ADD COLUMN revenue DECIMAL(10,2);

UPDATE stg_orders
SET revenue = sales;

ALTER TABLE stg_orders
ADD COLUMN shipping_days INT;

UPDATE stg_orders
SET shipping_days = DATEDIFF(ship_date, order_date);

DELETE FROM stg_orders
WHERE shipping_days < 0;

UPDATE stg_customers
SET segment = UPPER(segment);

UPDATE stg_products
SET category = UPPER(category),
    sub_category = UPPER(sub_category);

UPDATE stg_orders
SET ship_mode = UPPER(ship_mode);

SELECT MIN(revenue), MAX(revenue)
FROM stg_orders;

DELETE FROM stg_orders
WHERE revenue <= 0;

CREATE VIEW vw_clean_orders AS
SELECT
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    product_id,
    region_id,
    revenue,
    shipping_days
FROM stg_orders;




