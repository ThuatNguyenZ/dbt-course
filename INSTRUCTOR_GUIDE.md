# 👨‍🏫 Instructor Teaching Guide

## DBT MasterClass - Giảng dạy hướng dẫn

---

## 📋 Buổi 1: Giới thiệu DBT & Modern Data Stack

### Timeline chi tiết (2 tiếng)

#### 0:00 - 0:15 (15 phút): Welcome & Introductions

**Hoạt động:**
- Chào đón học viên
- Giới thiệu bản thân và background
- Mỗi học viên giới thiệu ngắn (tên, current role, kỳ vọng khóa học)

**Talking points:**
```
"Chào mọi người, tôi là [Name]. Tôi đã làm Data Engineering X năm,
từng làm việc với Glue, Airflow, và DBT trong production.

Trong 12 buổi tới, chúng ta sẽ cùng nhau xây dựng một data pipeline
hoàn chỉnh thay thế AWS Glue bằng DBT Core."
```

**Câu hỏi cho học viên:**
- Bạn đang dùng Glue cho use case gì?
- Pain point lớn nhất với Glue là gì?
- Bạn mong đợi gì sau khóa học này?

---

#### 0:15 - 0:45 (30 phút): DBT Concept & Theory

**Slide reference:** Session 1, slides 1-2

**Key concepts cần nhấn mạnh:**

1. **DBT là gì?**
   ```
   "DBT không phải là ETL tool theo nghĩa truyền thống.
   DBT là transformation-as-code cho data warehouse.

   Điểm khác biệt chính:
   - DBT không extract data từ source
   - DBT không load data vào warehouse (warehouse đã có sẵn)
   - DBT chỉ làm chữ T trong ELT: Transform"
   ```

2. **DBT vs Glue - So sánh thực tế:**
   ```
   "Glue = Spark-based, cần viết Python/Scala code
   DBT = SQL-based, ai biết SQL là dùng được

   Glue: write code → compile → test → debug → deploy
   DBT:  write SQL → run → see results ngay

   Đây là lý do tại sao DBT popular: Analytics Engineers
   (thường mạnh SQL, yếu coding) có thể self-serve."
   ```

3. **Cost comparison:**
   ```
   "Glue: $0.44/DPU-hour, 3 hours/day → ~$450/tháng
   DBT on EC2: t3.medium ~$30/tháng + electric

   Tiết kiệm 88%, nhưng quan trọng hơn là:
   - Không vendor lock-in
   - Dễ debug, dễ develop
   - Testing và documentation built-in"
   ```

**Check for understanding (5 phút):**
- Ask: "Ai có thể giải thích lại sự khác biệt chính giữa DBT và Glue?"
- Quick quiz trên slides

---

#### 0:45 - 1:00 (15 phút): Target Architecture Walkthrough

**Slide reference:** Session 1, slide 3

**Architecture deep dive:**
```
"Kiến trúc chúng ta sẽ xây dựng:

API (Shopee/TikTok)
  ↓ Pull Script (Python)
S3 Raw (JSON)
  ↓ DBT External Stage
PostgreSQL Staging
  ↓ DBT Models
PostgreSQL Analytics

Airflow orchestrate toàn bộ pipeline:
- 2am: Pull API data → S3
- 3am: DBT run staging models
- 4am: DBT run intermediate/marts
- 5am: Send Slack notification

Lý do chọn PostgreSQL:
- Học viên đã có RDS
- Phù hợp với dataset vừa và nhỏ (< 100GB)
- SQL dialect gần giống với các DW khác

Future: Có thể migrate lên Redshift/Snowflake
mà không cần rewrite nhiều DBT code."
```

---

#### 1:00 - 1:10 (10 phút): BREAK

---

#### 1:10 - 1:40 (30 phút): Live Demo - Setup DBT

**Slide reference:** Session 1, slide 4

**Demo steps (làm chậm, giải thích từng bước):**

1. **Install DBT Core:**
   ```bash
   python -m venv dbt-venv
   dbt-venv\Scripts\activate  # Windows
   pip install dbt-postgresql
   dbt --version
   ```

