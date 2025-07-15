import { buffer } from "micro"
import Stripe from "stripe"
import { PrismaClient } from "@prisma/client"

// Disable Next.js’s built-in body parsing so we can verify the raw Stripe signature
export const config = {
  api: { bodyParser: false }
}

const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, {
  apiVersion: "2024-09-30"
})
const prisma = new PrismaClient()

export default async function handler(req, res) {
  if (req.method !== "POST") {
    res.setHeader("Allow", "POST")
    return res.status(405).end("Method Not Allowed")
  }

  const sig = req.headers["stripe-signature"]
  const buf = await buffer(req)

  let event
  try {
    event = stripe.webhooks.constructEvent(
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

    // Persist to your DB
    await prisma.order.create({
      data: {
        stripeSessionId: session.id,
        amountTotal: session.amount_total,
        customerEmail: session.customer_email
      }
    })
  }

  res.status(200).json({ received: true })
}
