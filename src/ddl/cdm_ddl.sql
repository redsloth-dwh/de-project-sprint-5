CREATE TABLE IF NOT EXISTS cdm.dm_courier_ledger
(
	id serial primary key,
	courier_id integer not null,
	courier_name text not null,
	settlement_year integer not null check (settlement_year >= 2000 and settlement_year <= 3000),
	settlement_month integer not null check (settlement_month >= 1 and settlement_month <= 12),
	orders_count integer not null,
	orders_total_sum numeric(14, 2) not null default 0 check ((orders_total_sum >= (0)::numeric)),
	rate_avg numeric(14, 5) not null default 0 check ((rate_avg >= (0)::numeric)), 
	order_processing_fee numeric(14, 2) not null default 0 check ((order_processing_fee >= (0)::numeric)),
	courier_order_sum numeric(14, 2) not null default 0 check ((courier_order_sum >= (0)::numeric)),
	courier_tips_sum numeric(14, 2) not null default 0 check ((courier_tips_sum >= (0)::numeric)),
	courier_reward_sum numeric(14, 2) not null default 0 check ((courier_tips_sum >= (0)::numeric))
);
