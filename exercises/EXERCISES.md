# 📝 DBT MasterClass - Exercises & Solutions

## Buổi 1: Introduction to DBT

### Exercise 1.1: Install DBT Core
```bash
# Tạo virtual environment
python -m venv dbt-venv

# Activate
# Windows:
dbt-venv\Scripts\activate
# Linux/Mac:
source dbt-venv/bin/activate

# Install DBT với PostgreSQL adapter
pip install dbt-postgresql

# Verify installation
dbt --version
```

### Exercise 1.2: Initialize Project
```bash
dbt init dbt-shopee-tiktok
# Chọn adapter: postgresql
# Nhập connection details
```

### Exercise 1.3: Test Connection
```bash
cd dbt-shopee-tiktok
dbt debug
```

**Expected Output:**
```
All checks passed!
```

---

## Buổi 2: First Models

### Exercise 2.1: Tạo Staging Model

**File:** `models/staging/stg_shopee__orders.sql`

```sql
{{
    config(
        materialized='view',
        schema='staging',
        tags=['shopee', 'orders']
    )
}}

with source as (
    select * from {{ source('shopee', 'orders_raw') }}
),

renamed as (
    select
        -- Identifiers
        order_id::varchar as order_id,
        buyer_user_id::varchar as customer_id,
        seller_user_id::varchar as seller_id,

        -- Timestamps
        order_date::timestamp as order_at,
        paid_date::timestamp as paid_at,
        shipped_date::timestamp as shipped_at,
        completed_date::timestamp as completed_at,

        -- Amounts
        total_amount::numeric as gross_amount,
        discount_amount::numeric as discount,
        shipping_fee::numeric as shipping_fee,
        voucher_amount::numeric as voucher_discount,

        -- Status
        order_status as status,
        payment_method as payment_type,

        -- Metadata
        _loaded_at as loaded_at
    from source
)

select * from renamed
```

### Exercise 2.2: Configure Sources

**File:** `models/staging/schema.yml`

```yaml
version: 2

sources:
  - name: shopee
    description: "Raw data từ Shopee Open Platform API"
    schema: raw_data
    tables:
      - name: orders_raw
        description: "Orders raw data from Shopee API"
        columns:
          - name: order_id
            description: "Unique order identifier"
            tests:
              - unique
              - not_null
          - name: total_amount
            description: "Total order amount including shipping and discounts"
            tests:
              - not_null
          - name: order_status
            description: "Current order status"
            tests:
              - accepted_values:
                  values: ['PENDING', 'PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED']
      - name: products_raw
        description: "Products raw data from Shopee API"

  - name: tiktok
    description: "Raw data từ TikTokShop Open Platform"
    schema: raw_data
    tables:
      - name: orders_raw
        description: "Orders raw data from TikTokShop API"
      - name: products_raw
        description: "Products raw data from TikTokShop API"
```

### Exercise 2.3: Run Models

```bash
# Run staging models
dbt run --models staging.*

# Run tests
dbt test

# View results
dbt docs generate
dbt docs serve
```

---

## Buổi 3: Intermediate Models

### Exercise 3.1: Orders Deduplication

**File:** `models/intermediate/int_orders__deduped.sql`

```sql
{{
    config(
        materialized='table',
        schema='intermediate',
        tags=['orders', 'intermediate']
    )
}}

with orders as (
    select * from {{ ref('stg_shopee__orders') }}
    union all
    select * from {{ ref('stg_tiktok__orders') }}
),

deduped as (
    select
        *,
        row_number() over (
            partition by order_id
            order by loaded_at desc
        ) as rn
    from orders
)

select
    order_id,
    customer_id,
    seller_id,
    order_at,
    paid_at,
    shipped_at,
    completed_at,
    gross_amount,
    discount,
    shipping_fee,
    voucher_discount,
    status,
    payment_type,
    loaded_at
from deduped
where rn = 1
```

### Exercise 3.2: Daily Revenue

**File:** `models/intermediate/int_revenue__daily.sql`

```sql
{{
    config(
        materialized='table',
        schema='intermediate',
        tags=['revenue', 'daily']
    )
}}

with orders as (
    select * from {{ ref('int_orders__deduped') }}
),

daily_revenue as (
    select
        date(order_at) as order_date,
        count(distinct order_id) as order_count,
        count(distinct customer_id) as unique_customers,
        sum(gross_amount) as total_revenue,
        sum(discount) as total_discount,
        sum(shipping_fee) as total_shipping,
        avg(gross_amount) as avg_order_value
    from orders
    where status not in ('CANCELLED', 'RETURNED')
    group by date(order_at)
)

select * from daily_revenue
order by order_date desc
```

---

## Buổi 4: Data Testing

### Exercise 4.1: Add Tests to Models

**File:** `models/intermediate/schema.yml`

```yaml
version: 2

models:
  - name: int_orders__deduped
    description: "Deduplicated orders from all sources"
    columns:
      - name: order_id
        description: "Unique order identifier"
        tests:
          - unique
          - not_null
      - name: customer_id
        description: "Customer identifier"
        tests:
          - not_null
      - name: gross_amount
        description: "Gross order amount"
        tests:
          - not_null
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: order_at
        description: "Order timestamp"
        tests:
          - not_null

  - name: int_revenue__daily
    description: "Daily revenue metrics"
    columns:
      - name: order_date
        description: "Date of orders"
        tests:
          - unique
          - not_null
      - name: order_count
        tests:
          - dbt_utils.expression_is_true:
              expression: ">= 0"
      - name: total_revenue
        tests:
          - dbt_utils.expression_is_true:
              expression: ">= 0"
```

### Exercise 4.2: Custom SQL Test

**File:** `tests/assert_positive_revenue.sql`

