-- Written before measuring. Direction is relative to the market benchmark.
INSERT INTO hypotheses (event_type, market, sector, expected_direction, rationale, written_on) VALUES
 ('oil_price_spike','US','Energy','up','Oil producers earn more when oil rises','2026-11-13'),
 ('rate_hike','IN','Auto','down','Vehicle loans get more expensive','2026-11-13'),
 ('rate_hike','IN','Metals','down','Growth-sensitive; higher rates slow demand','2026-11-13'),
 ('rate_hike','IN','Pharma','up','Defensive: demand does not depend on the economy','2026-11-13'),
 ('rate_hike','IN','FMCG','up','Defensive: everyday goods hold up when growth worries rise','2026-11-13'),
 ('rate_hike','US','Technology','down','Growth stocks lose value when interest rates rise','2026-11-13'),
 ('rate_hike','US','Semiconductors','down','High-beta growth sector, sensitive to rates','2026-11-13'),
 ('rate_hike','US','Financials','up','Banks earn more on loans when rates rise','2026-11-13'),
 ('rate_cut','IN','Auto','up','Vehicle loans get cheaper','2026-11-13'),
 ('rate_cut','IN','Metals','up','Cheaper money supports demand for materials','2026-11-13'),
 ('rate_cut','US','Technology','up','Growth stocks gain when interest rates fall','2026-11-13'),
 ('rate_cut','US','Semiconductors','up','High-beta growth sector, sensitive to rates','2026-11-13'),
 ('export_control','US','Semiconductors','down','Chip makers lose sales to China','2026-11-13'),
 ('export_control','US','Technology','down','Smaller effect: big chip names sit inside the tech sector','2026-11-13'),
 ('ai_infra_investment','US','Semiconductors','up','AI spending means more orders for chips','2026-11-13'),
 ('ai_infra_investment','US','Technology','up','AI spending signals strong demand for tech','2026-11-13'),
 ('big_tech_layoff','US','Technology','up','Cost cuts lift profit margins','2026-11-13'),
 ('big_tech_layoff','IN','IT','down','Indian IT services depend on US tech clients spending','2026-11-13')
ON CONFLICT (event_type, market, sector) DO NOTHING;

-- Every other event type / sector pair: no specific expected difference
INSERT INTO hypotheses (event_type, market, sector, expected_direction, rationale, written_on)
SELECT t.event_type, i.market, i.sector, 'none', 'No specific expected link', DATE '2026-11-13'
FROM (VALUES ('oil_price_spike'),('rate_hike'),('rate_cut'),('export_control'),
             ('ai_infra_investment'),('big_tech_layoff'),('governance_probe')) AS t(event_type)
CROSS JOIN (SELECT DISTINCT market, sector FROM instruments
            WHERE kind = 'sector_index' AND sector IS NOT NULL AND market IN ('IN','US')) AS i
ON CONFLICT (event_type, market, sector) DO NOTHING;