# DBT + Snowflake — Airbnb Medallion Architecture

A learning project that builds an end-to-end analytics pipeline for Airbnb-style data on **Snowflake** using **dbt**, following the **Bronze → Silver → Gold (medallion) architecture**.

## Project Structure

```
DBT_Snowflake/
├── main.py                          # Placeholder Python entry point
├── pyproject.toml                   # uv/Python project config (dbt-core, dbt-snowflake)
└── azure_dbt_snowflake_project/     # The dbt project
    ├── dbt_project.yml
    ├── profiles.yml / ExampleProfiles.yml
    ├── models/
    │   ├── sources/sources.yaml     # Raw source: AIRBNB.STAGING (listings, bookings, hosts)
    │   ├── bronze/                  # Incremental 1:1 copies of source tables
    │   ├── silver/                  # Cleaned, enriched, business-logic-applied tables
    │   └── gold/
    │       ├── ephemeral/           # CTE-style ephemeral models (not materialized)
    │       ├── obt.sql              # One Big Table (denormalized fact + dims)
    │       └── fact.sql             # Fact table built via dynamic Jinja joins
    ├── macros/                      # Reusable Jinja macros (multiply, tag, trimmer, schema naming)
    ├── snapshots/                   # Type-2 SCD snapshots for bookings/hosts/listings
    ├── analyses/                    # Ad-hoc Jinja/SQL exploration scripts (loops, if/else)
    ├── tests/                       # Custom singular data test (negative booking amount check)
    └── seeds/                       # Seed data folder (currently empty)
```

## Architecture

- **Bronze** — `bronze_bookings`, `bronze_hosts`, `bronze_listings`: incremental models that pull straight from the `AIRBNB.STAGING` source, loading only new rows based on `CREATED_AT`.
- **Silver** — `silver_bookings`, `silver_hosts`, `silver_listings`: incremental models that clean and enrich bronze data (e.g. computed `TOTAL_BOOKING_AMOUNT`, `RESPONSE_RATE_QUALITY`, `PRICE_PER_NIGHT_TAG` via macros).
- **Gold** — `obt.sql` joins the silver tables into a One Big Table; `fact.sql` and the `ephemeral/` models build fact/dimension-style outputs from the OBT using Jinja-driven dynamic joins.
- **Snapshots** — Type-2 snapshots (`dim_bookings`, `dim_hosts`, `dim_listings`) track historical changes over time using the `timestamp` strategy.
- **Macros** — Reusable Jinja helpers: `multiply()`, `tag()`, `trimmer()`, and a custom `generate_schema_name()` override.

## Getting Started

```bash
# Install dependencies (uv)
uv sync

# From azure_dbt_snowflake_project/, configure profiles.yml with your Snowflake credentials
cd azure_dbt_snowflake_project
dbt debug
dbt run
dbt test
dbt snapshot
```

## Tech Stack

- **dbt-core** / **dbt-snowflake**
- **Snowflake** as the data warehouse
- **Python 3.12** / **uv** for environment management

---

**Note:** In the age of AI-assisted coding, it's worth stating plainly — every line of code in this project was written by **[Archit Gupta](https://github.com/architg0409)**, with the sole exception of this README file.
