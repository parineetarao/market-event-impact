WITH b AS (
  SELECT trade_date, close_price,
         LAG(close_price) OVER (ORDER BY trade_date) AS prev_price,
         ROW_NUMBER() OVER (ORDER BY trade_date) AS rn
  FROM prices_daily
  WHERE instrument_id = (SELECT instrument_id FROM instruments WHERE symbol = 'BZ=F')
),
spikes AS (
  SELECT trade_date, rn,
         round(100 * (close_price / prev_price - 1), 2) AS pct_change,
         rn - LAG(rn) OVER (ORDER BY trade_date) AS obs_since_prev
  FROM b
  WHERE trade_date >= '2023-01-01' AND close_price / prev_price - 1 >= 0.05
),
episodes AS (
  SELECT *,
         SUM(CASE WHEN obs_since_prev IS NULL OR obs_since_prev > 10 THEN 1 ELSE 0 END)
           OVER (ORDER BY trade_date) AS episode_no
  FROM spikes
)
SELECT episode_no, min(trade_date) AS episode_start, max(trade_date) AS episode_end,
       count(*) AS spike_days, max(pct_change) AS biggest_day_pct
FROM episodes GROUP BY episode_no ORDER BY episode_no;