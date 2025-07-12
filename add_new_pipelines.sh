#!/bin/bash

# === NEW PIPELINES TO ADD ===
NEW_PIPELINES=(
  billing_pipeline
  accounting_pipeline
  crm_pipeline
  project_management_pipeline
  hr_pipeline
  reporting_pipeline
  analytics_pipeline
  marketing_automation_pipeline
  integrations_pipeline
  ai_ml_pipeline
  security_backup_pipeline
  support_pipeline
  inventory_pipeline
  compliance_pipeline
  subscription_pipeline
  ecommerce_pipeline
  api_gateway_pipeline
)

echo "🚀 Adding new pipelines if missing..."

for pipeline in "${NEW_PIPELINES[@]}"; do
  # 1. Create directory if it doesn't exist
  if [[ ! -d "$pipeline" ]]; then
    mkdir "$pipeline"
    echo "✅ Created directory: $pipeline"
  else
    echo "⏩ Directory exists: $pipeline"
  fi

  # 2. Create stub scripts if missing
  for step in extract.sh transform.sh load.sh; do
    if [[ ! -f "$pipeline/$step" ]]; then
      echo "#!/bin/bash
# $step for $pipeline
echo '[$pipeline] $step running...'
" > "$pipeline/$step"
      chmod +x "$pipeline/$step"
      echo "  - Added $pipeline/$step"
    fi
  done

  # 3. Create matching CI YAML if missing
  YAML=".github/workflows/ci-${pipeline}.yml"
  if [[ ! -f "$YAML" ]]; then
    mkdir -p .github/workflows
    cat > "$YAML" <<EOF
name: CI – ${pipeline//_/ } Pipeline

on:
  push:
    paths:
      - '${pipeline}/**'

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
        run: bash ${pipeline}/extract.sh

      - name: Transform data
        run: bash ${pipeline}/transform.sh

      - name: Load into target
        run: bash ${pipeline}/load.sh
EOF
    echo "  - Created $YAML"
  fi
done

echo ""
echo "🎉 All requested new pipelines created and integrated into CI!"
echo "👉 Next: git add .github/workflows/ci-*.yml *_pipeline/*/*.sh"

