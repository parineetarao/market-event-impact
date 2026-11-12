SELECT n.trade_date,
       to_char(n.trade_date, 'Dy') AS weekday,
       count(*) AS sector_indices_missing
FROM prices_daily n
JOIN instruments nifty ON nifty.symbol = '^NSEI' AND n.instrument_id = nifty.instrument_id
CROSS JOIN instruments i
WHERE i.kind = 'sector_index'
  AND NOT EXISTS (SELECT 1 FROM prices_daily p
                  WHERE p.instrument_id = i.instrument_id AND p.trade_date = n.trade_date)
GROUP BY n.trade_date
ORDER BY n.trade_date;