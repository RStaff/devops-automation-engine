import os
import boto3
import pandas as pd
from io import StringIO
import psycopg2
from psycopg2.extras import execute_values
from dotenv import load_dotenv

# Load environment variables
load_dotenv(dotenv_path=".env")
print("DEBUG: S3_BUCKET_NAME =", os.getenv("S3_BUCKET_NAME"))
print("DEBUG: AWS_REGION     =", os.getenv("AWS_DEFAULT_REGION", "unset"))

# --- Fetch CSV from S3 ---
BUCKET = os.getenv("S3_BUCKET_NAME")
s3 = boto3.client("s3")
resp = s3.list_objects_v2(Bucket=BUCKET)
print("DEBUG: list_objects_v2 response =", resp)
objs = resp.get("Contents", [])
if not objs:
    raise SystemExit("ERROR: no files in S3 bucket")

key = sorted(objs, key=lambda x: x["LastModified"], reverse=True)[0]["Key"]
data = s3.get_object(Bucket=BUCKET, Key=key)["Body"].read().decode()
df = pd.read_csv(StringIO(data))
print(f"DEBUG: fetched {len(df)} rows from S3://{BUCKET}/{key}")

# --- Connect to Postgres and insert ---
conn = psycopg2.connect(os.getenv("POSTGRES_CONN"))
cur  = conn.cursor()

cur.execute("""
CREATE TABLE IF NOT EXISTS stock_prices (
  timestamp  DATE      PRIMARY KEY,
  open       DOUBLE PRECISION,
  high       DOUBLE PRECISION,
  low        DOUBLE PRECISION,
  close      DOUBLE PRECISION,
  volume     BIGINT
);
""")

records = [
    (row.timestamp, row.open, row.high, row.low, row.close, int(row.volume))
    for row in df.itertuples()
]

sql = """
INSERT INTO stock_prices (timestamp, open, high, low, close, volume)
VALUES %s
ON CONFLICT (timestamp) DO NOTHING;
"""

execute_values(cur, sql, records)
conn.commit()
print(f"Loaded {len(records)} rows into stock_prices table")

cur.close()
conn.close()
