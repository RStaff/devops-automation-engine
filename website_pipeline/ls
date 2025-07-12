import os
import boto3
from dotenv import load_dotenv

load_dotenv(dotenv_path=".env")

BUCKET = os.getenv("S3_BUCKET_NAME")
# Find the latest AAPL file in /tmp
file_list = [f for f in os.listdir("/tmp") if f.startswith("AAPL_") and f.endswith(".csv")]
if not file_list:
    print("ERROR: No AAPL CSV found in /tmp")
    exit(1)
FILE_NAME = sorted(file_list)[-1]

def upload():
    print("DEBUG: Bucket  =", BUCKET)
    print("DEBUG: File    =", FILE_NAME)
    s3 = boto3.client("s3")
    try:
        s3.upload_file(f"/tmp/{FILE_NAME}", BUCKET, FILE_NAME)
        print(f"Uploaded {FILE_NAME} to s3://{BUCKET}/{FILE_NAME}")
    except Exception as e:
        print("ERROR: upload failed:", e)
        exit(1)

if __name__ == "__main__":
    upload()

