#=====================
# STEP 1: Data Overview
#=====================

-- Let's take a quick look at these tables before we start querying. 

Select *
From 
`warehouse.warehouse_warehouse`
Limit 100

Select *
From 
`warehouse.warehouse_orders`
Limit 100

#====================================================
# STEP 2: WRANGLE DATA AND COMBINE INTO A SINGLE FILE
#====================================================

-- Since we want corresponding data from both tables we’ll use JOIN as shorthand for INNER JOIN and alias the warehouse tables in the process.

SELECT
orders.*,
warehouse_alias,
warehouse.state
FROM
`warehouse.warehouse_orders` orders
JOIN
`warehouse.warehouse_warehouse` warehouse ON orders.warehouse_id = warehouse.warehouse_id


#======================================================
# STEP 3: PREPARE Data FOR ANALYSIS
#======================================================

-- To answer how many states are in our ordered data
we'll use COUNT DISTINCT

Select
warehouse.state AS state,
Count(Distinct warehouse.state) AS num_states
FROM
`warehouse.warehouse_orders` orders
JOIN
`warehouse.warehouse_warehouse` warehouse ON orders.warehouse_id = warehouse.warehouse_id
GROUP BY warehouse.state

-- According to these results, we have three distinct states in our Orders data.
-- now we want to know how many orders within each state

Select
Warehouse.state AS state,
Count(Distinct order_id) AS num_orders
FROM
`warehouse.warehouse_orders` orders
JOIN
`warehouse.warehouse_warehouse` warehouse ON orders.warehouse_id = warehouse.warehouse_id
GROUP BY warehouse.state


#======================================================
# STEP 4: DATA AGGREGATION
#======================================================

-- what percentage of the orders are fulfilled by each warehouse
-- which warehouses are delivering the most orders

select
warehouse.warehouse_id,
CONCAT(warehouse.state, ': ',warehouse_alias) AS warehouse_name,
COUNT(orders.order_id) AS num_orders,
(SELECT
COUNT(*)
FROM `warehouse.warehouse_orders` orders)
AS total_orders,
CASE
WHEN COUNT(orders.order_id)/(SELECT COUNT(*) FROM `warehouse.warehouse_orders`) <=0.20
THEN "fulfilled 0-20% of orders"
WHEN COUNT(orders.order_id)/(SELECT COUNT(*) FROM `warehouse.warehouse_orders`) >0.20
AND COUNT(orders.order_id)/(SELECT COUNT(*) FROM `warehouse.warehouse_orders`) <=0.60
THEN "fulfilled 21-60% of orders"
ELSE "fulfilled more than 60% of orders"
END AS fulfillment_summary
from `warehouse.warehouse_warehouse` warehouse
LEFT JOIN 
`warehouse.warehouse_orders` orders ON warehouse.warehouse_id = orders.order_id
GROUP BY
warehouse_id,
warehouse_name
HAVING 
COUNT(orders.order_id) > 0 

