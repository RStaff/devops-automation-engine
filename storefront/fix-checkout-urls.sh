#!/usr/bin/env bash
API_FILE="pages/api/create-checkout-session.js"
grep -q "process.env.NEXT_PUBLIC_APP_URL.trim()" "$API_FILE" || sed -i '' '1s#^#const baseUrl = process.env.NEXT_PUBLIC_APP_URL.trim()\n#' "$API_FILE"
sed -i '' 's#const baseUrl = process.env.NEXT_PUBLIC_APP_URL#const baseUrl = process.env.NEXT_PUBLIC_APP_URL.trim()#g' "$API_FILE"
sed -i '' 's#success_url:.*#      success_url: \`${baseUrl}/success.html\`,#g' "$API_FILE"
sed -i '' 's#cancel_url:.*#      cancel_url:  \`${baseUrl}/\`,#g' "$API_FILE"
git add "$API_FILE"
git commit -m "fix(api): trim NEXT_PUBLIC_APP_URL and update checkout URLs"
npx vercel --prod --yes
