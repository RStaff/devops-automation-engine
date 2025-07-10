#!/usr/bin/env bash
set -e

echo "🔍 Initializing Terraform and planning..."
terraform init -input=false
terraform plan -out=tfplan -input=false

echo "✅ Terraform plan complete. Saved to tfplan."
