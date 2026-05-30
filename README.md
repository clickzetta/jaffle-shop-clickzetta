# jaffle-shop-clickzetta

[jaffle-shop](https://github.com/dbt-labs/jaffle-shop) adapted for [ClickZetta Lakehouse](https://www.yunqi.tech/). Use this project to get started with dbt + ClickZetta in minutes.

## What's inside

A coffee shop order dataset with a full dbt project:

- 6 CSV seed files → raw tables (153,864 rows total)
- 6 staging views (data cleaning layer)
- 7 mart tables (business-ready layer)
- 27 data quality tests + 3 unit tests
- 3 example analyses (store revenue, customer segments, top products)

## Prerequisites

- Python 3.10+
- A ClickZetta Lakehouse instance (workspace, vcluster, username, password)
- dbt-clickzetta 1.7.0+

## Quickstart

**1. Clone and set up environment**

```bash
git clone https://github.com/clickzetta/jaffle-shop-clickzetta.git
cd jaffle-shop-clickzetta

python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install dbt-clickzetta
```

**2. Configure connection**

```bash
cp profiles.yml.example profiles.yml
```

Edit `profiles.yml` with your instance details:

```yaml
jaffle_shop:
  target: dev
  outputs:
    dev:
      type: clickzetta
      service: <your-service-endpoint>
      instance: <your-instance-id>
      workspace: <your-workspace>
      username: <your-username>
      password: <your-password>
      schema: dbt_jaffle
      vcluster: default_ap
```

Set the profiles directory so you don't need `--profiles-dir .` on every command:

```bash
export DBT_PROFILES_DIR=.
```

Verify the connection:

```bash
dbt debug
```

**3. Run the project**

```bash
dbt deps
dbt seed    # ~60s — loads 153,864 rows via COPY INTO
dbt run     # ~5s  — builds 13 models
dbt test    # ~10s — runs 27 data quality tests + 3 unit tests
```

Expected output:

```
dbt seed  → Done. PASS=6  WARN=0 ERROR=0 SKIP=0 TOTAL=6
dbt run   → Done. PASS=13 WARN=0 ERROR=0 SKIP=0 TOTAL=13
dbt test  → Done. PASS=30 WARN=0 ERROR=0 SKIP=0 TOTAL=30
```

**4. Explore the results**

Query the mart tables directly in ClickZetta Studio or via cz-cli. Three ready-to-run example queries are in `analyses/`:

| File | Query |
|------|-------|
| `analyses/store_revenue.sql` | Revenue and order count by store location |
| `analyses/customer_segments.sql` | Customer count and avg spend by segment |
| `analyses/top_products.sql` | Top 10 products by order frequency |

Quick samples:

```sql
-- Store revenue ranking
SELECT
    l.location_name,
    COUNT(DISTINCT o.order_id)        AS total_orders,
    ROUND(SUM(o.subtotal) / 100.0, 2) AS revenue_usd
FROM dbt_jaffle.orders o
JOIN dbt_jaffle.locations l ON o.location_id = l.location_id
GROUP BY l.location_name
ORDER BY revenue_usd DESC;
```

```sql
-- Customer value segments
SELECT
    customer_type,
    COUNT(*)                               AS customers,
    ROUND(AVG(lifetime_spend) / 100.0, 2) AS avg_spend_usd
FROM dbt_jaffle.customers
GROUP BY customer_type
ORDER BY avg_spend_usd DESC;
```

```sql
-- Top 10 products by order count
SELECT
    product_name,
    product_type,
    COUNT(*) AS times_ordered
FROM dbt_jaffle.order_items
GROUP BY product_name, product_type
ORDER BY times_ordered DESC
LIMIT 10;
```

**5. View data lineage (optional)**

```bash
dbt docs generate
dbt docs serve
```

Open http://localhost:8080 to explore the data lineage graph.

## ClickZetta-specific adaptations

| File | Change |
|------|--------|
| `profiles.yml.example` | ClickZetta connection template |
| `dbt_project.yml` | `column_types: string` for all seed columns — required for COPY INTO compatibility (dbt-clickzetta 1.7.0+) |
| `macros/generate_schema_name.sql` | Preserves custom schema names in non-default targets |

## Project structure

```
models/
  staging/    ← views: clean raw data
  marts/      ← tables: business-ready
analyses/     ← example queries to run after dbt build
seeds/
  jaffle-data/  ← 6 CSV files (153,864 rows)
profiles.yml.example
```

## Documentation

Full step-by-step guide (Chinese): [dbt + ClickZetta Lakehouse 快速入门](https://docs.yunqi.tech)

dbt-clickzetta adapter: [github.com/clickzetta/dbt-clickzetta](https://github.com/clickzetta/dbt-clickzetta)
