-- ========================================================================
-- 州级瓶颈定位
-- 问题：各州在途时长差多少？差评率差多少？差距出在卖家发货还是物流在途？
-- 三步：按州看规模与差评 → 按州看时长 → 拆成卖家发货 / 物流在途
-- ========================================================================

-- ---- 1. 州级：单量、在途时长、差评率 ----
-- 单量与差评率要放在一起看：既慢又差评多、且单量大的州，才是真优先级。
SELECT
  c.customer_state AS state,
  COUNT(o.order_id) AS total_orders,
  ROUND(COUNT(o.order_id) / (SELECT COUNT(*) FROM v_delivered_orders) * 100, 2) AS order_share_pct,
  ROUND(AVG(o.actual_days), 2) AS avg_transit_days,
  ROUND(AVG(r.review_score), 2) AS avg_score,
  ROUND(SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS bad_review_rate_pct
FROM v_delivered_orders o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN reviews_dedup r ON o.order_id = r.order_id
GROUP BY c.customer_state
ORDER BY avg_transit_days DESC;

-- ---- 2. 关键州：卖家发货时长 vs 物流在途时长 ----
-- 用途：区分"卖家慢"还是"物流慢"。若各州 seller_days 接近，问题就在物流。
SELECT
  c.customer_state AS state,
  ROUND(AVG(DATEDIFF(o.order_delivered_carrier_date, o.order_purchase_timestamp)), 2) AS avg_seller_days,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date)), 2) AS avg_logistics_days
FROM v_delivered_orders o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
WHERE o.order_delivered_carrier_date IS NOT NULL   -- 1 单交运时间缺失，此处单独排除
GROUP BY c.customer_state
ORDER BY avg_logistics_days DESC;
