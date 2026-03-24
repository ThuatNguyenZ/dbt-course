# DBT Course - Exercise Solutions

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
# Expected: dbt-core=1.6.x, dbt-postgresql=1.6.x
```

### Exercise 1.2: Test Connection
```bash
cd dbt-shopee-tiktok
dbt debug

# Expected Output:
# All checks passed!
```

---

## Buổi 2: First Models

### Exercise 2.1: Staging Model Solution

**File:** `models/staging/stg_shopee__orders.sql`

```sql
{{
    config(
        materialized='view',
        schema='staging',
        tags=['shopee', 'orders', 'staging']
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

### Exercise 2.2: Sources Configuration

**File:** `models/staging/schema.yml`

```yaml
version: 2

sources:
  - name: shopee
    description: "Raw data từ Shopee Open Platform API"
    schema: raw_data
    loaded_at_field: _loaded_at
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
                  quote_values: true
      - name: products_raw
        description: "Products raw data from Shopee API"
        columns:
          - name: product_id
            description: "Unique product identifier"
            tests:
              - unique
              - not_null

  - name: tiktok
    description: "Raw data từ TikTokShop Open Platform"
    schema: raw_data
    loaded_at_field: _loaded_at
    tables:
      - name: orders_raw
        description: "Orders raw data from TikTokShop API"
        columns:
          - name: order_id
            description: "Unique order identifier"
            tests:
              - unique
              - not_null
      - name: products_raw
        description: "Products raw data from TikTokShop API"
        columns:
          - name: product_id
            description: "Unique product identifier"
            tests:
              - unique
              - not_null
```

---

## Buổi 3: Intermediate Models

### Exercise 3.1: Deduplication Solution

**File:** `models/intermediate/int_orders__deduped.sql`

```sql
{{
    config(
        materialized='table',
        schema='intermediate',
        tags=['orders', 'intermediate', 'dedup']
    )
}}

with source as (
    -- Union all sources
    select *, 'shopee' as source from {{ ref('stg_shopee__orders') }}
    union all
    select *, 'tiktok' as source from {{ ref('stg_tiktok__orders') }}
),

ranked as (
    select
        *,
        row_number() over (
            partition by order_id
            order by loaded_at desc, _dbt_loaded_at desc
        ) as rn
    from source
)

select
    order_id,
    customer_id,
    seller_id,
    source,
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
from ranked
where rn = 1
```

### Exercise 3.2: Daily Revenue Solution

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

daily_metrics as (
    select
        date_trunc('day', order_at::timestamp)::date as order_date,
        source,

        -- Volume metrics
        count(distinct order_id) as order_count,
        count(distinct customer_id) as unique_customers,

        -- Revenue metrics
        sum(gross_amount) as gross_revenue,
        sum(discount) as total_discounts,
        sum(shipping_fee) as total_shipping,
        sum(gross_amount - discount) as net_revenue,

        -- Derived metrics
        avg(gross_amount) as avg_order_value,
        sum(gross_amount) / nullif(count(distinct customer_id), 0) as revenue_per_customer

    from orders
    where status not in ('CANCELLED', 'RETURNED')
    group by 1, 2
)

select * from daily_metrics
order by order_date desc, source
```

### Exercise 3.3: Monthly Rollup with MoM Growth

**File:** `models/intermediate/int_revenue__monthly.sql`

```sql
{{
    config(
        materialized='table',
        schema='intermediate',
        tags=['revenue', 'monthly']
    )
}}

with daily as (
    select * from {{ ref('int_revenue__daily') }}
),

monthly as (
    select
        date_trunc('month', order_date::timestamp)::date as month_date,
        source,

        -- Volume metrics
        sum(order_count) as total_orders,
        sum(unique_customers) as monthly_active_customers,

        -- Revenue metrics
        sum(gross_revenue) as gross_revenue,
        sum(total_discounts) as total_discounts,
        sum(net_revenue) as net_revenue,

        -- Derived metrics
        avg(avg_order_value) as avg_order_value

    from daily
    group by 1, 2
),

with_mom as (
    select
        *,
        lag(net_revenue) over (
            partition by source
            order by month_date
        ) as prev_month_revenue,

        -- Month over Month growth
        case
            when lag(net_revenue) over (
                partition by source
                order by month_date
            ) > 0
            then round(
                ((net_revenue - lag(net_revenue) over (
                    partition by source
                    order by month_date
                )) / lag(net_revenue) over (
                    partition by source
                    order by month_date
                )) * 100,
                2
            )
            else null
        end as mom_growth_pct

    from monthly
)

select * from with_mom
order by month_date desc, source
```

---

## Buổi 4: Data Testing

### Exercise 4.1: Tests Configuration

**File:** `models/intermediate/schema.yml`

```yaml
version: 2

models:
  - name: int_orders__deduped
    description: "Deduplicated orders from all sources (Shopee + TikTok)"
    columns:
      - name: order_id
        description: "Unique order identifier"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error

      - name: customer_id
        description: "Customer identifier"
        tests:
          - not_null:
              severity: error
          - relationships:
              to: ref('stg_shopee__customers')
              field: customer_id
              severity: warn

      - name: gross_amount
        description: "Gross order amount"
        tests:
          - not_null:
              severity: error

      - name: status
        description: "Order status"
        tests:
          - accepted_values:
              values: ['PENDING', 'PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'RETURNED']
              severity: warn

      - name: order_at
        description: "Order timestamp"
        tests:
          - not_null:
              severity: error

  - name: int_revenue__daily
    description: "Daily revenue metrics by source"
    columns:
      - name: order_date
        description: "Date of orders"
        tests:
          - unique:
              severity: error
          - not_null:
              severity: error

      - name: order_count
        tests:
          - not_null:
              severity: error

      - name: net_revenue
        tests:
          - not_null:
              severity: error
```

### Exercise 4.2: Custom Tests Solutions

**File:** `tests/assert_positive_revenue.sql`

```sql
-- Test that daily revenue is never negative
select
    order_date,
    net_revenue
from {{ ref('int_revenue__daily') }}
where net_revenue < 0
```

**File:** `tests/assert_order_date_not_future.sql`

```sql
-- Test that order dates are not in the future
select
    order_id,
    order_at
from {{ ref('int_orders__deduped') }}
where order_at > now()
```

**File:** `tests/assert_discount_valid.sql`

```sql
-- Test that discount does not exceed gross amount
select
    order_id,
    gross_amount,
    discount
from {{ ref('int_orders__deduped') }}
where discount > gross_amount
```

**File:** `tests/assert_valid_order_status.sql`

```sql
-- Test that all order statuses are valid
select
    order_id,
    status
from {{ ref('int_orders__deduped') }}
where status not in ('PENDING', 'PAID', 'SHIPPED', 'DELIVERED', 'CANCELLED', 'RETURNED')
```

---

## Buổi 5: Documentation

### Exercise 5.1: Complete Documentation

**File:** `models/marts/schema.yml`

```yaml
version: 2

models:
  - name: fct_daily_sales
    description: |
      Fact table containing daily sales metrics aggregated from all sources.

      This table is the primary source for:
      - Daily revenue reporting
      - Trend analysis
      - Dashboard visualizations

      **Grain:** One row per day per source

      **Source Systems:** Shopee, TikTokShop

      **Update Frequency:** Daily at 3:00 AM UTC

    columns:
      - name: order_date
        description: "Date of the sales record"
        tests:
          - unique
          - not_null

      - name: source
        description: "Data source platform (shopee or tiktok)"
        tests:
          - accepted_values:
              values: ['shopee', 'tiktok']

      - name: order_count
        description: "Total number of orders placed on this date"
        tests:
          - not_null

      - name: unique_customers
        description: "Count of distinct customers who placed orders"

      - name: gross_revenue
        description: "Total revenue before discounts and shipping"
        tests:
          - not_null

      - name: net_revenue
        description: "Revenue after discounts, excluding shipping fees"

      - name: avg_order_value
        description: "Average order value (gross_revenue / order_count)"

  - name: fct_monthly_revenue
    description: |
      Monthly revenue rollup with month-over-month growth calculations.

      **Grain:** One row per month per source

    columns:
      - name: month_date
        description: "First day of the month"
        tests:
          - unique
          - not_null

      - name: mom_growth_pct
        description: "Month-over-month revenue growth percentage"
```

---

## Buổi 6: Macros

### Exercise 6.1: Date Truncation Macro

**File:** `macros/truncate_date.sql`

```sql
{% macro truncate_date(date_column, date_part) %}
    {{ return(adapter.dispatch('truncate_date', 'dbt_shopee_tiktok')(date_column, date_part)) }}
{% endmacro %}

{% macro default__truncate_date(date_column, date_part) %}
    date_trunc('{{ date_part }}', {{ date_column }}::timestamp)::timestamp
{% endmacro %}

{% macro postgres__truncate_date(date_column, date_part) %}
    date_trunc('{{ date_part }}', {{ date_column }}::timestamp)::timestamp
{% endmacro %}
```

### Exercise 6.2: VAT Calculation Macro

**File:** `macros/calculate_vat.sql`

```sql
{% macro calculate_vat(amount, vat_rate=0.10) %}
    round({{ amount }}::numeric * {{ vat_rate }}, 0)
{% endmacro %}

{% macro calculate_net_amount(gross_amount, discount, vat_rate=0.10) %}
    ({{ gross_amount }} - {{ discount }}) * (1 + {{ vat_rate }})
{% endmacro %}
```

### Exercise 6.3: Generate Date Range Macro

**File:** `macros/generate_date_range.sql`

```sql
{% macro generate_date_range(start_date, end_date, date_part='day') %}
    {{ return(adapter.dispatch('generate_date_range', 'dbt_shopee_tiktok')(start_date, end_date, date_part)) }}
{% endmacro %}

{% macro default__generate_date_range(start_date, end_date, date_part) %}
    generate_series(
        '{{ start_date }}'::date,
        '{{ end_date }}'::date,
        interval '1 {{ date_part }}'
    )::date as date
{% endmacro %}
```

### Exercise 6.4: Using Macros in Models

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
        source,
        count(*) as order_count,
        sum(gross_amount) as gross_revenue,
        sum(discount) as total_discounts,
        sum({{ calculate_vat('gross_amount - discount', 0.10) }}) as vat_amount,
        sum(gross_amount - discount) as net_revenue,
        count(distinct customer_id) as unique_customers
    from {{ ref('int_orders__deduped') }}
    where status not in ('CANCELLED', 'RETURNED')
    group by 1, 2
)

select * from daily_orders
order by order_date desc, source
```

---

## Buổi 7-9: Advanced Exercises

### Exercise 8.1: Incremental Model Solution

**File:** `models/marts/fct_daily_sales_incremental.sql`

```sql
{{
    config(
        materialized='incremental',
        schema='marts',
        unique_key='order_date_source',
        incremental_strategy='merge',
        tags=['sales', 'incremental']
    )
}}

with daily_orders as (
    select
        {{ truncate_date('order_at', 'day') }}::date as order_date,
        source,
        count(*) as order_count,
        sum(gross_amount) as gross_revenue,
        sum(discount) as total_discounts,
        sum(gross_amount - discount) as net_revenue,
        count(distinct customer_id) as unique_customers
    from {{ ref('int_orders__deduped') }}
    {% if is_incremental() %}
        -- Only process new/updated data
        where order_at >= (
            select max(order_date) - interval '7 days'
            from {{ this }}
        )
    {% endif %}
    group by 1, 2
),

deduplicated as (
    select
        *,
        row_number() over (
            partition by order_date, source
            order by _dbt_loaded_at desc
        ) as rn
    from daily_orders
)

select
    order_date,
    source,
    order_count,
    gross_revenue,
    total_discounts,
    net_revenue,
    unique_customers,
    concat(order_date::varchar, '_', source) as order_date_source
from deduplicated
where rn = 1
```

### Exercise 9.1: Product Snapshot Solution

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
        invalidate_hard_deletes=true,
    )
}}

select * from {{ ref('stg_shopee__products') }}

{% endsnapshot %}
```

### Exercise 9.2: Query Snapshot Data

```sql
-- Query current state of products
select
    product_id,
    product_name,
    price,
    stock,
    dbt_valid_from,
    dbt_valid_to,
    dbt_is_deleted
from {{ ref('snapshot_products') }}
where dbt_valid_to is null
order by product_id;

-- Query historical price changes for a product
select
    price,
    dbt_valid_from,
    dbt_valid_to,
    dbt_valid_to - dbt_valid_from as price_duration
from {{ ref('snapshot_products') }}
where product_id = 'SP001'
order by dbt_valid_from desc;
```

---

## Buổi 10-12: Production Exercises

### Exercise 10.1: Airflow DAG Solution

**File:** `dags/dbt_daily_pipeline.py`

```python
from airflow import DAG
from airflow.providers.dbt.cloud.operators.dbt import DbtCloudRunJobOperator
from airflow.operators.bash import BashOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'data_team',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'email_on_failure': True,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=15),
    'email': ['data-alerts@company.com'],
}

