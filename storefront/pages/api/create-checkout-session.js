export const config = { runtime: 'nodejs' };

import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

const baseUrl = process.env.NEXT_PUBLIC_APP_URL.trim();

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).end();
  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: 'usd',
            product_data: { name: 'Your Product' },
            unit_amount: 5000,
          },
          quantity: 1,
        },
      ],
      mode: 'payment',
      success_url: \`\${baseUrl}/success.html\`,
      cancel_url:  \`\${baseUrl}/\`,
    });
    return res.status(200).json({ url: session.url });
  } catch (err) {
    console.error('Stripe error:', err);
    return res.status(500).json({ error: 'Stripe error', message: err.message });
  }
}
