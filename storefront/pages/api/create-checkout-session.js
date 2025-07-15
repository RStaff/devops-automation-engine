import Stripe from 'stripe'
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY)
export default async (req, res) => {
  if (req.method !== 'POST') return res.status(405).end()
  const session = await stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    line_items: [{
      price_data: {
        currency: 'usd',
        product_data: { name: 'Your Product' },
        unit_amount: 5000
      },
      quantity: 1
    }],
    mode: 'payment',
    success_url: `${req.headers.origin}/success.html`,
    cancel_url: `${req.headers.origin}/`
  })
  res.status(200).json({ url: session.url })
}
