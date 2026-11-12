# Design decisions

Written before measuring results. Changes are made by adding a dated note with the reason, not by editing history.

## Event selection

Rule: include every event that matches the written rule for its type, regardless of how markets reacted. Events are never chosen because prices moved.

Date range: 2023-01-01 to 2026-11-10 (price data starts 2022-01-01 to leave an estimation window before the earliest event).

| Event type | Inclusion rule | Target | Date source |
|---|---|---|---|
| oil_price_spike | Brent front-month futures (Yahoo BZ=F) up at least 5% in one day. FRED spot Brent is a cross-check only | 9 (done) | Futures data plus news |
| rate_hike | Rate increase by the US Federal Reserve (FOMC) or the RBI (MPC) | up to 12 | Official statement |
| rate_cut | Rate cut by the US Federal Reserve (FOMC) or the RBI (MPC) | up to 12 | Official statement |
| export_control | US government announcement restricting advanced chip or chip-equipment sales to China | up to 12 | Commerce/BIS notice plus news |
| ai_infra_investment | Single announced commitment of at least US$10B for AI data centres, chips or compute | up to 12 | Company announcement plus news |
| big_tech_layoff | Single announcement of at least 5,000 job cuts or at least 5% of staff at a large US tech company | up to 12 | Company statement plus news |
| governance_probe | Formal investigation or regulatory action announced against a listed company or its leader | up to 12 | Regulator or company statement |

An event is counted only after I have opened its source and confirmed the date and what happened (verified = true).

## Oil spikes

- Defined on futures, not spot. Reason: on 2 Oct 2026 the FRED spot series jumped about 18% while futures were roughly flat, because the physical market was squeezed.
- Episode rule: spike days within 10 trading days of the previous spike day belong to the same episode. The first day is the event. Later days are flagged inside its window, not counted as new events.
- Events from 28 Feb 2026 onward are flagged as the US-Iran war regime.

## Timing

- Day 0 = the first trading session whose close comes after the event time. News during market hours counts that day. News after the close counts the next session.
- Each market has its own day 0 (India and the US can differ).
- Event times that are approximate are marked in confound_note.

## Data handling

- Returns are computed only between consecutive days present in both the stock and the benchmark.
- A gap inside an event window lowers n_days and flags the event.
- Blank values (for example Brent on holidays) are never filled with zero or forward-filled.
- The loader drops any row dated today or later, so unfinished bars are never stored.
- Hypotheses are frozen once committed. A change needs a dated note here with the reason.

## Open for Phase 3

- Length of the estimation window and how to handle estimation days that fall inside other events.
- Event windows to report (for example 0 to +5 days).
- Whether post-2026 events need a separate regime treatment.