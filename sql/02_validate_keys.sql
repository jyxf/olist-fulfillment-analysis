-- ========================================================================
-- 校验行数与主键唯一性
-- COUNT(*) = COUNT(DISTINCT order_id) 才算主键唯一。
-- ========================================================================

SELECT 
  COUNT(*) AS total_rows,
  COUNT(DISTINCT order_id) AS distinct_order_id
FROM olist_orders_dataset;
