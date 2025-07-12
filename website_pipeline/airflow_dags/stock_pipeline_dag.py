from airflow import DAG
from airflow.providers.amazon.aws.operators.s3 import S3ListObjectsOperator, S3Hook
from airflow.operators.python import PythonOperator
from datetime import datetime, timedelta

default_args = {
    'owner': 'rstaff',
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

def print_s3_head(**ctx):
    hook = S3Hook(aws_conn_id='aws_default')
    key = ctx['task_instance'].xcom_pull('list_raw_files')[0]
    data = hook.read_key(key, bucket_name='{{ var.value.raw_data_bucket }}')
    print(data.splitlines()[:5])

with DAG(
    dag_id='stock_pipeline',
    default_args=default_args,
    schedule_interval='@daily',
    start_date=datetime(2025, 1, 1),
    catchup=False,
) as dag:

    list_raw = S3ListObjectsOperator(
        task_id='list_raw_files',
        bucket='{{ var.value.raw_data_bucket }}',
        prefix='stocks/',
    )

    head_raw = PythonOperator(
        task_id='print_s3_head',
        python_callable=print_s3_head,
        provide_context=True,
    )

    list_raw >> head_raw
