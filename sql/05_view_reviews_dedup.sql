-- ========================================================================
-- 评价去重视图
-- 每单只保留 review_answer_timestamp 最新的一条。
-- 注意：用 MAX(ts) JOIN 在时间戳并列时会返回多行；改动见 REFACTOR_NOTES 第 3 条。
-- ========================================================================

CREATE OR REPLACE VIEW reviews_dedup AS
SELECT r.*
FROM olist_order_reviews_dataset r
INNER JOIN (
  SELECT order_id, MAX(review_answer_timestamp) AS max_ts
  FROM olist_order_reviews_dataset
  GROUP BY order_id
) t
ON r.order_id = t.order_id 
AND r.review_answer_timestamp = t.max_ts;
