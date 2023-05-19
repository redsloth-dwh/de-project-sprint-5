"""
Load data to STG
"""

from datetime import datetime, timedelta

from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.operators.python import PythonOperator

import pendulum
import requests
from requests.structures import CaseInsensitiveDict
from requests.adapters import HTTPAdapter
from urllib3.util.retry import Retry

import psycopg2


api_conn = BaseHook.get_connection('delivery_api')
api_endpoint = api_conn.host
api_token = api_conn.password
nickname = api_conn.login
COHORT = '12'

headers = {
    'X-API-KEY': api_token,
    'X-Nickname': nickname,
    'X-Cohort': COHORT
}

psql_conn = BaseHook.get_connection('pg_conn')


def load_data(table, id_column):
    """
    Load data into STG
    :param table: name of loading table
    :param id_column: name of id column
    :return: none
    """
    method_url = table
    params = CaseInsensitiveDict()
    params['sort_field'] = 'id'
    params['sort_direction'] = 'asc'
    params['from'] = (datetime.utcnow() - timedelta(hours=25)).strftime('%Y-%m-%d %H:%M:%S')
    params['offset'] = '0'
    
    
    session = requests.Session()
    retry = Retry(connect=3, backoff_factor=0.5)
    adapter = HTTPAdapter(max_retries=retry)
    session.mount('https://', adapter)
    data = session.get(f'https://{api_endpoint}/{method_url}', headers=headers, params=params)
    
    
    
    if len(data.json()):
        for d in data.json():
            sql_prep = f"delete from stg.deliverysystem_{table} where update_ts = current_date;"
            sql = f"""
                        INSERT INTO stg.deliverysystem_{table} 
                            (
                            object_id, 
                            object_value, 
                            update_ts
                            )
                        VALUES ('{d[id_column]}', '{str(d).replace("'", '"')}', current_date);
                        """
                        
            with psycopg2.connect(f"dbname='de' port='{psql_conn.port}' user='{psql_conn.login}' host='{psql_conn.host}' password='{psql_conn.password}'") as conn:
                with conn.cursor() as cur:
                    cur.execute(sql_prep)
                    cur.execute(sql)
                    conn.commit()      
        params['offset'] = str(int(params['offset']) + len(data.json()))



with DAG(
    dag_id='stg_load',
    schedule_interval='05 10 * * *',
    start_date=pendulum.datetime(2023, 5, 16, tz='UTC'),
    catchup=False,
    tags=['sprint5', 'stg']
) as dag:
    dag.doc_md = __doc__
    
    deliverysystem_couriers = PythonOperator(
        task_id='deliverysystem_couriers',
        python_callable=load_data,
        op_kwargs={
            'table':'couriers',
            'id_column':'_id'
        }
    )
    deliverysystem_deliveries = PythonOperator(
        task_id='deliverysystem_deliveries',
        python_callable=load_data,
        op_kwargs={
            'table':'deliveries',
            'id_column':'delivery_id'
        }
    )
    
