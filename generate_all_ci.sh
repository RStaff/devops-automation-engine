#!/bin/bash

# List your pipeline directories (no trailing slashes)
PIPELINES=(
  ad_analytics_pipeline
  chatbot_pipeline
  content_creation_pipeline
  content_personalization_pipeline
  email_campaign_pipeline
  iac_pipeline
  ingestion_pipeline
  landing_page_pipeline
  lead_generation_pipeline
  marketing_campaign_pipeline
  mlops_pipeline
  mobile_pipeline
  robotics_pipeline
  social_media_pipeline
  website_pipeline
)

mkdir -p .github/workflows

for pipeline in "${PIPELINES[@]}"; do
  # Strip "_pipeline" for friendly display name (optional)
  FRIENDLY=$(echo "$pipeline" | sed -E 's/_pipeline$//' | sed -E 's/(^|_)([a-z])/\U\2/g' | sed 's/_/ /g')
  cat > .github/workflows/ci-$pipeline.yml <<EOF
name: CI – $FRIENDLY Pipeline

on:
  push:
    paths:
      - '$pipeline/**'

permissions:
  contents: read
  id-token: write

env:
  GCP_PROJECT: \${{ secrets.GCP_PROJECT }}
  GCP_REGION:  \${{ secrets.GCP_REGION }}

jobs:
  run:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Authenticate to GCP
        uses: google-github-actions/auth@v1
        with:
          credentials_json: \${{ secrets.GCP_SA_JSON }}
          project_id:      \${{ env.GCP_PROJECT }}

      - name: Set up gcloud CLI
        uses: google-github-actions/setup-gcloud@v2
        with:
          project_id: \${{ env.GCP_PROJECT }}

      - name: Extract raw data
        run: bash $pipeline/extract.sh

      - name: Transform data
        run: bash $pipeline/transform.sh

      - name: Load into target
        run: bash $pipeline/load.sh
EOF

  echo "✅ Created: .github/workflows/ci-$pipeline.yml"
done

echo "🚀 All CI workflows generated. Review, git add, commit, and push to enable!"

