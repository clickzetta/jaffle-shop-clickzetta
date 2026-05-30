-- 热销商品 Top 10
-- 按订单次数统计最受欢迎的商品

SELECT
    product_name,
    product_type,
    ROUND(product_price / 100.0, 2)     AS price_usd,
    COUNT(*)                            AS times_ordered,
    ROUND(SUM(product_price) / 100.0, 2) AS total_revenue_usd
FROM {{ ref('order_items') }}
GROUP BY product_name, product_type, product_price
ORDER BY times_ordered DESC
LIMIT 10
