INSERT INTO dds.dm_deliveries 
    (
    delivery_id, 
    order_id, 
    courier_id, 
    delivery_rate, 
    delivery_tip_sum
    )
SELECT object_id AS delivery_id
    ,dd.object_value::json->>'order_id' AS order_id
    ,c.id AS courier_id
    ,CAST(object_value::json->>'rate' AS INT) AS delivery_rate
    ,CAST(object_value::json->>'tip_sum' AS INT) AS delivery_tip_sum
FROM stg.deliverysystem_deliveries dd
LEFT JOIN dds.dm_couriers c ON dd.object_value::json->>'courier_id' = c.courier_id;


UPDATE dds.srv_wf_settings
SET workflow_settings = (
    SELECT CONCAT('{"last_loaded_delivery_id":"', MAX(id), '"}')::json
    FROM stg.deliverysystem_deliveries
)
WHERE workflow_key = 'deliveries_raw_to_dds_workflow';

