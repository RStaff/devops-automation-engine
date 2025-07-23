#!/usr/bin/env bash
set -euo pipefail

# 1) Start Next.js in the background
echo -e "\n🚀 Starting Next.js dev server…"
npm run dev &  
NEXT_PID=$!

# 2) Wait briefly for the server to boot
sleep 3

# 3) Start Stripe CLI to forward events
echo -e "\n🔔 Listening for Stripe webhooks…"
stripe listen \
  --forward-to http://localhost:3000/api/webhooks \
  --events checkout.session.completed &  
STRIPE_PID=$!

# 4) Trigger a Checkout Session event
echo -e "\n🧪 Triggering test checkout.session.completed…"
stripe trigger checkout.session.completed

# 5) Wait a moment for the handler to write to DB
sleep 2

# 6) List orders in your DB
echo -e "\n📋 Listing orders:"
./scripts/list-orders.js

# 7) Tear everything down
echo -e "\n🛑 Shutting down background processes…"
kill $NEXT_PID $STRIPE_PID
