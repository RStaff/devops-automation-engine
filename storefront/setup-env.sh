#!/usr/bin/env bash
set -e

# Ask for your Stripe Test Publishable Key
read -p "👉  Enter your Stripe *test* publishable key (pk_test_…): " PK

# Write it into .env.local
cat << EOL > .env.local
# Next.js overrides
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=$PK
EOL
echo "✅ .env.local created"

# Make sure we never commit it
if ! grep -qxF ".env.local" .gitignore; then
  echo ".env.local" >> .gitignore
  echo "✅ Added .env.local to .gitignore"
else
  echo ".env.local already in .gitignore"
fi

echo
echo "✨ Done! Now restart dev server: npm run dev"
