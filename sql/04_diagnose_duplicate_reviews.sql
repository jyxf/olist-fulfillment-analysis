-- ========================================================================
-- 诊断重复评价
-- 评价表 100,000 行，订单只有 99,441 个 —— 先量化膨胀程度，再决定怎么去重。
-- ========================================================================

SELECT 
  review_cnt,
  COUNT(*) AS order_num
FROM (
  SELECT order_id, COUNT(*) AS review_cnt
  FROM olist_order_reviews_dataset
  GROUP BY order_id
) t
GROUP BY review_cnt
ORDER BY review_cnt;
