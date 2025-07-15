#!/usr/bin/env bash
set -e

API_FILE="pages/api/create-checkout-session.js"

# 1) Prepend baseUrl if it’s missing
if ! grep -q "const baseUrl = process.env.NEXT_PUBLIC_APP_URL" "$API_FILE"; then
  sed -i '' '1i\
const baseUrl = process.env.NEXT_PUBLIC_APP_URL\
' "$API_FILE"
fi

# 2) Rewrite the two URL lines
sed -i '' "s|success_url:.*|    success_url: \\\`\${baseUrl}/success.html\\\`,|g" "$API_FILE"
sed -i '' "s|cancel_url:.*|    cancel_url:  \\\`\${baseUrl}/\\\`,|g" "$API_FILE"

echo "✅ Patching done in $API_FILE"
