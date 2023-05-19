"""
Load data to CDM
"""

from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.providers.postgres.operators.postgres import PostgresOperator

import pendulum

with DAG(
    dag_id='cdm_load',
    schedule_interval='0 11 * * *',
    start_date=pendulum.datetime(2023, 5, 16, tz='UTC'),
    catchup=False,
    tags=['sprint5', 'cdm']
) as dag:
    dag.doc_md = __doc__
    
    dm_courier_ledger = PostgresOperator(
        task_id= "dm_courier_ledger", 
        postgres_conn_id="pg_conn", 
        sql='./sql/dm_courier_ledger.sql'
    )
