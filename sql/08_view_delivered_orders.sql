-- ========================================================================
-- 妥投订单视图（核心底表）
-- 只保留 delivered 且下单/送达/承诺三个时间齐全的订单 = 96,470 单。
-- 不要求 order_delivered_carrier_date 非空：已妥投就是已妥投，
--   交运时间缺失属单字段问题，不该丢掉整张订单（差 1 单）。
--   用到交运时间的分析（脚本 11）自行加过滤。
-- delay_group 在此定义一次，下游 10 / 13 直接引用，不再重复写 CASE。
-- ⚠ 本视图是全部下游分析的唯一取数入口，不要在其他脚本里重复定义。
-- ========================================================================

CREATE OR REPLACE VIEW v_delivered_orders AS
SELECT
  t.*,
  CASE
    WHEN t.delay_days <= 0  THEN '1.准时/提前'
    WHEN t.delay_days <= 3  THEN '2.延迟1-3天'
    WHEN t.delay_days <= 7  THEN '3.延迟4-7天'
    ELSE                         '4.延迟8天以上'
  END AS delay_group,
  -- 数字排序键：图表/透视表按此列排序，不依赖字符串前缀的字典序。
  -- Power BI 里用「列工具 → 按列排序 → delay_rank」绑到 delay_group 上。
  CASE
    WHEN t.delay_days <= 0  THEN 1
    WHEN t.delay_days <= 3  THEN 2
    WHEN t.delay_days <= 7  THEN 3
    ELSE                         4
  END AS delay_rank
FROM (
  SELECT
    order_id,
    customer_id,
    order_purchase_timestamp,
    order_delivered_carrier_date,
    order_delivered_customer_date,
    order_estimated_delivery_date,
    -- 实际配送天数：下单 → 送达
    DATEDIFF(order_delivered_customer_date, order_purchase_timestamp) AS actual_days,
    -- 延迟天数：实际送达 - 承诺送达。正值 = 延迟，负值 = 提前
    DATEDIFF(order_delivered_customer_date, order_estimated_delivery_date) AS delay_days
  FROM olist_orders_dataset
  WHERE order_status = 'delivered'
    AND order_purchase_timestamp IS NOT NULL
    AND order_delivered_customer_date IS NOT NULL
    AND order_estimated_delivery_date IS NOT NULL
) t;

-- 校验：应为 96,470
SELECT COUNT(*) AS rows_cnt FROM v_delivered_orders;

-- ------------------------------------------------------------------------
-- 为什么是这四档（分桶依据，可直接用于答辩）
--
-- 1) 拐点：按"延误天数"逐日看差评率，1→6 天陡升（19.8% → 76.6%），
--    7 天以后进入平台（73.5% ~ 83.1%），故在 7/8 天处分界。
--
-- 2) 为什么把"15 天以上"并入"8 天以上"：
--      8-15 天    n=1,637   差评率 80.21%   95%CI ±1.93pp
--      15 天以上  n=1,225   差评率 78.53%   95%CI ±2.30pp
--      差异 1.68pp，z = 1.09 < 1.96 —— 不显著，属抽样噪声。
--    分开画会得到"80.2% 之后回落到 78.5%"的假象，合并后才呈现真实的单调上升。
--
-- 3) 已知异常（需在报告中标注，不要硬解释）：
--      31 天以上 n=345，差评率 68.70%（±4.89pp），显著低于 16-30 天的 82.39%。
--    可能来自极端远端地区的样本构成差异，结论不宜外推。
-- ------------------------------------------------------------------------
