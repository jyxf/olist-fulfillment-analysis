-- ========================================================================
-- 逐表检查关联覆盖率
-- 四张维度表分别 LEFT JOIN，看有多少订单连不上。
-- order_items 是一对多，JOIN 后行数会膨胀 —— 要同时看 joined_rows 和 distinct order。
-- ========================================================================

-- customers_dataset 关联覆盖率
SELECT 
  COUNT(*) AS orders_total,
  COUNT(c.customer_id) AS matched
FROM olist_orders_dataset o
LEFT JOIN olist_customers_dataset c 
  ON o.customer_id = c.customer_id;

-- order_items_dataset 关联覆盖率
SELECT 
  COUNT(*) AS joined_rows,
  COUNT(DISTINCT o.order_id) AS orders_with_items
FROM olist_orders_dataset o
LEFT JOIN olist_order_items_dataset oi 
  ON o.order_id = oi.order_id;

-- payments_dataset 关联覆盖率
SELECT 
  COUNT(*) AS joined_rows,
  COUNT(DISTINCT o.order_id) AS orders_with_payment
FROM olist_orders_dataset o
LEFT JOIN olist_order_payments_dataset p 
  ON o.order_id = p.order_id;

-- order_reviews_dataset 关联覆盖率
SELECT 
  (SELECT COUNT(*) FROM olist_orders_dataset) AS total_orders,
  COUNT(DISTINCT r.order_id) AS orders_with_review,
  COUNT(*) AS joined_rows
FROM olist_orders_dataset o
LEFT JOIN olist_order_reviews_dataset r 
  ON o.order_id = r.order_id;
