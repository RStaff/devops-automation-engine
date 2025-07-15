#!/usr/bin/env bash
set -e

# 1) Overwrite pages/index.js
cat > pages/index.js << 'PAGE'
export default function Home() {
  const handleCheckout = async () => {
    const res = await fetch('/api/create-checkout-session', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    });
    if (!res.ok) {
      alert(\`Checkout failed: \${res.status}\`);
      return;
    }
    const { url } = await res.json();
    window.location.href = url;
  };

  return (
    <div style={{ textAlign: 'center', marginTop: '4rem' }}>
      <h1>Your Product — $50.00</h1>
      <button
        onClick={handleCheckout}
        style={{ padding: '0.75rem 1.5rem', fontSize: '1rem', cursor: 'pointer' }}
      >
        Buy Now
      </button>
    </div>
  );
}
PAGE

# 2) Overwrite the API route
cat > pages/api/create-checkout-session.js << 'API'
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);
export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method Not Allowed' });
  const DOMAIN = process.env.NEXT_PUBLIC_APP_URL;
  try {
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      line_items: [{
        price_data: {
          currency: 'usd',
          product_data: { name: 'Agent Bundle' },
          unit_amount: 500
        },
        quantity: 1
      }],
      mode: 'payment',
      success_url: \`\${DOMAIN}/success.html\`,
      cancel_url: \`\${DOMAIN}/\`
    });
    res.status(200).json({ url: session.url });
  } catch {
    res.status(500).json({ error: 'Checkout session creation failed' });
  }
}
API

# 3) Ensure success.html
cat > public/success.html << 'PAGE'
<!DOCTYPE html>
<html>
  <body style="text-align:center;margin-top:4rem">
    <h1>🎉 Success!</h1>
    <p>Your purchase is complete. Download here:</p>
    <a href="/downloads/agent.zip" download>Download agent.zip</a>
  </body>
</html>
PAGE

# 4) Install Stripe client and server SDKs
npm install stripe @stripe/stripe-js

# 5) Commit & deploy
git add pages/index.js pages/api/create-checkout-session.js public/success.html package.json package-lock.json
git commit -m "chore: wire up POST-only Stripe Checkout + success page"
vercel --prod --yes