```sql
-- Test that daily revenue is never negative
select
    order_date,
    total_revenue
from {{ ref('int_revenue__daily') }}
where total_revenue < 0
```

### Exercise 4.3: Run Tests

```bash
# Run all tests
dbt test

# Run specific model tests
dbt test --models int_orders__deduped

# Run with verbose output
dbt test --output verbose
```

---

## Buổi 5: Documentation

### Exercise 5.1: Add Model Descriptions

**File:** `models/marts/schema.yml`

```yaml
version: 2

models:
  - name: fct_daily_sales
    description: |
      Fact table containing daily sales metrics.

      This table aggregates order data from all sources (Shopee, TikTokShop)
      and provides daily-level metrics for reporting and analytics.

      **Grain:** One row per day

      **Columns:**
      - order_date: The date of orders
      - order_count: Total number of orders
      - revenue: Total revenue after discounts
      - unique_customers: Number of unique customers

    columns:
      - name: order_date
        description: "Date of the sales record"
      - name: order_count
        description: "Total number of orders placed on this date"
      - name: revenue
        description: "Net revenue after discounts and before shipping"
      - name: unique_customers
        description: "Count of distinct customers who placed orders"
```

### Exercise 5.2: Generate Docs

```bash
# Generate documentation
dbt docs generate

# Serve locally
dbt docs serve --port 8080

# Copy docs to S3 (optional)
aws s3 sync target/ s3://your-bucket/dbt-docs/
```

---

## Buổi 6: Macros

### Exercise 6.1: Date Truncation Macro

**File:** `macros/truncate_date.sql`

```sql
{% macro truncate_date(date_column, date_part) %}
    date_trunc('{{ date_part }}', {{ date_column }}::timestamp)
{% endmacro %}
```

### Exercise 6.2: VAT Calculation Macro

**File:** `macros/calculate_vat.sql`

```sql
{% macro calculate_vat(amount, vat_rate=0.10) %}
    round({{ amount }}::numeric * {{ vat_rate }}, 0)
{% endmacro %}
```

### Exercise 6.3: Using Macros in Models

**File:** `models/marts/fct_daily_sales.sql`

```sql
{{
    config(
        materialized='table',
        schema='marts',
        tags=['sales', 'daily']
    )
}}

with daily_orders as (
    select
        {{ truncate_date('order_at', 'day') }}::date as order_date,
        count(*) as order_count,
        sum(gross_amount) as gross_revenue,
        sum({{ calculate_vat('gross_amount', 0.10) }}) as vat_amount,
        sum(gross_amount - discount) as net_revenue,
        count(distinct customer_id) as unique_customers
    from {{ ref('int_orders__deduped') }}
    where status not in ('CANCELLED', 'RETURNED')
    group by 1
)

select * from daily_orders
```

---

## Buổi 7-9: Advanced Exercises

### Exercise 8.1: Incremental Model

**File:** `models/marts/fct_daily_sales_incremental.sql`

```sql
{{
    config(
        materialized='incremental',
        schema='marts',
        unique_key='order_date',
        incremental_strategy='merge',
        tags=['sales', 'incremental']
    )
}}

with daily_orders as (
    select
        {{ truncate_date('order_at', 'day') }}::date as order_date,
        count(*) as order_count,
        sum(gross_amount) as gross_revenue,
        sum(gross_amount - discount) as net_revenue,
        count(distinct customer_id) as unique_customers
    from {{ ref('int_orders__deduped') }}
    where status not in ('CANCELLED', 'RETURNED')
    {% if is_incremental() %}
        and order_at >= (select max(order_date) from {{ this }})
    {% endif %}
    group by 1
)

select * from daily_orders
```

### Exercise 9.1: Product Snapshot

**File:** `snapshots/snapshot_products.sql`

```sql
{% snapshot snapshot_products %}

{{
    config(
        target_database='analytics',
        target_schema='snapshots',
        unique_key='product_id',
        strategy='timestamp',
        updated_at='updated_at',
    )
}}

select * from {{ ref('stg_shopee__products') }}

{% endsnapshot %}
```

---

## Buổi 10-12: Production Exercises

### Exercise 10.1: Airflow DAG

**File:** `dags/dbt_daily_pipeline.py`

```python
from airflow import DAG
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

with DAG(
    'dbt_daily_pipeline',
    default_args=default_args,
    description='Daily DBT pipeline for ecommerce data',
    schedule_interval='0 2 * * *',
    catchup=False,
) as dag:

    run_dbt = DbtCloudRunJobOperator(
        task_id='run_dbt_models',
        dbt_cloud_conn_id='dbt_cloud',
        job_id=12345,
        timeout=3600,
    )

    run_dbt
```

### Exercise 11.1: Dockerfile

**File:** `Dockerfile`

```dockerfile
FROM python:3.11-slim

WORKDIR /dbt

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy project
COPY . .

# Set DBT environment
ENV DBT_PROFILES_DIR=/dbt/profiles

# Run command
ENTRYPOINT ["dbt"]
CMD ["run"]
```

---

## 📋 Solution Checklist

### Buổi 1-6 Checklist
- [ ] DBT Core installed và working
- [ ] Project initialized với correct structure
- [ ] 4 staging models created
- [ ] Sources configured
- [ ] Tests added (10+ total)
- [ ] Documentation complete
- [ ] 5+ macros created

### Buổi 7-9 Checklist
- [ ] dbt_utils package installed
- [ ] Incremental model implemented
- [ ] Snapshot configured
- [ ] Performance optimized

### Buổi 10-12 Checklist
- [ ] Airflow DAG created
- [ ] Docker container built
- [ ] Deployed to EC2
- [ ] Monitoring configured
- [ ] Final project submitted
