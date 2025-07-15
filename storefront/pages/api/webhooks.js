// pages/api/webhooks.js

import { buffer } from 'micro'
import Stripe from 'stripe'
import { PrismaClient } from '@prisma/client'

export const config = {
  api: {
    // Disable Next.js body parsing so we can verify raw body
    bodyParser: false,
  },
}

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY)
const prisma = new PrismaClient()

export default async function handler(req, res) {
  // 1) Only accept POST
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST')
    return res.status(405).end('Method Not Allowed')
  }

  // 2) Retrieve the raw body & Stripe signature header
  const buf = await buffer(req)
  const sig = req.headers['stripe-signature']

  let event
  try {
    // 3) Verify signature
    event = stripe.webhooks.constructEvent(
      buf.toString(),
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    )
  } catch (err) {
    console.error('⚠️  Webhook signature verification failed:', err.message)
    return res.status(400).send(`Webhook Error: ${err.message}`)
  }

  // 4) Handle the event
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object
    console.log('✅  Checkout session completed:', session.id)

    // 5) Persist to your database
    try {
      await prisma.order.create({
        data: {
          stripeSessionId: session.id,
          amountTotal: session.amount_total,
          customerEmail: session.customer_email,
        },
      })
      console.log('💾  Order saved:', session.id)
    } catch (dbErr) {
      console.error('❌  Failed to save order:', dbErr)
      // You might choose to retry or alert here
    }
  }

  // 6) Return a 200 to acknowledge receipt
  res.status(200).json({ received: true })
}

