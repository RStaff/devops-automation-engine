import Stripe from 'stripe'
import { buffer } from 'micro'

export const config = {
  api: {
    // We need raw body for signature verification
    bodyParser: false,
  },
}

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY)

export default async function handler(req, res) {
  // Only accept POST
  if (req.method !== 'POST') {
    res.setHeader('Allow', 'POST')
    return res.status(405).end('Method Not Allowed')
  }

  // Retrieve the raw body as a buffer
  const buf = await buffer(req)
  const sig = req.headers['stripe-signature']

  let event
  try {
    event = stripe.webhooks.constructEvent(
      buf.toString(),
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    )
  } catch (err) {
    console.error('⚠️  Webhook signature verification failed:', err.message)
    return res.status(400).send(`Webhook Error: ${err.message}`)
  }

  // Handle the event
  if (event.type === 'checkout.session.completed') {
    const session = event.data.object
    console.log('✅  Session completed:', session.id)
    // TODO: fulfill the purchase: e.g. save session.id into your database
  }

  // Return a 200 to acknowledge receipt of the event
  res.status(200).json({ received: true })
}
