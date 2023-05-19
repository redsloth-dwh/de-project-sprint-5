INSERT INTO dds.dm_couriers 
    (
    courier_id, 
    courier_name
    )
SELECT object_id AS courier_id
    ,object_value::json->>'name' AS courier_name
FROM stg.deliverysystem_couriers;

UPDATE dds.srv_wf_settings
SET workflow_settings = (
    SELECT CONCAT('{"last_loaded_courier_id":"', MAX(id), '"}')::json
    FROM stg.deliverysystem_couriers
)
WHERE workflow_key = 'couriers_raw_to_dds_workflow';
