// pages/api/check-session.js
import { PrismaClient } from "@prisma/client"

const prisma = new PrismaClient()

export default async function handler(req, res) {
  const { session_id } = req.query

  if (!session_id) {
    return res.status(400).json({ error: "Missing session_id" })
  }

  const order = await prisma.order.findUnique({
    where: { stripeSessionId: session_id },
  })

  if (!order) {
    return res.status(404).json({ error: "Order not found" })
  }

  return res.status(200).json(order)
}
