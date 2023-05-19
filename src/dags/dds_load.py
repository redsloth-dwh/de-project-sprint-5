"""
Load data to DDS
"""

from airflow import DAG
from airflow.hooks.base import BaseHook
from airflow.providers.postgres.operators.postgres import PostgresOperator

import pendulum


with DAG(
    dag_id='dds_load',
    schedule_interval='0 15 * * *',
    start_date=pendulum.datetime(2023, 5, 16, tz='UTC'),
    catchup=False,
    tags=['sprint5', 'dds']
) as dag:
    dag.doc_md = __doc__
    
    dm_couriers = PostgresOperator(
        task_id= "dm_couriers", 
        postgres_conn_id="pg_conn", 
        sql='./sql/dm_couriers.sql'
    )

    dm_deliveries = PostgresOperator(
        task_id= "dm_deliveries", 
        postgres_conn_id="pg_conn", 
        sql='./sql/dm_deliveries.sql'
    )

    dm_orders = PostgresOperator(
        task_id= "dm_orders", 
        postgres_conn_id="pg_conn", 
        sql='./sql/dm_orders.sql'
    )

dm_couriers >> dm_deliveries >> dm_orders