2. **Initialize project:**
   ```bash
   dbt init dbt-shopee-tiktok
   # Chọn postgresql
   # Nhập connection details
   ```

3. **Configure profiles.yml:**
   ```bash
   # Show ~/.dbt/profiles.yml
   # Giải thích target dev vs prod
   ```

4. **Test connection:**
   ```bash
   dbt debug
   # Show "All checks passed!" output
   ```

**Tips khi demo:**
- Nói to những gì đang làm
- Giải thích tại sao làm bước này
- Chỉ ra common mistakes:
  ```
  "Lưu ý: profiles.yml KHÔNG được commit vào Git!
  Đây là file chứa credentials, mỗi người có file riêng."
  ```

---

#### 1:40 - 2:00 (20 phút): Q&A + Assignment

**Q&A Preparation:**
Chuẩn bị cho các câu hỏi thường gặp:

1. **"DBT Cloud vs DBT Core - cái nào tốt hơn?"**
   ```
   "DBT Core: Free, self-hosted, nhiều control hơn
   DBT Cloud: $50+/tháng, managed, có UI, easier collaboration

   Khóa học này dùng DBT Core vì:
   - Free, phù hợp học tập
   - Hiểu sâu hơn về internals
   - Sau này lên Cloud dễ dàng"
   ```

2. **"PostgreSQL có thực sự đủ mạnh cho analytics?"**
   ```
   "Cho dataset < 100GB và query không quá complex: YES
   PostgreSQL 14+ với proper indexing khá nhanh.

   Khi scale:
   - 100GB-1TB: Redshift/Snowflake
   - 1TB+: BigQuery/Snowflake

   Điểm hay của DBT:迁移 dễ dàng, chỉ cần change adapter."
   ```

3. **"Learning curve của DBT?"**
   ```
   "Nếu biết SQL: 1-2 tuần để productive
   Phần khó nhất không phải SQL mà là:
   - Hiểu DBT conventions (models, sources, tests)
   - Design data layers đúng cách
   - Writing maintainable macros"
   ```

**Assignment giới thiệu:**
```
"Bài tập về nhà:
1. Cài đặt DBT Core trên máy của bạn
2. Tạo project mới, connect tới PostgreSQL RDS
3. Chạy dbt debug, chụp màn hình 'All checks passed'
4. Chuẩn bị sample data từ Shopee/TikTok API (JSON format)

Deadline: Trước buổi 2. Submit qua GitHub hoặc Slack."
```

---

## 📋 Buổi 2: First Models

### Timeline (2 tiếng)

#### 0:00 - 0:20: Review bài tập + Q&A

**Review points:**
- Check xem học viên có setup thành công không
- Debug common issues (connection errors, permissions)
- Show một số ví dụ tốt từ học viên

#### 0:20 - 0:50: Project Structure Deep Dive

**Teaching approach:**
```
"Tôi sẽ explain từng folder trong DBT project:

models/staging/: Clean data từ raw format
- Column renaming (snake_case)
- Type casting (string → timestamp, numeric)
- Basic filtering (exclude cancelled)

models/intermediate/: Business logic
- Joins giữa các entities
- Deduplication
- Calculations (revenue, margins)

models/marts/: Final output
- Optimized cho querying
- Organized theo business subject
- Documentation đầy đủ"
```

#### 0:50 - 1:20: Live Coding - First Model

**Code cùng học viên:**
```sql
-- models/staging/stg_shopee__orders.sql

{{
    config(
        materialized='view',
        schema='staging'
    )
}}

with source as (
    select * from {{ source('shopee', 'orders_raw') }}
),

renamed as (
    select
        order_id::varchar as order_id,
        buyer_user_id::varchar as customer_id,
        total_amount::numeric as gross_amount,
        order_date::timestamp as order_at
    from source
)

select * from renamed
```

**Giải thích từng concept:**
- `{{ config() }}` - DBT configuration
- `materialized='view'` - Tại sao là view thay vì table?
- `{{ source() }}` - Reference to source tables
- CTE pattern (source → renamed → final)

