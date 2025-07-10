#!/usr/bin/env bash
set -e

echo "💣 Destroying Terraform-managed infrastructure..."
terraform destroy -auto-approve

echo "✅ Terraform destroy complete."
