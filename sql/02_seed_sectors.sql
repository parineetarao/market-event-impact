INSERT INTO sectors (sector) VALUES
  ('IT'), ('Banking'), ('Auto'), ('Pharma'), ('Energy'), ('Metals'), ('FMCG')
ON CONFLICT DO NOTHING;