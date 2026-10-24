# 原始数据

数据集来自 Kaggle：**Olist Brazilian E-Commerce Public Dataset**

https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce

> 原始 9 个 CSV 合计约 120 MB，超出 GitHub 单文件建议上限，故不纳入版本管理。
> 按下面的步骤自行下载并导入即可完整复现。

## 需要下载的文件

```
olist_orders_dataset.csv
olist_order_items_dataset.csv
olist_order_payments_dataset.csv
olist_order_reviews_dataset.csv
olist_customers_dataset.csv
olist_sellers_dataset.csv
olist_products_dataset.csv
olist_geolocation_dataset.csv
product_category_name_translation.csv
```

## 导入步骤

### 1. 建库

```sql
CREATE DATABASE olist DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_general_ci;
```

### 2. 建表并导入

用 Navicat 的「导入向导」，或 MySQL 的 `LOAD DATA LOCAL INFILE`。

**全部字段先按 `varchar` 导入**，时间列不要在这一步转类型 ——
CSV 里的空值是空字符串而不是 `NULL`，直接建成 `datetime` 会导入失败。

时间列在 `01_cast_datetime.sql` 里统一处理：
先 `NULLIF(col, '')` 把空串转成 `NULL`，再 `ALTER TABLE ... MODIFY COLUMN ... DATETIME`。

需要转类型的时间列：

| 表 | 列 |
|---|---|
| `olist_orders_dataset` | `order_purchase_timestamp`、`order_approved_at`、`order_delivered_carrier_date`、`order_delivered_customer_date`、`order_estimated_delivery_date` |
| `olist_order_items_dataset` | `shipping_limit_date` |
| `olist_order_reviews_dataset` | `review_creation_date`、`review_answer_timestamp` |

### 3. 校验导入结果

```sql
SELECT COUNT(*) FROM olist_orders_dataset;        -- 99,441
SELECT COUNT(*) FROM olist_order_reviews_dataset; -- 100,000
SELECT COUNT(*) FROM olist_order_items_dataset;   -- 112,650
SELECT COUNT(*) FROM olist_customers_dataset;     -- 99,441
```

对得上再往下走。第 10 行以后都可能出错，卡在这一步最省时间。
