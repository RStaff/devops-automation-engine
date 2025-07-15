#!/usr/bin/env bash
set -e

# 1) Write webhook handler
mkdir -p pages/api
cat > pages/api/webhooks.js << 'WEOF'
import { buffer } from 'micro'
import Stripe from 'stripe'

export const config = { api: { bodyParser: false } }

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY)

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end()

  const sig = req.headers['stripe-signature']
  const buf = await buffer(req)

  let event
  try {
    event = stripe.webhooks.constructEvent(
      buf.toString(),
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    )
  } catch (err) {
    return res.status(400).send(\`Webhook Error: \${err.message}\`)
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object
    // TODO: fulfill order (e.g. save session.id to your DB)
  }

  res.status(200).json({ received: true })
}
WEOF

# 2) Commit & push
git add pages/api/webhooks.js
git commit -m "feat(api): add Stripe webhook handler"
git push origin main

# 3) Deploy
npx vercel --prod --yes

# 4) Prompt to set the webhook secret
vercel env add STRIPE_WEBHOOK_SECRET production
