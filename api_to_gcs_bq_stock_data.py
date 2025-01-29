import json
import csv
import requests
from datetime import datetime, timedelta
from airflow import DAG
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from airflow.operators.python import PythonOperator
from google.cloud import storage
from airflow.models import Variable

# Custom Python logic for derriving date value
yesterday = datetime.combine(datetime.today() - timedelta(1), datetime.min.time())

# Function to convert JSON to CSV
def json_to_csv(json_data, csv_file_path):
    if json_data is None:
        raise ValueError("Received None as JSON data. Cannot process.")
    
    # Check if the 'ranking' field exists in the JSON and is a list
    if not isinstance(json_data.get("ranking"), list):
        raise ValueError("'ranking' field is missing or is not a list.")
    
    with open(csv_file_path, 'w', newline='') as f:
        writer = csv.writer(f)
        # Write the header row
        writer.writerow([
            'season', 'rank', 'symbol', 'shares', 
            'measurement_start', 'start_value_usd', 'measurement_end', 
            'end_value_usd', 'percent_gain'
        ])

        # Flatten the JSON structure and write each portfolio entry as a row
        for ranking in json_data["ranking"]:
            season = json_data.get("season", "")
            rank = ranking.get("rank", "")
            measurement_start = ranking.get("measurement_start", "")
            start_value_usd = ranking.get("start_value_usd", "")
            measurement_end = ranking.get("measurement_end", "")
            end_value_usd = ranking.get("end_value_usd", "")
            percent_gain = ranking.get("percent_gain", "")
            
            # Loop over portfolio to create a row for each symbol
            for portfolio in ranking.get("portfolio", []):
                symbol = portfolio.get("symbol", "")
                shares = portfolio.get("shares", "")
                
                writer.writerow([
                    season, rank, symbol, shares,
                    measurement_start, start_value_usd, measurement_end, 
                    end_value_usd, percent_gain
                ])

# Function to fetch data from the API
def fetch_data_from_api(**kwargs):
    # API URL and request
    # api_url = 'https://www.alphavantage.co/query?function=TOURNAMENT_PORTFOLIO&season=2021-09&apikey=demo' 
    api_url = Variable.get("api_base_url") 
    response = requests.get(api_url)
    
    # Check if the request was successful
    if response.status_code == 200:
        json_data = response.json()
    else:
        raise Exception("Failed to fetch data from API")
    
    return json_data

# Function to upload the CSV file to GCS
def upload_to_gcs(csv_file_path, bucket_name, object_name, **kwargs):
    client = storage.Client()  # Authenticate using default credentials
    bucket = client.get_bucket(bucket_name)  # Specify GCS bucket
    blob = bucket.blob(object_name)  # Specify the file name/path in GCS
    blob.upload_from_filename(csv_file_path)  # Upload the file from local path
    print(f"File {csv_file_path} uploaded to {bucket_name}/{object_name}")

# Airflow DAG definition
default_args = {
    'start_date': yesterday,
    'email_on_failure': False,
    'email_on_retry': False,
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

dag = DAG(
    'api_to_gcs_bq_stock_data',
    default_args=default_args,
    schedule=None,  # Adjust this based on your schedule
)

# Task 1: Fetch JSON data from API
fetch_data_task = PythonOperator(
    task_id='fetch_data_task',
    python_callable=fetch_data_from_api,
    #provide_context=True,
    dag=dag,
)

# Task 2: Convert JSON to CSV and store it locally
def convert_json_to_csv_and_store(**kwargs):
    # Get data from the previous task (XCom)
    json_data = kwargs['ti'].xcom_pull(task_ids='fetch_data_task')
    if json_data is None:
        raise ValueError("Received None as JSON data in Task2. Cannot process.")

    # Convert JSON to CSV
    csv_file_path = '/tmp/stock_output_data.csv'
    json_to_csv(json_data, csv_file_path)
    
    return csv_file_path

convert_json_to_csv_task = PythonOperator(
    task_id='convert_json_to_csv',
    python_callable=convert_json_to_csv_and_store,
    #provide_context=True,
    dag=dag,
)

# Task 3: Upload CSV to Google Cloud Storage using PythonOperator
upload_to_gcs_task = PythonOperator(
    task_id='upload_to_gcs',
    python_callable=upload_to_gcs,
    op_args=['/tmp/stock_output_data.csv', 'us-central1-composer-airflo-1642f332-bucket', 'data/cust_data/stock_output_data.csv'],  
    #provide_context=True,
    dag=dag,
)

# Task 4: Load CSV into BigQuery using GCSToBigQueryOperator
load_csv_to_bq_task = GCSToBigQueryOperator(
    task_id='load_csv_to_bq',
    bucket='us-central1-composer-airflo-1642f332-bucket',  
    source_objects=['data/cust_data/stock_output_data.csv'],  # Path to CSV in GCS
    destination_project_dataset_table='stellar-concord-448718-m1.gcs_to_gbq_cust_ds.gcs_to_gbq_stock_data',  # BigQuery table name
    source_format='CSV',
    autodetect=True,  # BigQuery will auto-detect the schema
    skip_leading_rows=1,  # Skip header row
    write_disposition='WRITE_APPEND',  # Use WRITE_TRUNCATE to overwrite if needed
   # gcp_conn_id='google_cloud_default',  # Use your Google Cloud connection ID
    dag=dag,
)

# Set up task dependencies
fetch_data_task >> convert_json_to_csv_task >> upload_to_gcs_task >> load_csv_to_bq_task