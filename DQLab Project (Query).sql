----- Data Analysis for E-Commerce (DQLab) -----


-- 1)The 10 largest transactions of user 12476
SELECT seller_id,
       buyer_id,
       total AS tsc_value,
       created_at AS tsc_date
FROM orders
WHERE buyer_id = 12476
ORDER BY tsc_value DESC
LIMIT 10;

-- 2)Monthly transaction summary for the year 2020
SELECT EXTRACT(YEAR_MONTH FROM created_at) AS year_monthh,
       COUNT(EXTRACT(YEAR_MONTH FROM created_at)) AS total_tsc,
       SUM(total) AS total_tsc_value
FROM orders
WHERE created_at >= '2020-01-01'
GROUP BY EXTRACT(YEAR_MONTH FROM created_at)
ORDER BY EXTRACT(YEAR_MONTH FROM created_at);

-- 3)User with the highest average transaction in January 2020
SELECT buyer_id,
       COUNT(buyer_id) AS total_tsc,
       ROUND(AVG(total)) AS avg_tsc_value
FROM orders
WHERE created_at >= '2020-01-01' AND created_at < '2020-02-01'
GROUP BY buyer_id
HAVING COUNT(buyer_id) >= 2
ORDER BY avg_tsc_value DESC
LIMIT 10;

-- 4)Large transactions in December 2019
SELECT nama_user AS buyers_name,
       total AS tsc_value,
       created_at AS tsc_date
FROM orders 
INNER JOIN users ON user_id = buyer_id
WHERE created_at >= '2019-12-01' AND created_at < '2020-01-01' AND total >= 20000000
ORDER BY total DESC;

-- 5)Best-selling product categories in 2020
SELECT category,
       SUM(quantity) AS total_quantity,
       SUM(price) AS total_price
FROM orders
INNER JOIN order_details USING(order_id)
INNER JOIN products USING(product_id)
WHERE created_at >= '2020-01-01' AND delivery_at IS NOT NULL
GROUP BY category
ORDER BY total_quantity DESC
LIMIT 5;

-- 6)Finding high-value buyers
SELECT nama_user AS buyers_name,
       COUNT(1) AS total_tsc,
       SUM(total) AS total_tsc_value,
       MIN(total) AS min_tsc_value
FROM orders
INNER JOIN users ON buyer_id = user_id
GROUP BY user_id, nama_user
HAVING COUNT(1) > 5 AND MIN(total) > 2000000
ORDER BY 3 DESC;

-- 7)Finding dropshippers
SELECT nama_user AS buyers_name,
       COUNT(1) AS total_tsc,
       COUNT(DISTINCT orders.kodepos) AS distinct_postal_code,
       SUM(total) AS total_tsc_value,
       AVG(total) AS avg_tsc_value
FROM orders
INNER JOIN users
ON buyer_id = user_id
GROUP BY user_id, nama_user
HAVING COUNT(1) >= 10 AND COUNT(1) = COUNT(DISTINCT orders.kodepos)
ORDER BY 2 DESC;

-- 8)Finding offline resellers
SELECT nama_user AS buyers_name,
       COUNT(nama_user) AS total_tsc,
       SUM(total) AS total_tsc_value,
       AVG(total) AS avg_tsc_value,
       AVG(total_quantity) AS avg_quantity_per_tsc
FROM orders
INNER JOIN users ON buyer_id = user_id
INNER JOIN (SELECT order_id,
                   SUM(quantity) AS total_quantity
            FROM order_details
            GROUP BY 1) AS summary_order USING(order_id)
WHERE orders.kodepos = users.kodepos
GROUP BY user_id, nama_user
HAVING COUNT(nama_user) >= 8 AND AVG(total_quantity) > 10
ORDER BY 3 DESC;

-- 9)Buyer and seller at the same time
SELECT nama_user AS users_name,
       total_purchase_tsc,
       total_sales_tsc
FROM users
INNER JOIN(
       SELECT buyer_id,
              COUNT(1) AS total_purchase_tsc
       FROM orders
       GROUP BY 1) AS buyer
ON buyer_id = user_id
INNER JOIN(
       SELECT seller_id,
              COUNT(1) AS total_sales_tsc
       FROM orders
       GROUP BY 1) AS seller
ON seller_id = user_id
WHERE total_purchase_tsc >= 7
ORDER BY 1;

-- 10)Time taken for the transaction to be paid
SELECT EXTRACT(YEAR_MONTH FROM created_at) AS year_monthh,
       COUNT(1) AS jumlah_transaksi,
       AVG(DATEDIFF(paid_at, created_at)) AS avg_time_paid,
       MIN(DATEDIFF(paid_at, created_at)) AS min_time_paid,
       MAX(DATEDIFF(paid_at, created_at)) AS max_time_paid
FROM orders
WHERE paid_at IS NOT NULL
GROUP BY 1
ORDER BY 1;