#### 1:20 - 1:30: BREAK

#### 1:30 - 1:50: Configure Sources + Run

```yaml
# models/staging/schema.yml
version: 2

sources:
  - name: shopee
    schema: raw_data
    tables:
      - name: orders_raw
        columns:
          - name: order_id
            tests:
              - unique
              - not_null
```

```bash
dbt run
dbt test
dbt docs generate
```

#### 1:50 - 2:00: Assignment giới thiệu

```
"Bài tập:
1. Tạo 4 staging models:
   - stg_shopee__orders
   - stg_shopee__products
   - stg_tiktok__orders
   - stg_tiktok__products

2. Configure sources.yml cho cả shopee và tiktok

3. Thêm tests (unique, not_null) cho order_id và product_id

4. Run dbt và chụp màn hình kết quả"
```

---

## 🎯 Teaching Best Practices

### 1. Live Coding Tips

**DO:**
- Code chậm, giải thích từng dòng
- Show errors và cách debug
- Encourage questions trong quá trình demo
- Use split screen: code + slides

**DON'T:**
- Code quá nhanh
- Giấu errors (học viên sẽ gặp!)
- Chỉ nói "nó hoạt động vậy đó"

### 2. Check for Understanding

**Mỗi 15-20 phút, pause và:**
- Ask: "Mọi người có câu hỏi gì không?"
- Quick poll: "Ai đã chạy thành công dbt run?"
- Call on specific học viên (gentle): "[Name], bạn thấy sao?"

### 3. Handle Different Skill Levels

**Cho học viên yếu hơn:**
- Provide code snippets ready-to-use
- Pair với học viên mạnh hơn
- Extra office hours

**Cho học viên mạnh hơn:**
- Challenge questions: "Tại sao dùng view thay vì table?"
- Advanced exercises: "Try implementing this với incremental"
- Help teaching others (peer learning)

### 4. Common Student Issues

| Issue | Solution |
|-------|----------|
| Connection refused | Check security group, public access |
| Permission denied | Check IAM role, database grants |
| Model not found | Check file location, ref() syntax |
| Tests failing | Check data quality, type casting |

---

## 📊 Assessment Rubric

### Homework Grading (10 points each)

| Criteria | 9-10 (Excellent) | 7-8 (Good) | 5-6 (Fair) | <5 (Poor) |
|----------|------------------|------------|------------|-----------|
| Completeness | All requirements met | Minor issues missing | Several issues | Incomplete |
| Code Quality | Clean, well-organized | Minor style issues | Messy but works | Broken code |
| Understanding | Can explain everything | Minor gaps | Significant gaps | No understanding |

### Final Project (100 points)

| Component | Points |
|-----------|--------|
| Pipeline completeness | 30 |
| Testing coverage | 20 |
| Documentation | 15 |
| Performance | 15 |
| Presentation | 20 |

---

## 🔧 Troubleshooting Guide

### Setup Issues

**Problem:** `dbt: command not found`
```bash
# Check if venv is activated
which python  # Should point to venv
pip list | grep dbt  # Should show dbt-core, dbt-postgresql
```

**Problem:** Connection timeout
```bash
# Check RDS security group
# Inbound: Port 5432 from your IP
# Check public accessibility setting
```

### Runtime Issues

**Problem:** Model not found
```
Error: Model 'model.my_project.stg_orders' not found!

Solution:
1. Check file is in models/ folder
2. Check file name matches model name
3. Run dbt clean && dbt deps
```

**Problem:** Compilation error
```
Error: Compilation Error in model stg_orders
  syntax error at or near "select"

Solution:
1. Check Jinja syntax {{ }}
2. Check SQL syntax
3. Run dbt debug
```

---

## 📞 Contact & Support

**Office Hours:** Tuesday & Thursday 2-4 PM
**Slack:** #dbt-masterclass
**Email:** [instructor@email.com]

**Response Time:**
- Slack: Within 4 hours during business hours
- Email: Within 24 hours
- Urgent issues: Call/SMS
