INSERT INTO sectors (sector) VALUES
  ('Semiconductors'), ('Technology'), ('Financials')
ON CONFLICT DO NOTHING;