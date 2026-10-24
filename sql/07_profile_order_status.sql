-- ========================================================================
-- 订单状态与日期缺失情况
-- 所有 status 都要看，才知道为什么只保留 delivered。
-- 空值集中在 canceled / unavailable / shipped —— 这是筛选依据。
-- ========================================================================

SELECT
  order_status,
  COUNT(*) AS total,
  SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS approved_null,
  SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS carrier_null,
  SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS delivered_null,
  SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS estimated_null
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total DESC;
