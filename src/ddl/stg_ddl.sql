CREATE TABLE stg.deliverysystem_couriers 
(
	id serial primary key,
	object_id varchar not null,
	object_value text not null,
	update_ts timestamp not null,
	constraint deliverysystem_couriers_object_id_key unique (object_id)
);

CREATE TABLE stg.deliverysystem_deliveries (
	id SERIAL primary key,
	object_id varchar not null,
	object_value text not null,
	update_ts timestamp not null,
	constraint deliverysystem_deliveries_object_id_key unique (object_id)
);
