-- ========================================================================
-- 导出 Power BI 宽表
-- 最终交付：一张干净的、可直接连看板的宽表。
-- delay_group 直接取自 08 视图，与脚本 10 完全同源，不会出现两张图对不上的情况。
-- 注意：seller_days / logistics_days 依赖 carrier_date，有 1 单该字段为空，
--       两个字段会返回 NULL —— 看板按州聚合时忽略即可，不删除订单。
-- ========================================================================

CREATE OR REPLACE VIEW v_bi_dashboard_data AS
SELECT
  o.order_id,
  c.customer_state,
  c.customer_city,
  o.order_purchase_timestamp,
  o.actual_days,
  o.delay_days,
  o.delay_group,
  o.delay_rank,   -- 供 Power BI「按列排序」使用，保证 x 轴顺序与业务一致
  o.order_delivered_carrier_date,
  DATEDIFF(o.order_delivered_carrier_date, o.order_purchase_timestamp) AS seller_days,
  DATEDIFF(o.order_delivered_customer_date, o.order_delivered_carrier_date) AS logistics_days,
  r.review_score
FROM v_delivered_orders o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN reviews_dedup r ON o.order_id = r.order_id;

-- 校验：应为 96,470（与 08 视图一致）
SELECT COUNT(*) AS rows_cnt FROM v_bi_dashboard_data;
