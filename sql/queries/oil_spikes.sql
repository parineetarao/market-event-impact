WITH b AS (
  SELECT trade_date, close_price,
         LAG(trade_date)  OVER (ORDER BY trade_date) AS prev_date,
         LAG(close_price) OVER (ORDER BY trade_date) AS prev_price
  FROM prices_daily
  WHERE instrument_id = (SELECT instrument_id FROM instruments WHERE symbol = 'DCOILBRENTEU')
)
SELECT trade_date, prev_date, prev_price, close_price,
       round(100 * (close_price / prev_price - 1), 2) AS pct_change,
       trade_date - prev_date AS gap_days
FROM b
WHERE trade_date >= '2023-01-01'
  AND close_price / prev_price - 1 >= 0.05
ORDER BY trade_date;