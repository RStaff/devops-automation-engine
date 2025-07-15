import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY, { apiVersion: '2022-11-15' });

export default async function handler(req, res) {
  console.log('👉 received', req.method, req.url);
  if (req.method !== 'POST') {
    return res.status(405).end();
  }
  try {
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
    });
    return res.status(200).json({ url: session.url });
  } catch (err) {
    console.error('⚠️ stripe error:', err);
    return res.status(500).json({ error: 'Internal error' });
  }
}
