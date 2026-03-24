# DBT Course - Deployment Guide

## Production Deployment trên EC2

### 1. EC2 Setup

#### Launch EC2 Instance
```bash
# AWS Console hoặc CLI
aws ec2 run-instances \
    --image-id ami-0c55b159cbfafe1f0 \
    --instance-type t3.medium \
    --key-name your-key-pair \
    --security-group-ids sg-your-sg \
    --iam-instance-profile Name=YourIAMProfile \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=dbt-runner}]'
```

#### Security Group Rules
```
Inbound Rules:
- SSH (22) from Your IP
- Custom TCP (8080) from Your IP (for DBT docs)

Outbound Rules:
- All traffic allowed
```

### 2. Install Dependencies

```bash
# SSH vào EC2
ssh -i your-key.pem ec2-user@your-ec2-ip

# Update system
sudo yum update -y

# Install Python 3.11
sudo yum install -y python3.11 python3.11-pip python3.11-venv

# Install Docker
sudo yum install -y docker
sudo service docker start
sudo usermod -aG docker ec2-user

# Install Git
sudo yum install -y git

# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```

### 3. Setup DBT Project

```bash
# Clone repository
git clone https://github.com/your-org/dbt-shopee-tiktok.git
cd dbt-shopee-tiktok

# Create virtual environment
python3.11 -m venv dbt-venv
source dbt-venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Create profiles directory
mkdir -p ~/.dbt

# Create profiles.yml
cat > ~/.dbt/profiles.yml << EOF
dbt_shopee_tiktok:
  outputs:
    prod:
      type: postgres
      host: your-rds-endpoint.rds.amazonaws.com
      port: 5432
      user: dbt_prod_user
      password: \${DBT_PASSWORD}
      dbname: analytics
      schema: analytics
      threads: 8
      keepalives_idle: 0
      connect_timeout: 10
  target: prod
EOF

# Test connection
dbt debug
```

### 4. Setup Airflow

#### Install Airflow
```bash
# Install Airflow
pip install "apache-airflow[postgres]==2.7.0"

# Initialize Airflow database
export AIRFLOW_HOME=~/airflow
airflow db init

# Create admin user
airflow users create \
    --username admin \
    --firstname Data \
    --lastname Admin \
    --role Admin \
    --email admin@company.com
```

#### Configure Airflow
```python
# airflow/airflow.cfg
[core]
dags_folder = /home/ec2-user/dbt-shopee-tiktok/dags
load_examples = False

[scheduler]
schedule_interval = @daily
catchup_by_default = False
```

#### Create DBT DAG
```python
# dags/dbt_daily_pipeline.py
from airflow import DAG
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
}

with DAG(
    'dbt_daily_pipeline',
    default_args=default_args,
    description='Daily DBT pipeline',
    schedule_interval='0 2 * * *',
    catchup=False,
) as dag:

    run_dbt = BashOperator(
        task_id='run_dbt_models',
        bash_command='cd /home/ec2-user/dbt-shopee-tiktok && source dbt-venv/bin/activate && dbt run --target prod',
    )

    test_dbt = BashOperator(
        task_id='test_dbt_models',
        bash_command='cd /home/ec2-user/dbt-shopee-tiktok && source dbt-venv/bin/activate && dbt test --target prod',
    )

    run_dbt >> test_dbt
```

### 5. Setup Systemd Service

```bash
# Create systemd service for Airflow Scheduler
sudo cat > /etc/systemd/system/airflow-scheduler.service << EOF
[Unit]
Description=Airflow Scheduler
After=network.target

[Service]
Type=simple
User=ec2-user
Group=ec2-user
Environment="AIRFLOW_HOME=/home/ec2-user/airflow"
Environment="PATH=/home/ec2-user/dbt-venv/bin:/usr/local/bin:/usr/bin"
ExecStart=/home/ec2-user/dbt-venv/bin/airflow scheduler
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Create systemd service for Airflow Webserver
sudo cat > /etc/systemd/system/airflow-webserver.service << EOF
[Unit]
Description=Airflow Webserver
After=network.target

[Service]
Type=simple
User=ec2-user
Group=ec2-user
Environment="AIRFLOW_HOME=/home/ec2-user/airflow"
Environment="PATH=/home/ec2-user/dbt-venv/bin:/usr/local/bin:/usr/bin"
ExecStart=/home/ec2-user/dbt-venv/bin/airflow webserver -p 8080
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

# Enable and start services
sudo systemctl daemon-reload
sudo systemctl enable airflow-scheduler
sudo systemctl enable airflow-webserver
sudo systemctl start airflow-scheduler
sudo systemctl start airflow-webserver

# Check status
sudo systemctl status airflow-scheduler
sudo systemctl status airflow-webserver
```

### 6. Setup CloudWatch Logging

```bash
# Install CloudWatch agent
sudo yum install -y amazon-cloudwatch-agent

# Configure CloudWatch agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard

# Start CloudWatch agent
sudo systemctl start amazon-cloudwatch-agent
sudo systemctl enable amazon-cloudwatch-agent
```

### 7. Setup Monitoring & Alerts

