#!/usr/bin/env bash
set -euo pipefail

API_FILE="pages/api/webhooks.js"
COMMIT_MSG="fix(webhooks): verify raw body & persist order via Prisma"

# 1) Ensure raw body parsing is disabled
grep -q "bodyParser: false" "$API_FILE" || sed -i '' '1s#export const config = #{&\
  api: { bodyParser: false },#' "$API_FILE"

# 2) Import PrismaClient at the top
grep -q "from '@prisma\/client'" "$API_FILE" || sed -i '' '1i\
import { PrismaClient } from "@prisma/client"\nconst prisma = new PrismaClient()\n' "$API_FILE"

# 3) Ensure Stripe import & instantiation
grep -q "new Stripe" "$API_FILE" || sed -i '' '1i\
import Stripe from "stripe"\nimport { buffer } from "micro"\nconst stripe = new Stripe(process.env.STRIPE_SECRET_KEY)\n' "$API_FILE"

# 4) After the event type check, append the DB write
PATCH_MARKER="if (event.type === 'checkout.session.completed')"
if ! grep -q "await prisma.order.create" "$API_FILE"; then
  sed -i '' "/$PATCH_MARKER/a\\
    const session = event.data.object\\
    console.log('✅ Session completed:', session.id)\\
    await prisma.order.create({ data: {\\
      stripeSessionId: session.id,\\
      amountTotal: session.amount_total,\\
      customerEmail: session.customer_email\\
    } })" "$API_FILE"
fi

# 5) Commit, push & deploy
git add "$API_FILE"
git commit -m "$COMMIT_MSG"
git push origin main
npx vercel --prod --yes

echo "✅ Webhook handler patched, committed, and deployed."
