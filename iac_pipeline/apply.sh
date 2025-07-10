#!/usr/bin/env bash
set -e

echo "🚀 Applying Terraform plan..."
terraform apply -input=false tfplan

echo "✅ Terraform apply complete."
