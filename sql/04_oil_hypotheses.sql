INSERT INTO event_types (event_type, definition) VALUES
 ('oil_price_spike', 'Brent front-month futures (Yahoo BZ=F) up at least 5% in one day. Spike days within 10 trading days of each other form one episode; the first day is the event. FRED spot Brent is only a cross-check.'),
 ('governance_probe', 'Board, regulator or government investigation announced into a listed company or its senior leadership.')
ON CONFLICT (event_type) DO NOTHING;

INSERT INTO hypotheses (event_type, market, sector, expected_direction, rationale, written_on) VALUES
 ('oil_price_spike','IN','Auto','down','Fuel and raw-material costs rise and driving gets more expensive','2026-11-12'),
 ('oil_price_spike','IN','FMCG','down','Transport and packaging cost more and consumers have less to spend','2026-11-12'),
 ('oil_price_spike','IN','Banking','down','Higher oil raises inflation and weakens the rupee, which tends to push foreign investors out','2026-11-12'),
 ('oil_price_spike','IN','Energy','up','Producers earn more when oil rises; index is mixed so effect may be small','2026-11-12'),
 ('oil_price_spike','IN','IT','none','Income comes from clients abroad, not from oil prices','2026-11-12'),
 ('oil_price_spike','IN','Pharma','none','Little direct link to oil','2026-11-12'),
 ('oil_price_spike','IN','Metals','none','Commodity prices rise together but an oil spike also signals slower global growth','2026-11-12')
ON CONFLICT (event_type, market, sector) DO NOTHING;