-- 门店营收排名
-- 跑完 dbt build 后在 Studio 或 cz-cli 中执行
-- cz-cli sql "$(cat analyses/store_revenue.sql)" --profile <your_profile> --sync

SELECT
    l.location_name,
    COUNT(DISTINCT o.order_id)          AS total_orders,
    ROUND(SUM(o.subtotal) / 100.0, 2)   AS revenue_usd,
    ROUND(AVG(o.subtotal) / 100.0, 2)   AS avg_order_usd
FROM {{ ref('orders') }} o
JOIN {{ ref('locations') }} l ON o.location_id = l.location_id
GROUP BY l.location_name
ORDER BY revenue_usd DESC
