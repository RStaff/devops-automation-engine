import os
import requests
import pandas as pd
from datetime import datetime
from dotenv import load_dotenv
from io import StringIO

load_dotenv(dotenv_path=".env")

API_KEY = os.getenv("ALPHAVANTAGE_API_KEY")
SYMBOL  = "AAPL"
OUTPUT_FILE = f"/tmp/{SYMBOL}_{datetime.today().strftime('%Y-%m-%d')}.csv"

def fetch_and_save():
    print("DEBUG: API_KEY =", API_KEY)
    if not API_KEY:
        print("ERROR: No API key found. Exiting.")
        return

    url = (
        "https://www.alphavantage.co/query"
        f"?function=TIME_SERIES_DAILY&symbol={SYMBOL}"
        f"&apikey={API_KEY}&datatype=csv"
    )
    print("DEBUG: Fetching URL:", url)

    try:
        resp = requests.get(url, timeout=10)
        print("DEBUG: HTTP status code:", resp.status_code)
        resp.raise_for_status()
    except Exception as e:
        print("ERROR: Request failed:", e)
        return

    # load into DataFrame
    df = pd.read_csv(StringIO(resp.text))
    print("DEBUG: Retrieved rows:", len(df))

    # write to disk
    df.to_csv(OUTPUT_FILE, index=False)
    print("Saved data to", OUTPUT_FILE)

if __name__ == "__main__":
    fetch_and_save()

