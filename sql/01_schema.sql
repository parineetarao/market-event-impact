CREATE TABLE sectors (
  sector TEXT PRIMARY KEY
);
CREATE TABLE instruments (
  instrument_id SERIAL PRIMARY KEY,
  symbol TEXT NOT NULL,
  name TEXT NOT NULL,
  market TEXT NOT NULL CHECK (market IN ('IN','US','GLOBAL')),
  kind TEXT NOT NULL CHECK (kind IN ('stock','sector_index','benchmark','indicator')),
  sector TEXT REFERENCES sectors,
  source TEXT NOT NULL,
  UNIQUE (market, symbol)
);
CREATE TABLE prices_daily (
  instrument_id INT NOT NULL REFERENCES instruments,
  trade_date DATE NOT NULL,
  close_price NUMERIC(18,4) NOT NULL,
  adj_close_price NUMERIC(18,4),
  source TEXT NOT NULL,
  loaded_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (instrument_id, trade_date)
);
CREATE TABLE event_types (
  event_type TEXT PRIMARY KEY,
  definition TEXT NOT NULL
);
CREATE TABLE events (
  event_id SERIAL PRIMARY KEY,
  event_type TEXT NOT NULL REFERENCES event_types,
  title TEXT NOT NULL,
  event_ts TIMESTAMPTZ NOT NULL,
  source_url TEXT NOT NULL,
  source_name TEXT,
  verified BOOLEAN NOT NULL DEFAULT false,
  confounded BOOLEAN NOT NULL DEFAULT false,
  confound_note TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending','measured','excluded'))
);
CREATE TABLE hypotheses (
  hypothesis_id SERIAL PRIMARY KEY,
  event_type TEXT NOT NULL REFERENCES event_types,
  market TEXT NOT NULL CHECK (market IN ('IN','US')),
  sector TEXT NOT NULL REFERENCES sectors,
  expected_direction TEXT NOT NULL CHECK (expected_direction IN ('up','down','none')),
  rationale TEXT NOT NULL,
  written_on DATE NOT NULL,
  UNIQUE (event_type, market, sector)
);