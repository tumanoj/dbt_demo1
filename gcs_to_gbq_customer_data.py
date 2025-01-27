import os
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.empty import EmptyOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.models import Variable
import json


# Custom Python logic for derriving date value
yesterday = datetime.combine(datetime.today() - timedelta(1), datetime.min.time())

# Get schema from Airflow Variables
#schema_fields = json.loads(Variable.get("gcs_to_bq_schema"))

# Default arguments
default_args = {
    'start_date': yesterday,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

# DAG definitions
with DAG(dag_id='GCS_to_GBQ_CUST_DATA',
         catchup=False,
         schedule=timedelta(days=1),
         default_args=default_args
         ) as dag:

# Dummy strat task
    start = EmptyOperator(
        task_id='start',
        dag=dag,
    )

# GCS to BigQuery data load Customer data
    gcs_to_gbq_load_file1 = GCSToBigQueryOperator(
                task_id='gcs_to_gbq_load_file1',
                bucket='us-central1-composer-airflo-1642f332-bucket',
                source_objects=['data/cust_data/customers.csv'],
                destination_project_dataset_table='stellar-concord-448718-m1.gcs_to_gbq_cust_ds.gcs_to_gbq_customers',
                schema_fields=[
                                {'name': 'ID', 'type': 'INT64', 'mode': 'NULLABLE'},
                                {'name': 'FIRST_NAME', 'type': 'STRING', 'mode': 'NULLABLE'},
                                {'name': 'LAST_NAME', 'type': 'STRING', 'mode': 'NULLABLE'}
                              ],
                #schema_fields=schema_fields
                skip_leading_rows=1,
                field_delimiter=',',
                source_format='CSV',
                create_disposition='CREATE_IF_NEEDED',
                write_disposition='WRITE_TRUNCATE', # Overwrite the table
    dag=dag)

# GCS to BigQuery data load Order data
    gcs_to_gbq_load_file2 = GCSToBigQueryOperator(
                task_id='gcs_to_gbq_load_file2',
                bucket='us-central1-composer-airflo-1642f332-bucket',
                source_objects=['data/cust_data/orders.csv'],
                destination_project_dataset_table='stellar-concord-448718-m1.gcs_to_gbq_cust_ds.gcs_to_gbq_orders',
                schema_fields=[
                                {'name': 'ID', 'type': 'INT64', 'mode': 'NULLABLE'},
                                {'name': 'USER_ID', 'type': 'INT64', 'mode': 'NULLABLE'},
                                {'name': 'ORDER_DATE', 'type': 'STRING', 'mode': 'NULLABLE'},
                                {'name': 'STATUS', 'type': 'STRING', 'mode': 'NULLABLE'}
                              ],
                skip_leading_rows=1,
                field_delimiter=',',
                source_format='CSV',
                create_disposition='CREATE_IF_NEEDED',
                write_disposition='WRITE_TRUNCATE', # Overwrite the table
    dag=dag)

# GCS to BigQuery data load Payments data
    gcs_to_gbq_load_file3 = GCSToBigQueryOperator(
                task_id='gcs_to_gbq_load_file3',
                bucket='us-central1-composer-airflo-1642f332-bucket',
                source_objects=['data/cust_data/payments.csv'],
                destination_project_dataset_table='stellar-concord-448718-m1.gcs_to_gbq_cust_ds.gcs_to_gbq_payments',
                schema_fields=[
                                {'name': 'id', 'type': 'INT64', 'mode': 'NULLABLE'},
                                {'name': 'orderid', 'type': 'INT64', 'mode': 'NULLABLE'},
                                {'name': 'paymentmethod', 'type': 'STRING', 'mode': 'NULLABLE'},
                                {'name': 'status', 'type': 'STRING', 'mode': 'NULLABLE'},
                                {'name': 'amount', 'type': 'FLOAT64', 'mode': 'NULLABLE'},
                                {'name': 'created', 'type': 'STRING', 'mode': 'NULLABLE'},
                                {'name': 'transaction_timestamp', 'type': 'TIMESTAMP', 'mode': 'NULLABLE'}
                              ],
                skip_leading_rows=1,
                field_delimiter=',',
                source_format='CSV',
                create_disposition='CREATE_IF_NEEDED',
                write_disposition='WRITE_TRUNCATE', # Overwrite the table
    dag=dag)

# Dummy end task
    end = EmptyOperator(
        task_id='end',
        dag=dag,
    )

# Settting up task ls -lrtdependency
start >> gcs_to_gbq_load_file1 >> gcs_to_gbq_load_file2 >> gcs_to_gbq_load_file3 >> end