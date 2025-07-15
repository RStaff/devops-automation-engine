import Stripe from "stripe"
import { buffer } from "micro"

export const config = { api: { bodyParser: false } }

import { buffer } from 'micro'

export const config = {
  api: {
    bodyParser: false,
  },
}
import { buffer } from 'micro'
import Stripe from 'stripe'

export const config = {
  api: {
    bodyParser: false
  }
}

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY)

export default async function handler(req, res) {
  if (req.method !== "POST") {
    res.setHeader("Allow", "POST")
    return res.status(405).end("Method Not Allowed")
  }

  let event
  try {
    const buf = await buffer(req)
    const sig = req.headers["stripe-signature"]
    event = new Stripe(process.env.STRIPE_SECRET_KEY).webhooks.constructEvent(
      buf.toString(),
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    )
  } catch (err) {
    console.error("⚠️  Webhook signature verification failed:", err.message)
    return res.status(400).send(`Webhook Error: ${err.message}`)
  }

  if (event.type === "checkout.session.completed") {
    const session = event.data.object
    console.log("✅  Session completed:", session.id)
    // TODO: fulfill order, e.g. save session.id to your DB
  }

  res.status(200).json({ received: true })
}
eq, res) {
  if (req.method !== 'POST') return res.status(405).end('Method Not Allowed')

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
    return res.status(400).send(`Webhook Error: ${err.message}`)
  }

  if (event.type === 'checkout.session.completed') {
    const session = event.data.object
    // TODO: fulfill order, e.g. save session.id to your DB
  }

  res.status(200).json({ received: true })
}
