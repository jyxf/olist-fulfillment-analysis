-- ========================================================================
-- 统一日期字段类型
-- varchar → DATETIME。先 NULLIF 去掉空字符串，否则 ALTER 会失败。
-- 覆盖 orders / order_items / order_reviews 三张表的所有时间列。
-- ========================================================================

UPDATE olist_orders_dataset SET
  order_purchase_timestamp = NULLIF(order_purchase_timestamp, ''),
  order_approved_at = NULLIF(order_approved_at, ''),
  order_delivered_carrier_date = NULLIF(order_delivered_carrier_date, ''),
  order_delivered_customer_date = NULLIF(order_delivered_customer_date, ''),
  order_estimated_delivery_date = NULLIF(order_estimated_delivery_date, '');

ALTER TABLE olist_orders_dataset
  MODIFY order_purchase_timestamp DATETIME,
  MODIFY order_approved_at DATETIME,
  MODIFY order_delivered_carrier_date DATETIME,
  MODIFY order_delivered_customer_date DATETIME,
  MODIFY order_estimated_delivery_date DATETIME;

-- ---- order_items 与 order_reviews 的时间列 ----

UPDATE olist_order_items_dataset
SET shipping_limit_date = NULLIF(shipping_limit_date, '');

ALTER TABLE olist_order_items_dataset
  MODIFY shipping_limit_date DATETIME;

UPDATE olist_order_reviews_dataset
SET review_creation_date = NULLIF(review_creation_date, ''),
    review_answer_timestamp = NULLIF(review_answer_timestamp, '');

ALTER TABLE olist_order_reviews_dataset
  MODIFY review_creation_date DATETIME,
  MODIFY review_answer_timestamp DATETIME;