#### Create CloudWatch Alarm
```bash
# Alarm for DBT pipeline failure
aws cloudsight put-metric-alarm \
    --alarm-name "DBT-Pipeline-Failure" \
    --alarm-description "DBT pipeline failed to complete" \
    --metric-name DBTJobFailure \
    --namespace DBT \
    --statistic Sum \
    --period 300 \
    --threshold 1 \
    --comparison-operator GreaterThanOrEqualToThreshold \
    --evaluation-periods 1 \
    --alarm-actions arn:aws:sns:region:account:dbt-alerts \
    --unit Count
```

#### Slack Integration
```python
# Add to DAG
from airflow.operators.python import PythonOperator
import requests

def send_slack_notification(context):
    webhook_url = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"

    if context['dag_run'].state == 'failed':
        message = {
            "text": f"🚨 DBT Pipeline Failed: {context['dag'].dag_id}",
            "attachments": [{
                "color": "danger",
                "fields": [{
                    "title": "Error",
                    "value": str(context.get('exception')),
                    "short": False
                }]
            }]
        }
    else:
        message = {
            "text": f"✅ DBT Pipeline Completed: {context['dag'].dag_id}",
            "attachments": [{
                "color": "good",
                "fields": [{
                    "title": "Status",
                    "value": "Success",
                    "short": True
                }]
            }]
        }

    requests.post(webhook_url, json=message)

notify_slack = PythonOperator(
    task_id='notify_slack',
    python_callable=send_slack_notification,
    provide_context=True,
)
```

### 8. CI/CD với GitHub Actions

```yaml
# .github/workflows/dbt-ci.yml
name: DBT CI/CD

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:
        image: postgres:14
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
        ports:
          - 5432:5432

    steps:
      - uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt

      - name: Run DBT tests
        env:
          DBT_HOST: localhost
          DBT_USER: postgres
          DBT_PASSWORD: postgres
          DBT_DATABASE: postgres
        run: |
          dbt deps
          dbt run --target ci
          dbt test --target ci

  deploy:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v3

      - name: Deploy to EC2
        uses: appleboy/ssh-action@master
        with:
          host: \${{ secrets.EC2_HOST }}
          username: ec2-user
          key: \${{ secrets.EC2_KEY }}
          script: |
            cd /home/ec2-user/dbt-shopee-tiktok
            git pull origin main
            source dbt-venv/bin/activate
            dbt deps
            dbt run --target prod
            dbt test --target prod
```

### 9. Backup & Recovery

#### Database Backup
```bash
# Create backup script
cat > /home/ec2-user/backup-db.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="analytics_backup_$DATE.sql"

pg_dump -h your-rds-endpoint.rds.amazonaws.com \
    -U backup_user \
    -d analytics \
    -F c \
    -f /home/ec2-user/backups/$BACKUP_FILE

# Upload to S3
aws s3 cp /home/ec2-user/backups/$BACKUP_FILE s3://your-backup-bucket/dbt/$BACKUP_FILE

# Delete old backups (keep 30 days)
find /home/ec2-user/backups -name "*.sql" -mtime +30 -delete
EOF

chmod +x /home/ec2-user/backup-db.sh

# Add to crontab
crontab -e
# Add: 0 4 * * * /home/ec2-user/backup-db.sh
```

### 10. Performance Tuning

#### PostgreSQL Configuration
```sql
-- Run on RDS PostgreSQL
-- Modify parameter group

-- Memory settings
SET shared_buffers = '2GB';
SET effective_cache_size = '6GB';
SET work_mem = '64MB';
SET maintenance_work_mem = '512MB';

-- Parallel query settings
SET max_parallel_workers_per_gather = 4;
SET max_parallel_workers = 8;

-- Checkpoint settings
SET checkpoint_completion_target = 0.9;
SET wal_buffers = '16MB';

-- Logging
SET log_min_duration_statement = 1000;
SET log_checkpoints = on;
```

#### DBT Configuration
```yaml
# dbt_project.yml
models:
  dbt_shopee_tiktok:
    +batch_size: 100000
    +incremental_strategy: merge
    +on_schema_change: append_new_columns

on-run-start:
  - "SET work_mem TO '256MB'"

on-run-end:
  - "VACUUM ANALYZE"
```

---

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| Connection timeout | Check Security Group, RDS public accessibility |
| Out of memory | Reduce threads, increase work_mem |
| Disk full | Clean target/ folder, setup log rotation |
| Airflow DAG not showing | Check dags_folder, restart scheduler |
| DBT tests failing | Check data quality, review thresholds |

### Useful Commands

```bash
# Check Airflow logs
tail -f ~/airflow/logs/scheduler/latest/*.log

# Check DBT logs
tail -f logs/dbt.log

# Restart Airflow services
sudo systemctl restart airflow-scheduler
sudo systemctl restart airflow-webserver

# Monitor PostgreSQL connections
psql -h your-rds-endpoint -U postgres -c "SELECT count(*) FROM pg_stat_activity;"

# Check disk usage
df -h
du -sh /home/ec2-user/dbt-shopee-tiktok/target
```

---

## Cost Estimation

### Monthly Costs (USD)

| Resource | Configuration | Cost/Month |
|----------|--------------|------------|
| EC2 | t3.medium | ~$30 |
| RDS PostgreSQL | db.t3.medium | ~$50 |
| S3 Storage | 100 GB | ~$2.30 |
| Data Transfer | ~10 GB | ~$1 |
| **Total** | | **~$83.30** |

Compare to AWS Glue: ~$450/month → **Save 81%**
