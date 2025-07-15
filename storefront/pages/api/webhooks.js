import Stripe from 'stripe'
import { buffer } from 'micro'
import { PrismaClient } from '@prisma/client'

export const config = {
  api: {
    // we need the raw body to verify Stripe’s signature
    bodyParser: false,
  },
}

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY)
const prisma = new PrismaClient()

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST')
    return res.status(405).end('Method Not Allowed')
  }

  // 1) Read raw body
  const buf = await buffer(req)
  const sig = req.headers['stripe-signature']

  // 2) Verify signature
  let event
  try {
    event = stripe.webhooks.constructEvent(
      buf.toString(),
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    )
  } catch (err) {
    console.error('⚠️ Webhook signature verification failed:', err.message)
    return res.status(400).send(`Webhook Error: ${err.message}`)
  }

  // 3) Handle the event
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object
    console.log('✅  Session completed:', session.id)

    // 4) Persist to your database
    await prisma.order.create({
      data: {
        stripeSessionId: session.id,
        amountTotal: session.amount_total,
        customerEmail: session.customer_email,
      },
    })
  }

  // 5) Return a 200 to Stripe
  res.status(200).json({ received: true })
}
