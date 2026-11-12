INSERT INTO event_types (event_type, definition) VALUES
 ('rate_hike', 'Policy rate increase announced by the US Federal Reserve (FOMC) or the Reserve Bank of India (MPC).'),
 ('rate_cut', 'Policy rate cut announced by the US Federal Reserve (FOMC) or the Reserve Bank of India (MPC).'),
 ('export_control', 'US government announcement restricting sales of advanced chips or chip-making equipment to China.'),
 ('ai_infra_investment', 'Single announced commitment of at least US$10 billion for AI data centres, chips or compute capacity.'),
 ('big_tech_layoff', 'Single announcement of at least 5,000 job cuts or at least 5% of staff at a large US tech company.')
ON CONFLICT (event_type) DO NOTHING;