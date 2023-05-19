CREATE TABLE IF NOT EXISTS dds.dm_couriers 
(
	id serial primary key,
	courier_id varchar not null,
	courier_name varchar not null
);

CREATE TABLE IF NOT EXISTS dds.dm_deliveries 
(
	id 				serial primary key,
	delivery_id 		varchar not null,
	order_id 			varchar not null,
	courier_id 		integer null,
	delivery_rate 		integer null,
	delivery_tip_sum 	numeric(14,2) null
);


ALTER TABLE dds.dm_orders ADD COLUMN delivery_id integer;
ALTER TABLE dds.dm_orders ADD CONSTRAINT dm_orders_delivery_id_fkey FOREIGN KEY (delivery_id) REFERENCES dds.dm_deliveries(id);

