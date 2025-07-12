#!/usr/bin/env bash
set -euo pipefail

# ─── Variables ────────────────────────────────────────────────────────────────
GCP_PROJECT="adlink-agent-demo"     # your GCP project ID
GCP_REGION="us-central1"            # your GCP region
SA_JSON="sa.json"                   # path to your downloaded JSON key

# ─── 1) Encode service account key ──────────────────────────────────────────
echo "Encoding \$SA_JSON…"
SA_B64=\$(base64 < "\$SA_JSON" | tr -d '\n')

# ─── 2) Push GitHub Secrets ─────────────────────────────────────────────────
echo "Setting GitHub Actions secrets via gh CLI…"
gh secret set GCP_PROJECT --body "\$GCP_PROJECT"
gh secret set GCP_REGION  --body "\$GCP_REGION"
gh secret set GCP_SA_KEY  --body "\$SA_B64"

# ─── 3) Write .github/workflows/ci-template.yml ─────────────────────────────
mkdir -p .github/workflows
cat > .github/workflows/ci-template.yml << 'WORKFLOW'
# .github/workflows/ci-template.yml
on:
  workflow_call:
    secrets:
      GCP_PROJECT:
        description: 'Your GCP project ID'
        required: true
      GCP_REGION:
        description: 'Your GCP region'
        required: true
      GCP_SA_KEY:
        description: 'Base64-encoded GCP service-account JSON key'
        required: true

    inputs:
      pipeline-dir:
        description: 'Path to the pipeline directory'
        required: true
        type: string
      environment:
        description: 'Environment (dev/staging/prod)'
        required: true
        type: string
      tools:
        description: 'JSON array of tools (e.g. ["npm","docker"])'
        required: true
        type: string

jobs:
  run:
    runs-on: ubuntu-latest
    env:
      GCP_PROJECT: \${{ secrets.GCP_PROJECT }}
      GCP_REGION:  \${{ secrets.GCP_REGION }}
      GCP_SA_KEY:  \${{ secrets.GCP_SA_KEY }}

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up gcloud CLI
        uses: google-github-actions/setup-gcloud@v2
        with:
          project_id: \${{ secrets.GCP_PROJECT }}

      - name: Debug GCP_SA_KEY
        run: |
          echo "→ GCP_PROJECT=\$GCP_PROJECT"
          echo "→ GCP_REGION =\$GCP_REGION"
          echo "→ GCP_SA_KEY length: \$(echo -n "\$GCP_SA_KEY" | wc -c) bytes"

      - name: Decode & activate GCP service account
        run: |
          echo "Decoding GCP_SA_KEY…"
          echo "\$GCP_SA_KEY" \
            | tr -d '\r' \
            | base64 --decode > \$RUNNER_TEMP/sa.json

          if [[ ! -s \$RUNNER_TEMP/sa.json ]]; then
            echo "❌ \$RUNNER_TEMP/sa.json is empty—your secret didn’t decode!"
            exit 1
          fi

          echo "\$RUNNER_TEMP/sa.json size: \$(wc -c < \$RUNNER_TEMP/sa.json) bytes"
          head -n3 \$RUNNER_TEMP/sa.json

          echo "Authenticating…"
          gcloud auth activate-service-account --key-file=\$RUNNER_TEMP/sa.json
          gcloud config set project "\$GCP_PROJECT"
          gcloud config set run/region "\$GCP_REGION"

      - name: Report inputs
        run: |
          echo "Pipeline-dir = \${{ inputs.pipeline-dir }}"
          echo "Environment  = \${{ inputs.environment }}"
          echo "Tools        = \${{ inputs.tools }}"

      - name: Extract raw data
        run: bash \${{ inputs.pipeline-dir }}/extract.sh

      - name: Transform data
        run: bash \${{ inputs.pipeline-dir }}/transform.sh

      - name: Load into target
        run: bash \${{ inputs.pipeline-dir }}/load.sh
WORKFLOW

# ─── 4) Write .github/workflows/cd-ad-analytics.yml ────────────────────────
cat > .github/workflows/cd-ad-analytics.yml << 'CDWORKFLOW'
# .github/workflows/cd-ad-analytics.yml
name: Ad Analytics

on:
  push:
    paths:
      - 'ad_analytics_pipeline/**'

jobs:
  run-ad-analytics:
    uses: ./.github/workflows/ci-template.yml
    with:
      pipeline-dir: ad_analytics_pipeline
      environment: dev
      tools: '["bash"]'
    secrets:
      GCP_PROJECT: \${{ secrets.GCP_PROJECT }}
      GCP_REGION:  \${{ secrets.GCP_REGION }}
      GCP_SA_KEY:  \${{ secrets.GCP_SA_KEY }}
CDWORKFLOW

# ─── 5) Commit & push ──────────────────────────────────────────────────────
git add .github/workflows/ci-template.yml .github/workflows/cd-ad-analytics.yml
git commit -m "chore: wire up GCP auth in CI/CD workflows"
git push

echo "✅ Done! Workflows updated and secrets populated."
