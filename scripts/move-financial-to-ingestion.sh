#!/usr/bin/env bash
set -euo pipefail

# 1. Ensure we’re at repo root
cd "$(git rev-parse --show-toplevel)"

# 2. Create ingestion_pipeline directory
mkdir -p ingestion_pipeline

# 3. Move financial_pipeline under ingestion_pipeline
if [ -d financial_pipeline ] && [ ! -d ingestion_pipeline/financial_pipeline ]; then
  git mv financial_pipeline ingestion_pipeline/financial_pipeline
fi

# 4. Update all workflows to point at the new path
for wf in .github/workflows/*.yml; do
  sed -i.bak \
    -e 's|\(pipeline-dir:\s*\)financial_pipeline|\1ingestion_pipeline/financial_pipeline|g' \
    "$wf"
  rm -f "${wf}.bak"
done

# 5. Stage, commit and push
git add ingestion_pipeline .github/workflows
git commit -m "chore: move financial_pipeline into ingestion_pipeline and update workflows"
git push origin main
