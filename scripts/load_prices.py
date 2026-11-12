import os
import pathlib
from datetime import date

import pandas as pd
import pg8000.dbapi
from dotenv import load_dotenv

load_dotenv()
conn = pg8000.dbapi.connect(
    user=os.environ["PG_USER"],
    password=os.environ["PG_PASSWORD"],
    host="localhost",
    port=5432,
    database=os.environ["PG_DB"],
)
cur = conn.cursor()
RAW = pathlib.Path("data/raw")

# file, symbol, name, market, kind, sector, source
SERIES = [
    ("NIFTY50", "^NSEI", "Nifty 50", "IN", "benchmark", None, "yfinance"),
    ("NIFTY_IT", "^CNXIT", "Nifty IT", "IN", "sector_index", "IT", "yfinance"),
    ("NIFTY_BANK", "^NSEBANK", "Nifty Bank", "IN", "sector_index", "Banking", "yfinance"),
    ("NIFTY_AUTO", "^CNXAUTO", "Nifty Auto", "IN", "sector_index", "Auto", "yfinance"),
    ("NIFTY_PHARMA", "^CNXPHARMA", "Nifty Pharma", "IN", "sector_index", "Pharma", "yfinance"),
    ("NIFTY_ENERGY", "^CNXENERGY", "Nifty Energy", "IN", "sector_index", "Energy", "yfinance"),
    ("NIFTY_METAL", "^CNXMETAL", "Nifty Metal", "IN", "sector_index", "Metals", "yfinance"),
    ("NIFTY_FMCG", "^CNXFMCG", "Nifty FMCG", "IN", "sector_index", "FMCG", "yfinance"),
    ("INDIAVIX", "^INDIAVIX", "India VIX", "IN", "indicator", None, "yfinance"),
    ("USDINR", "USDINR=X", "USD/INR", "GLOBAL", "indicator", None, "yfinance"),
    ("SP500", "^GSPC", "S&P 500", "US", "benchmark", None, "yfinance"),
    ("BRENT_FUT", "BZ=F", "Brent crude futures (front-month, Yahoo)", "GLOBAL", "indicator", None, "yfinance"),
    ("NASDAQ", "^IXIC", "Nasdaq Composite", "US", "benchmark", None, "yfinance"),
    ("NVDA", "NVDA", "Nvidia", "US", "stock", None, "yfinance"),
    ("BRENT", "DCOILBRENTEU", "Brent crude spot (FRED)", "GLOBAL", "indicator", None, "FRED"),
    ("SEMIS_ETF", "SMH", "VanEck Semiconductor ETF", "US", "sector_index", "Semiconductors", "yfinance"),
    ("TECH_ETF", "XLK", "Technology Select Sector SPDR", "US", "sector_index", "Technology", "yfinance"),
    ("ENERGY_ETF", "XLE", "Energy Select Sector SPDR", "US", "sector_index", "Energy", "yfinance"),
    ("FIN_ETF", "XLF", "Financial Select Sector SPDR", "US", "sector_index", "Financials", "yfinance"),
    ("MSFT", "MSFT", "Microsoft", "US", "stock", None, "yfinance"),
    ("GOOGL", "GOOGL", "Alphabet", "US", "stock", None, "yfinance"),
    ("AMZN", "AMZN", "Amazon", "US", "stock", None, "yfinance"),
    ("META", "META", "Meta Platforms", "US", "stock", None, "yfinance"),
    ("AMD", "AMD", "Advanced Micro Devices", "US", "stock", None, "yfinance")
    ]


def read_series(name):
    df = pd.read_csv(RAW / f"{name}.csv")
    if name == "BRENT":
        df = df.rename(columns={df.columns[0]: "date", "DCOILBRENTEU": "close"})
        df["adj"] = None
    else:
        df = df.rename(columns={"Date": "date", "Close": "close", "Adj Close": "adj"})
    # keep the local date exactly as written; avoids timezone/DST surprises
    df["date"] = pd.to_datetime(df["date"].astype(str).str[:10]).dt.date
    df["close"] = pd.to_numeric(df["close"], errors="coerce")
    df["adj"] = pd.to_numeric(df["adj"], errors="coerce")
    df = df.dropna(subset=["close"])
    return df[df["date"] < date.today()]  # never store an unfinished bar


for fname, sym, name, mkt, kind, sector, src in SERIES:
    cur.execute(
        """INSERT INTO instruments (symbol, name, market, kind, sector, source)
           VALUES (%s, %s, %s, %s, %s, %s)
           ON CONFLICT (market, symbol) DO NOTHING""",
        (sym, name, mkt, kind, sector, src),
    )
    cur.execute(
        "SELECT instrument_id FROM instruments WHERE market = %s AND symbol = %s",
        (mkt, sym),
    )
    iid = cur.fetchone()[0]
    df = read_series(fname)
    rows = [
        (iid, r.date, float(r.close), None if pd.isna(r.adj) else float(r.adj), src)
        for r in df.itertuples()
    ]
    cur.executemany(
        """INSERT INTO prices_daily
               (instrument_id, trade_date, close_price, adj_close_price, source)
           VALUES (%s, %s, %s, %s, %s)
           ON CONFLICT (instrument_id, trade_date) DO NOTHING""",
        rows,
    )
    print(f"{fname:13} read {len(rows)} rows")

conn.commit()

cur.execute(
    """SELECT i.symbol, count(*) AS n, min(p.trade_date) AS first_day, max(p.trade_date) AS last_day
       FROM prices_daily p JOIN instruments i USING (instrument_id)
       GROUP BY i.symbol ORDER BY i.symbol"""
)
print(pd.DataFrame(cur.fetchall(), columns=["symbol", "n", "first_day", "last_day"]).to_string(index=False))
conn.close()