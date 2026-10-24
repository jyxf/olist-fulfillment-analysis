-- ========================================================================
-- 延迟整体分布
-- 看延迟率、极值、均值，确认数据合理。
-- ========================================================================

SELECT 
  COUNT(*) AS total_orders,
  MIN(delay_days) AS min_delay,
  MAX(delay_days) AS max_delay,
  AVG(delay_days) AS avg_delay,
  SUM(CASE WHEN delay_days > 0 THEN 1 ELSE 0 END) AS delayed_orders,
  ROUND(SUM(CASE WHEN delay_days > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS delayed_rate_pct
FROM v_delivered_orders;
