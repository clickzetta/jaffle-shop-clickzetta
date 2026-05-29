# jaffle-shop-clickzetta

[jaffle-shop](https://github.com/dbt-labs/jaffle-shop) adapted for [ClickZetta Lakehouse](https://www.yunqi.tech/). Use this project to get started with dbt + ClickZetta in minutes.

## What's inside

A coffee shop order dataset with a full dbt project:

- 6 CSV seed files → raw tables (153,864 rows total)
- 6 staging views (data cleaning layer)
- 7 mart tables (business-ready layer)
- 27 data quality tests

## Prerequisites

- Python 3.10+
- A ClickZetta Lakehouse instance (workspace, vcluster, username, password)
- dbt-clickzetta 1.6.5+

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

Verify the connection:

```bash
dbt debug --profiles-dir .
```

**3. Run the project**

```bash
dbt deps --profiles-dir .
dbt seed --profiles-dir .
dbt run --profiles-dir .
dbt test --profiles-dir .
```

Expected output:

```
dbt seed  → Done. PASS=6  WARN=0 ERROR=0 TOTAL=6
dbt run   → Done. PASS=13 WARN=0 ERROR=0 TOTAL=13
dbt test  → Done. PASS=27 WARN=0 ERROR=0 TOTAL=27
```

## ClickZetta-specific adaptations

This fork adds the following on top of the original jaffle-shop:

| File | Change |
|------|--------|
| `profiles.yml.example` | ClickZetta connection template |
| `macros/clickzetta_seed_batch_size.sql` | Limits seed batch size to 1000 rows to avoid oversized INSERT statements |
| `dbt_project.yml` | Sets profile name; disables dbt unit tests (unsupported `cast...not null` syntax) |
| `packages.yml` | Removes unused `dbt-audit-helper` |

## Project structure

```
models/
  staging/    ← views: clean raw data
  marts/      ← tables: business-ready
seeds/
  jaffle-data/  ← 6 CSV files
macros/
  clickzetta_seed_batch_size.sql
profiles.yml.example
```

## Documentation

Full step-by-step guide (Chinese): [dbt + ClickZetta Lakehouse 快速入门](https://docs.yunqi.tech)

dbt-clickzetta adapter: [github.com/clickzetta/dbt-clickzetta](https://github.com/clickzetta/dbt-clickzetta)