with DAG(
    'dbt_daily_pipeline',
    default_args=default_args,
    description='Daily DBT pipeline for ecommerce data',
    schedule_interval='0 2 * * *',  # Run at 2 AM daily
    catchup=False,
    max_active_runs=1,
    tags=['dbt', 'ecommerce', 'daily'],
) as dag:

    # Task 1: Check S3 data availability
    check_s3_data = BashOperator(
        task_id='check_s3_data',
        bash_command='aws s3 ls s3://your-bucket/raw/{{ ds }}/ || exit 1',
    )

    # Task 2: Run DBT models
    run_dbt = DbtCloudRunJobOperator(
        task_id='run_dbt_models',
        dbt_cloud_conn_id='dbt_cloud',
        job_id=12345,
        timeout=3600,
        check_interval=30,
    )

    # Task 3: Run DBT tests
    test_dbt = DbtCloudRunJobOperator(
        task_id='test_dbt_models',
        dbt_cloud_conn_id='dbt_cloud',
        job_id=12346,
        timeout=1800,
    )

    # Task 4: Send notification
    send_notification = BashOperator(
        task_id='send_slack_notification',
        bash_command='curl -X POST -H "Content-type: application/json" --data "{\"text\":\"DBT pipeline completed successfully\"}" $SLACK_WEBHOOK_URL',
    )

    check_s3_data >> run_dbt >> test_dbt >> send_notification
