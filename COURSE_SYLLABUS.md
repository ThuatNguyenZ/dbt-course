# 🎓 DBT MasterClass - Course Syllabus

## Tổng quan khóa học
- **Thời lượng:** 12 buổi × 2 giờ = 24 giờ
- **Đối tượng:** Data Engineers có background AWS (Glue, S3, EC2, RDS)
- **Mục tiêu:** Thay thế AWS Glue bằng DBT Core + Airflow
- **Stack:** S3 → DBT → PostgreSQL + Airflow

---

## 📅 Lộ trình chi tiết

### Phần 1: DBT Core Fundamentals (Buổi 1-6)

#### Buổi 1: Giới thiệu DBT & Modern Data Stack
**Nội dung chính:**
- DBT là gì? Tại sao DBT?
- So sánh DBT vs AWS Glue
- Target architecture: S3 → DBT → PostgreSQL
- Setup environment và kết nối PostgreSQL

**Hands-on:**
- Cài đặt DBT Core
- Tạo project đầu tiên
- Test connection với `dbt debug`

**Bài tập:** Setup hoàn chỉnh môi trường DBT

---

#### Buổi 2: DBT Core Setup & First Models
**Nội dung chính:**
- DBT project structure
- Data layers: Raw → Staging → Intermediate → Marts
- Tạo first staging models
- Sources configuration

**Hands-on:**
- Tạo staging models cho Shopee/TikTok data
- Configure sources.yml
- Chạy `dbt run` và `dbt test`

**Bài tập:** Tạo 4 staging models (shopee orders, products + tiktok orders, products)

---

#### Buổi 3: Building Intermediate Models
**Nội dung chính:**
- Intermediate layer purpose
- Joins và business logic
- Data deduplication strategies
- Handling slowly changing data

**Hands-on:**
- Tạo int_orders__deduped.sql
- Tạo int_orders__enriched.sql (join với customers)
- Tạo int_revenue__daily.sql

**Bài tập:** Xây dựng intermediate layer hoàn chỉnh

---

#### Buổi 4: Data Testing với DBT
**Nội dung chính:**
- Built-in tests (unique, not_null, foreign_key, accepted_values)
- Custom SQL tests
- Severity levels (warn vs error)
- Testing best practices

**Hands-on:**
- Thêm tests vào staging models
- Viết custom test cho business logic
- Chạy `dbt test` và debug failures

**Bài tập:** Viết 10+ tests cho toàn bộ pipeline

---

#### Buổi 5: Documentation & Data Discovery
**Nội dung chính:**
- Auto-generated documentation
- Writing descriptions in YAML
- dbt docs generate & serve
- Documentation best practices

**Hands-on:**
- Add descriptions cho models, columns, sources
- Generate documentation
- Host docs trên S3 hoặc local server

**Bài tập:** Complete documentation cho toàn bộ project

---

#### Buổi 6: Macros - Reusable SQL
**Nội dung chính:**
- Macro syntax và structure
- Jinja templating basics
- Common macro patterns
- Debugging macros

**Hands-on:**
- Tạo macro truncate_timestamp()
- Tạo macro calculate_vat()
- Tạo macro generate_date_range()

**Bài tập:** Viết 5+ macros hữu ích cho project

---

### Phần 2: Advanced DBT (Buổi 7-9)

#### Buổi 7: DBT Packages & Code Reuse
**Nội dung chính:**
- DBT packages ecosystem
- Installing và using packages
- Popular packages (dbt_utils, dbt_date)
- Creating custom packages

**Hands-on:**
- Install dbt_utils package
- Sử dụng dbt_utils functions
- Reference custom macros trong models

**Bài tập:** Refactor code sử dụng dbt_utils

---

#### Buổi 8: Incremental Models & Performance
**Nội dung chính:**
- Incremental vs full-refresh
- Incremental strategies (append, delete+insert, merge)
- Configuring incremental models
- Performance optimization

**Hands-on:**
- Convert daily sales model to incremental
- Configure incremental_strategy
- Test với large dataset

**Bài tập:** Implement incremental loading cho orders table

---

#### Buổi 9: Snapshots & Slowly Changing Data
**Nội dung chính:**
- What are snapshots?
- SCD Type 1 vs Type 2
- Snapshot configuration
- Use cases và best practices

**Hands-on:**
- Tạo snapshot cho products table
- Track price changes over time
- Query snapshot data

**Bài tập:** Implement snapshots cho products và customers

---

### Phần 3: Production Deployment (Buổi 10-12)

#### Buổi 10: Airflow Integration
**Nội dung chính:**
- Airflow architecture overview
- DBT Operator và DBT Cloud Hook
- Creating DBT DAGs
- Handling dependencies và alerts

**Hands-on:**
- Install Airflow trên EC2
- Configure DBT Operator
- Tạo DAG cho daily pipeline

**Bài tập:** Tạo complete DAG với alerts

---

#### Buổi 11: Production Deployment trên EC2
**Nội dung chính:**
- EC2 setup và security
- Docker containerization cho DBT
- CI/CD với GitHub Actions
- Monitoring và logging

**Hands-on:**
- Tạo Dockerfile cho DBT
- Deploy lên EC2
- Setup CloudWatch logging

**Bài tập:** Deploy production-ready pipeline

---

#### Buổi 12: Near-Real-Time Architecture Design
**Nội dung chính:**
- Batch vs streaming considerations
- Designing for near-real-time
- Cost-performance tradeoffs
- Migration strategy từ batch

**Hands-on:**
- Design architecture cho hourly pipelines
- Discuss options: Kinesis → Lambda → DBT
- Planning migration path

**Final Project:** Present end-to-end pipeline design

---

## 📚 Tài nguyên học tập

### Required Reading
- [DBT Documentation](https://docs.getdbt.com/)
- [DBT Guide](https://dbt-guide.com/)
- [Airflow Documentation](https://airflow.apache.org/docs/)

### Sample Datasets
- Shopee API sample data (JSON)
- TikTokShop API sample data (JSON)
- Exchange rates CSV

### Tools & Software
- DBT Core (v1.6+)
- PostgreSQL 14+
- Airflow 2.7+
- Docker Desktop
- VS Code với DBT extension

---

## 🎯 Đánh giá và Certification

### Requirements để hoàn thành
- ✓ Attendance: 10/12 buổi minimum
- ✓ Homework: 8/10 assignments submitted
- ✓ Final project: End-to-end pipeline

### Certification levels
- **Completion:** Đạt requirements cơ bản
- **Proficiency:** Hoàn thành final project với good practices
- **Excellence:** Outstanding work + shareable portfolio

---

## 📞 Contact & Support

- **Instructor:** [Your name]
- **Email:** [Your email]
- **Slack Channel:** #dbt-masterclass
- **Office Hours:** Tuesday & Thursday 2-4 PM
