import pathlib
import pandas as pd
import yfinance as yf

RAW = pathlib.Path("data/raw")
RAW.mkdir(parents=True, exist_ok=True)

TICKERS = {
    "NIFTY50": "^NSEI",
    "NIFTY_IT": "^CNXIT",
    "NIFTY_BANK": "^NSEBANK",
    "NIFTY_AUTO": "^CNXAUTO",
    "NIFTY_PHARMA": "^CNXPHARMA",
    "NIFTY_ENERGY": "^CNXENERGY",
    "NIFTY_METAL": "^CNXMETAL",
    "NIFTY_FMCG": "^CNXFMCG",
    "INDIAVIX": "^INDIAVIX",
    "USDINR": "USDINR=X",
    "BRENT_FUT": "BZ=F",
    "SP500": "^GSPC",
    "NASDAQ": "^IXIC",
    "NVDA": "NVDA",
    "SEMIS_ETF": "SMH",
    "TECH_ETF": "XLK",
    "ENERGY_ETF": "XLE",
    "FIN_ETF": "XLF",
    "MSFT": "MSFT",
    "GOOGL": "GOOGL",
    "AMZN": "AMZN",
    "META": "META",
    "AMD": "AMD",
}

for name, sym in TICKERS.items():
    try:
        df = yf.download(sym, start="2022-01-01", auto_adjust=False, progress=False)
    except Exception as e:
        print(f"{name:13} FAILED: {e}")
        continue
    if df.empty:
        print(f"{name:13} EMPTY (check ticker {sym})")
        continue
    if isinstance(df.columns, pd.MultiIndex):
        df.columns = df.columns.get_level_values(0)
    missing = int(df["Close"].isna().sum())
    print(f"{name:13} rows={len(df):5}  first={df.index.min().date()}  "
          f"last={df.index.max().date()}  missing_close={missing}")
    df.to_csv(RAW / f"{name}.csv")

col = "DCOILBRENTEU"
brent = pd.read_csv(f"https://fred.stlouisfed.org/graph/fredgraph.csv?id={col}")
date_col = brent.columns[0]
brent[col] = pd.to_numeric(brent[col], errors="coerce")
brent = brent[brent[date_col] >= "2022-01-01"]
print(f"{'BRENT':13} rows={len(brent):5}  first={brent[date_col].iloc[0]}  "
      f"last={brent[date_col].iloc[-1]}  missing={int(brent[col].isna().sum())}")
brent.to_csv(RAW / "BRENT.csv", index=False)