```

### Exercise 11.1: Dockerfile Solution

**File:** `Dockerfile`

```dockerfile
FROM python:3.11-slim

WORKDIR /dbt

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    make \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy DBT project
COPY . .

# Set environment variables
ENV DBT_PROFILES_DIR=/dbt/profiles
ENV PYTHONPATH=/dbt

# Create non-root user
RUN useradd -m dbt_user
USER dbt_user

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD dbt debug || exit 1

# Default command
ENTRYPOINT ["dbt"]
CMD ["run"]
```

### Exercise 11.2: Docker Compose Solution

**File:** `docker-compose.yml`

```yaml
version: '3.8'

services:
  dbt:
    build: .
    volumes:
      - ./profiles:/dbt/profiles:ro
      - ./logs:/dbt/logs
    environment:
      - DBT_PROFILES_DIR=/dbt/profiles
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
    networks:
      - dbt_network
    deploy:
      resources:
        limits:
          cpus: '2'
          memory: 4G

networks:
  dbt_network:
    driver: bridge
```

---

## Testing Your Solutions

### Run All Tests
```bash
# Run models
dbt run

# Run tests
dbt test

# Run specific model tests
dbt test --models int_orders__deduped

# Run with verbose output
dbt test --output verbose
```

### Generate Documentation
```bash
dbt docs generate
dbt docs serve --port 8080
```

### Build and Run Docker
```bash
docker build -t dbt-shopee-tiktok .
docker run --rm dbt-shopee-tiktok dbt run
```
