#!/usr/bin/env bash
set -e

API_FILE="pages/api/create-checkout-session.js"

# 1) Inject a baseUrl line just inside the handler if it isn't already present
grep -q "const baseUrl" "$API_FILE" || sed -i '' 's|export default async function handler(req, res) {|export default async function handler(req, res) {\n  const baseUrl = process.env.NEXT_PUBLIC_APP_URL?.trim() || req.headers.origin;|' "$API_FILE"

# 2) Replace the two URL lines
sed -i '' 's|success_url:.*|      success_url: `${baseUrl}/success.html`,|' "$API_FILE"
sed -i '' 's|cancel_url:.*|      cancel_url:  `${baseUrl}/`,|' "$API_FILE"

echo "✅ Applied checkout‐URL patch to $API_FILE"
