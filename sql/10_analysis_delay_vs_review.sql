-- ========================================================================
-- 延误天数 → 差评率（核心分析）
-- 看点：分桶看差评率，而不是只看平均分——平均分会把 79% 的差评压成"1.69 分"。
-- delay_group 已在 08 视图里定义，这里直接 GROUP BY，不重复写 CASE。
-- ========================================================================

SELECT
  o.delay_group,
  COUNT(*) AS order_cnt,
  ROUND(COUNT(*) / (SELECT COUNT(*) FROM v_delivered_orders) * 100, 2) AS order_share_pct,
  ROUND(AVG(r.review_score), 2) AS avg_score,
  ROUND(SUM(CASE WHEN r.review_score <= 2 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS bad_review_rate_pct
FROM v_delivered_orders o
INNER JOIN reviews_dedup r ON o.order_id = r.order_id
GROUP BY o.delay_group
ORDER BY o.delay_group;

-- 预期结果（分桶依据见 08 注释）：
--   准时/提前      89,936   93.23%   4.28   9.54%
--   延迟1-3天       1,870    1.94%   3.28   32.41%
--   延迟4-7天       1,802    1.87%   2.09   68.09%
--   延迟8天以上      2,862    2.97%   1.69   79.49%
--
-- 结论：差评率随延误单调上升，但斜率在 7 天处折断 ——
--       1-3 天 32.4%（+22.9pp）、4-7 天 68.1%（+35.7pp）、8 天以上 79.5%（+11.4pp）。
--       真正的伤害发生在"开始延误后的头一周"，此后再延长几乎不再恶化。
--       因此运营目标不是"消灭所有延误"，而是"把延误压回 7 天以内"。
