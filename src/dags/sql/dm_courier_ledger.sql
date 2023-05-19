INSERT INTO cdm.dm_courier_ledger 
    (
    courier_id,
    courier_name,
    settlement_year,
    settlement_month,
    orders_count,
    orders_total_sum,
    rate_avg,
    order_processing_fee,
    courier_order_sum,
    courier_tips_sum,
    courier_reward_sum
    )
SELECT dc.id AS courier_id
    , dc.courier_name
    , dt."year"::int AS settlement_year
    , dt."month"::int AS settlement_month
    , COUNT(fps.order_id) AS orders_count
    , SUM(fps.total_sum) AS orders_total_sum
    , rating.rate_avg 
    , SUM(fps.total_sum) * 0.25 AS order_processing_fee
    , SUM(CASE WHEN rating.rate_avg < 4 THEN CASE WHEN 0.05 * fps.total_sum < 100 THEN 100 ELSE 0.05 * fps.total_sum END
        WHEN rating.rate_avg < 4.5 THEN CASE WHEN 0.07 * fps.total_sum < 150 THEN 150 ELSE 0.07 * fps.total_sum END
        WHEN rating.rate_avg < 4.9 THEN CASE WHEN 0.08 * fps.total_sum < 175 THEN 175 ELSE 0.08 * fps.total_sum END
        ELSE CASE WHEN 0.1 * fps.total_sum < 200 THEN 200 ELSE 0.1 * fps.total_sum END
        END) AS courier_order_sum
    , SUM(dd.delivery_tip_sum) AS courier_tips_sum
    , (SUM(CASE WHEN rating.rate_avg < 4 THEN CASE WHEN 0.05 * fps.total_sum < 100 THEN 100 ELSE 0.05 * fps.total_sum END
        WHEN rating.rate_avg < 4.5 THEN CASE WHEN 0.07 * fps.total_sum < 150 THEN 150 ELSE 0.07 * fps.total_sum END
        WHEN rating.rate_avg < 4.9 THEN CASE WHEN 0.08 * fps.total_sum < 175 THEN 175 ELSE 0.08 * fps.total_sum END
        ELSE CASE WHEN 0.1 * fps.total_sum < 200 THEN 200 ELSE 0.1 * fps.total_sum END
        END) + SUM(dd.delivery_tip_sum)) * 0.95 AS courier_reward_sum
FROM dds.fct_product_sales fps
LEFT JOIN dds.dm_orders "do" ON "do".id = fps.order_id 
LEFT JOIN dds.dm_deliveries dd ON "do".delivery_id = dd.id
LEFT JOIN dds.dm_couriers dc ON dd.courier_id = dc.id
LEFT JOIN dds.dm_timestamps dt ON "do".timestamp_id = dt.id
LEFT JOIN (
    SELECT dc.id AS courier_id
        , dt."year" AS settlement_year
        , dt."month" AS settlement_month
        , AVG(dd.delivery_rate) AS rate_avg 
    FROM dds.dm_orders "do"
    LEFT JOIN dds.dm_deliveries dd ON "do".delivery_id = dd.id
    LEFT JOIN dds.dm_couriers dc ON dd.courier_id = dc.id
    LEFT JOIN dds.dm_timestamps dt ON "do".timestamp_id = dt.id
    GROUP BY dc.id, dt."year", dt."month"
) rating ON dc.id = rating.courier_id AND dt."year" = rating.settlement_year AND dt."month" = rating.settlement_month
GROUP BY dc.id, dc.courier_name, dt."year", dt."month", rating.rate_avg;
