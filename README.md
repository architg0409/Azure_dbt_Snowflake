# DBT + Snowflake — Airbnb Medallion Architecture

A learning project that builds an end-to-end analytics pipeline for Airbnb-style data on **Snowflake** using **dbt**, following the **Bronze → Silver → Gold (medallion) architecture**. Source data is staged in **Azure Blob Storage** and loaded into Snowflake via an external stage.

## Project Structure

```
DBT_Snowflake/
├── .gitignore                       # Single, root-level gitignore for the whole repo
├── pyproject.toml                   # uv/Python project config (dbt-core, dbt-snowflake)
├── uv.lock
├── .python-version
├── DDL/
│   ├── ddl.sql                      # Creates AIRBNB.STAGING database/schema + raw tables
│   └── resources.sql                # Azure storage integration, stage, file format, COPY INTO
├── SourceData/
│   ├── bookings.csv                 # Sample raw data to upload to Azure Blob Storage
│   ├── hosts.csv
│   └── listings.csv
└── azure_dbt_snowflake_project/     # The dbt project
    ├── dbt_project.yml
    ├── ExampleProfiles.yml          # Template — copy to profiles.yml and fill in your creds
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

### 1. Install dependencies

```bash
uv sync
```

### 2. Create the Snowflake database and raw tables

Run `DDL/ddl.sql` in Snowflake. This creates the `AIRBNB` database, `STAGING` schema, and the raw `HOSTS`, `LISTINGS`, `BOOKINGS` tables that dbt's sources point to.

### 3. Set up Azure Blob Storage (source for the external stage)

`DDL/resources.sql` loads data into Snowflake from an **Azure Blob Storage** container via an external stage, so the following needs to exist on the Azure side first:

1. **Create a storage account and container** in the Azure Portal (e.g. account `mystorageaccount`, container `airbnb-data`).
2. **Upload the CSVs** from `SourceData/` (`bookings.csv`, `hosts.csv`, `listings.csv`) into that container.
3. **Note your Azure AD Tenant ID**, storage account name, and container name — you'll substitute these into `resources.sql` in place of `<tenant-id>`, `<storage_account>`, and `<container>`.

### 4. Create the storage integration and stage in Snowflake

Run `DDL/resources.sql` (with the placeholders filled in) up through the `CREATE STORAGE INTEGRATION` and `CREATE STAGE` statements. Then:

1. Run `DESC STORAGE INTEGRATION azure_int;` and note the `AZURE_CONSENT_URL` and `AZURE_MULTI_TENANT_APP_NAME` values it returns.
2. **Grant Azure AD consent**: open the `AZURE_CONSENT_URL` as an Azure AD admin and consent to the permissions requested for Snowflake's multi-tenant application.
3. **Grant the app access to the container**: in the Azure Portal, go to your storage account (or container) → **Access Control (IAM)** → **Add role assignment** → assign **Storage Blob Data Reader** to the service principal named in `AZURE_MULTI_TENANT_APP_NAME`.
4. Back in Snowflake, run `LIST @snowstage;` to confirm the CSV files are visible through the stage.
5. Run the remaining `COPY INTO` statements in `resources.sql` to load the CSVs into `HOSTS`, `LISTINGS`, and `BOOKINGS`.

### 5. Configure the dbt profile

```bash
cd azure_dbt_snowflake_project
cp ExampleProfiles.yml profiles.yml
# then edit profiles.yml with your Snowflake account, user, and password
```

### 6. Run dbt

```bash
dbt debug
dbt run
dbt test
dbt snapshot
```

## Tech Stack

- **dbt-core** / **dbt-snowflake**
- **Snowflake** as the data warehouse
- **Azure Blob Storage** as the source data landing zone
- **Python 3.12** / **uv** for environment management

---

**Note:** In the age of AI-assisted coding, it's worth stating plainly — every line of code in this project was written by hand by **[Archit Gupta](https://github.com/architg0409)**, with the sole exception of this README file.
