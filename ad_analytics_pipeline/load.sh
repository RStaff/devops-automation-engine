#!/usr/bin/env bash
set -euo pipefail
bq --project_id=$GCP_PROJECT load \
  --source_format=NEWLINE_DELIMITED_JSON \
  $GCP_PROJECT:ad_analytics.ads \
  ad_analytics_pipeline/processed/ads.ldjson \
  _PARSE_JSON:STRING
