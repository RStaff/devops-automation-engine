#!/usr/bin/env bash
set -e

API_FILE="pages/api/webhooks.js"

# 1) Ensure file exists
if [[ ! -f "$API_FILE" ]]; then
  echo "❌ $API_FILE not found!"
  exit 1
fi

# 2) Insert imports & disable bodyParser at top (idempotent)
grep -q "export const config = { *api: { *bodyParser: false" "$API_FILE" || \
  sed -i '' '1s#^#import Stripe from "stripe"\nimport { buffer } from "micro"\n\nexport const config = { api: { bodyParser: false } }\n\n#' "$API_FILE"

# 3) Replace existing handler entirely with the webhook-ready version
#    (This will stomp whatever was there before.)
sed -i '' 's#export default async function handler(. *#export default async function handler(req, res) {\n  if (req.method !== "POST") {\n    res.setHeader("Allow", "POST")\n    return res.status(405).end("Method Not Allowed")\n  }\n\n  let event\n  try {\n    const buf = await buffer(req)\n    const sig = req.headers["stripe-signature"]\n    event = new Stripe(process.env.STRIPE_SECRET_KEY).webhooks.constructEvent(\n      buf.toString(),\n      sig,\n      process.env.STRIPE_WEBHOOK_SECRET\n    )\n  } catch (err) {\n    console.error("⚠️  Webhook signature verification failed:", err.message)\n    return res.status(400).send(\`Webhook Error: \${err.message}\`)\n  }\n\n  if (event.type === "checkout.session.completed") {\n    const session = event.data.object\n    console.log("✅  Session completed:", session.id)\n    // TODO: fulfill order, e.g. save session.id to your DB\n  }\n\n  res.status(200).json({ received: true })\n}\n#' "$API_FILE"

echo "✅ Patched $API_FILE"
