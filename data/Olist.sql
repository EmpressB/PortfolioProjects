
SELECT osd.seller_state, COUNT(osd.seller_id) AS num_of_sellers  
FROM olist_sellers_dataset osd 
WHERE seller_state = (SELECT MIN(seller_state) FROM olist_sellers_dataset)

--Which state has  the most sellers?
SELECT osd.seller_state, COUNT(osd.seller_id) AS num_of_sellers  
FROM olist_sellers_dataset osd 
WHERE seller_state =(SELECT MAX(seller_state) FROM olist_sellers_dataset)

--How many sellers in each state in Brazil?
SELECT DISTINCT osd.seller_state,count(seller_id) AS num_of_sellers 
FROM olist_sellers_dataset osd 
GROUP BY seller_state 
ORDER BY 2 DESC 


---list of order in 2016------
SELECT ood.order_approved_at ,ood.order_delivered_carrier_date ,ood.order_delivered_customer_date 
FROM olist_orders_dataset ood 
WHERE order_delivered_customer_date <=2017
GROUP BY 3
ORDER BY 2 ASC 
--only shows info for the month of october----

--which item had the  most sales by state?
WITH TopItems AS 
(
SELECT  prods.product_category_name, SUM(items.price) AS Total_Sales,ocdm.customer_state
FROM olist_order_items_dataset items
JOIN olist_products_dataset prods ON items.product_id = prods.product_id 
JOIN olist_orders_dataset ood ON items.order_id = ood.order_id 
JOIN olist_customers_dataset_merge ocdm ON ood.customer_id = ocdm.customer_id 
GROUP BY 1,3
)
SELECT product_category_name,customer_state, max(Total_Sales)
FROM TopItems
--WHERE Total_Sales= (SELECT MAX(Total_Sales) FROM TopItems)
GROUP BY 2
ORDER BY 1 DESC



---how many customer_states are there?
SELECT DISTINCT ocdm.customer_state 
FROM olist_customers_dataset_merge ocdm 

---same answer as before---
SELECT DISTINCT ogd.geolocation_state 
FROM olist_geolocation_dataset ogd 

--What year had the highest sales--?
WITH HighYear AS 
(
SELECT ood.order_purchase_timestamp, SUM(ooid.price) AS Total_Sales  
FROM olist_order_items_dataset ooid 
JOIN olist_orders_dataset ood ON ooid.order_id = ood.order_id 
WHERE ood.order_purchase_timestamp >2016
GROUP BY 1
ORDER BY 2 DESC
)

SELECT order_purchase_timestamp,max(Total_Sales)
FROM HighYear
---2017 HAD 13,440, 2018 had 7160----

----nothing shows just null
SELECT oopd.payment_value,ood.order_delivered_customer_date  
FROM olist_orders_dataset ood 
LEFT JOIN olist_order_payments_dataset oopd ON ood.order_id = oopd.order_id 
WHERE oopd.payment_value IS NULL 


SELECT oopd.payment_sequential 
FROM olist_order_payments_dataset oopd 
WHERE payment_sequential ISNULL 



--what is the average shipping time per category?

SELECT opd.product_category_name,round(AVG(ood.order_delivered_customer_date),2) AS avg_delivery_time  
FROM olist_order_items_dataset ooid 
JOIN olist_products_dataset opd ON ooid.product_id = opd.product_id 
JOIN olist_orders_dataset ood ON ooid.order_id = ood.order_id 


---what are the average reviews for the top items?---

--are the customers getting their shipment fast?
--breakdown BY year---

WITH avgdays  AS 
(
SELECT ood.order_purchase_timestamp,
ood.order_delivered_carrier_date ,
ood.order_delivered_customer_date, 
ooid.shipping_limit_date, round(JULIANDAY(order_delivered_customer_date) - JULIANDAY(order_delivered_carrier_date),2) AS ship_days 
FROM olist_orders_dataset ood 
JOIN olist_order_items_dataset ooid ON ood.order_id = ooid.order_id 
---WHERE ood.order_purchase_timestamp < 2017
GROUP BY 1
ORDER BY 4 ASC 
)
SELECT --AVG(ship_days) 
count(ship_days)
FROM avgdays
----WHERE ship_days >10


---31,323  amount of shipmnets that took  more than 10 days
---95,931 is the amount of shipments from 2016-2018


SELECT *
FROM olist_order_payments_dataset oopd 

SELECT *
FROM olist_order_reviews_dataset oord 

