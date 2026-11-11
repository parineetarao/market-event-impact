CREATE TABLE event_models (
  model_id SERIAL PRIMARY KEY,
  event_id INT NOT NULL REFERENCES events,
  instrument_id INT NOT NULL REFERENCES instruments,
  benchmark_id INT NOT NULL REFERENCES instruments,
  day0_date DATE NOT NULL,
  est_start DATE NOT NULL,
  est_end DATE NOT NULL,
  est_n_obs INT NOT NULL,
  alpha NUMERIC(12,8) NOT NULL,
  beta NUMERIC(12,6) NOT NULL,
  resid_std NUMERIC(12,8) NOT NULL,
  r_squared NUMERIC(8,6),
  return_type TEXT NOT NULL DEFAULT 'log' CHECK (return_type IN ('log','simple')),
  computed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  UNIQUE (event_id, instrument_id, benchmark_id),
  CHECK (instrument_id <> benchmark_id),
  CHECK (est_end >= est_start)
);

CREATE TABLE abnormal_returns (
  model_id INT NOT NULL REFERENCES event_models ON DELETE CASCADE,
  rel_day INT NOT NULL,
  trade_date DATE NOT NULL,
  actual_return NUMERIC(12,8) NOT NULL,
  benchmark_return NUMERIC(12,8) NOT NULL,
  expected_return NUMERIC(12,8) NOT NULL,
  abnormal_return NUMERIC(12,8) NOT NULL,
  PRIMARY KEY (model_id, rel_day)
);

CREATE TABLE car_results (
  model_id INT NOT NULL REFERENCES event_models ON DELETE CASCADE,
  win_start INT NOT NULL,
  win_end INT NOT NULL,
  car NUMERIC(12,8) NOT NULL,
  n_days INT NOT NULL,
  t_stat NUMERIC(10,4),
  computed_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (model_id, win_start, win_end),
  CHECK (win_end >= win_start)
);

CREATE VIEW v_car_path AS
SELECT model_id, rel_day, trade_date, abnormal_return,
       SUM(abnormal_return) OVER (
         PARTITION BY model_id ORDER BY rel_day
         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
       ) AS car_from_day0
FROM abnormal_returns
WHERE rel_day >= 0;