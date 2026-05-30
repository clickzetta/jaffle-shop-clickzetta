-- 客户价值分层
-- 按消费金额将客户分为 VIP / Regular / New 三类

SELECT
    customer_type,
    COUNT(*)                                    AS customer_count,
    ROUND(AVG(lifetime_spend) / 100.0, 2)       AS avg_lifetime_spend_usd,
    ROUND(AVG(count_lifetime_orders), 1)        AS avg_orders
FROM {{ ref('customers') }}
GROUP BY customer_type
ORDER BY avg_lifetime_spend_usd DESC
