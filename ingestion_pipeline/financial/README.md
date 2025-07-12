# Financial Data Pipeline

A reference implementation of a scalable, production‐style data integration workflow built in Python, orchestrated with Apache Airflow, deployed via Docker, and backed by cloud infrastructure as code. This project mirrors the core responsibilities of a Data Integration Engineer: fetching raw financial data, landing it in S3, transforming and loading into a relational store, and scheduling everything in an automated DAG.
---

## 📂 Repository Structure
.
├── .github/
│ └── workflows/ # CI/CD pipelines (lint, tests, Docker build)
├── infra/ # Terraform code for provisioning S3 bucket, IAM roles, etc.
├── app/ # Dockerfile, entrypoint scripts, containerized helpers
├── src/ # Python modules
│ ├── fetch_stock_data.py # ETL: pull daily CSV from Alpha Vantage
│ ├── s3_upload.py # Upload local CSV to S3
│ └── db_load.py # Read S3 CSV and append into PostgreSQL
├── airflow_dags/ # Airflow DAG definitions
│ └── stock_pipeline_dag.py
├── Dockerfile # Containerizes the Python & Airflow environment
├── requirements.txt # Python dependencies
└── README.md # This documentation

---

## 🚀 Features

- **End-to-End ETL**  
  Fetch equity price data, push to AWS S3, and load into Postgres.
- **Orchestration**  
  Define and schedule a daily DAG in Apache Airflow.
- **Infrastructure as Code**  
  Terraform configs to provision S3 buckets and IAM roles.
- **Containerized Development**  
  Dockerfile for consistent local/dev/test environments.
- **CI/CD Integration**  
  GitHub Actions pipelines for linting, testing, and pushing Docker images.

---

## 🛠️ Getting Started

### Prerequisites

- **Python 3.8+**  
- **Docker & Docker Compose**  
- **Terraform 0.13+**  
- **Airflow 2.x** (or the Docker container will spin it up)  
- AWS credentials with permissions to create/read/write S3, and an accessible Postgres instance.

### Quick Setup

1. **Clone & enter**  
   ```bash
   git clone https://github.com/RStaff/financial-data-pipeline.git
   cd financial-data-pipeline

   cd infra
terraform init
terraform apply   # provisions S3 bucket + IAM roles

cd ..
docker-compose up -d --build
ALPHAVANTAGE_API_KEY=YOUR_KEY
AWS_ACCESS_KEY_ID=…
AWS_SECRET_ACCESS_KEY=…
S3_BUCKET_NAME=provisioned-bucket
POSTGRES_CONN=postgresql://user:pass@db:5432/yourdb
PROJECT_PATH=/opt/airflow

**Trigger the DAG**
Open http://localhost:8080 → unpause stock_data_pipeline → trigger it manually or wait for the daily schedule.

🔍 **How It Works**
fetch_stock_data.py
Hits Alpha Vantage’s REST API, saves a timestamped CSV to /tmp.

s3_upload.py
Uses boto3 to upload the latest CSV to your S3 bucket.

db_load.py
Reads that CSV from S3 and appends the records to the stock_prices table in Postgres.

stock_pipeline_dag.py
Defines a three‐step Airflow DAG (fetch → upload → load) scheduled at @daily.

# financial-data-pipeline
