WITH f AS (
  SELECT trade_date,
         close_price / LAG(close_price) OVER (ORDER BY trade_date) - 1 AS r
  FROM prices_daily
  WHERE instrument_id = (SELECT instrument_id FROM instruments WHERE symbol = 'BZ=F')
),
s AS (
  SELECT trade_date,
         close_price / LAG(close_price) OVER (ORDER BY trade_date) - 1 AS r,
         LEAD(close_price) OVER (ORDER BY trade_date) / close_price - 1 AS r_next
  FROM prices_daily
  WHERE instrument_id = (SELECT instrument_id FROM instruments WHERE symbol = 'DCOILBRENTEU')
)
SELECT f.trade_date,
       round(100 * f.r, 2)      AS futures_pct,
       round(100 * s.r, 2)      AS spot_pct_same_day,
       round(100 * s.r_next, 2) AS spot_pct_next_day
FROM f LEFT JOIN s USING (trade_date)
WHERE f.trade_date >= '2023-01-01' AND f.r >= 0.05
ORDER BY f.trade_date;