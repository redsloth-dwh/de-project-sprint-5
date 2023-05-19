INSERT INTO dds.dm_orders 
    (
    order_key, 
    order_status, 
    restaurant_id, 
    timestamp_id, 
    user_id, 
    delivery_id
    )
SELECT order_key
        , oo.order_status 
        , dr.id AS restaurant_id
        , dt.id AS timestamp_id
        , du.id AS user_id
        , dd.id AS delivery_id
    FROM (
        SELECT id
            , object_id AS order_key
            , object_value::json->>'final_status' AS order_status 
            , object_value::json->'restaurant'->>'id' AS restaurant_id
            , object_value::json->>'date' AS timestamp_id
            , object_value::json->'user'->>'id' AS user_id 
        FROM stg.ordersystem_orders oo 
    ) oo
    LEFT JOIN dds.dm_restaurants dr ON dr.restaurant_id = oo.restaurant_id
    LEFT JOIN dds.dm_timestamps dt ON dt.ts = oo.timestamp_id::timestamp
    LEFT JOIN dds.dm_users du ON du.user_id = oo.user_id
    LEFT JOIN dds.dm_deliveries dd ON dd.order_id = oo.order_key
;


UPDATE dds.srv_wf_settings
SET workflow_settings = (
    SELECT CONCAT('{"last_loaded_id":"', MAX(id), '"}')::json
    FROM stg.ordersystem_orders
)
WHERE workflow_key = 'orders_raw_to_dds_workflow';

