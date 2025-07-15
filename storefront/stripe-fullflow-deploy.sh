#!/usr/bin/env bash
# stripe-fullflow-deploy.sh
# Patches backend + frontend for Stripe checkout, commits, and deploys on Vercel

set -euo pipefail

# 1. Verify domain
: "${NEXT_PUBLIC_APP_URL:?Must set NEXT_PUBLIC_APP_URL env var}"

# 2. Patch the API route
cat > pages/api/create-checkout-session.js <<PATCH
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export default async function handler(req, res) {
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method Not Allowed' });
  }
  const YOUR_DOMAIN = process.env.NEXT_PUBLIC_APP_URL;

  const session = await stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    line_items: [{
      price_data: {
        currency: 'usd',
        product_data: { name: 'Agent Bundle' },
        unit_amount: 500,
      },
      quantity: 1,
    }],
    mode: 'payment',
    success_url: \`\${YOUR_DOMAIN}/success.html\`,
    cancel_url: \`\${YOUR_DOMAIN}/\`,
  });

  return res.status(200).json({ url: session.url });
}
PATCH
echo "✔️  API patched"

# 3. Patch the front-end page
cat > pages/index.js <<PAGE
import React from 'react';

export default function Home() {
  const handleCheckout = async () => {
    const res = await fetch('/api/create-checkout-session', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    });
    if (!res.ok) {
      const err = await res.json().catch(() => ({ error: res.status }));
      return alert('Checkout failed: ' + err.error);
    }
    const { url } = await res.json();
    window.location = url;
  };

  return (
    <div style={{ padding: '2rem', fontFamily: 'sans-serif' }}>
      <h1>Your Product — $50.00</h1>
      <button onClick={handleCheckout}>Buy Now</button>
    </div>
  );
}
PAGE
echo "✔️  Front-end patched"

# 4. Ensure the static success page
mkdir -p public
cat > public/success.html <<PAGE
<!DOCTYPE html>
<html><body>
  <h1>🎉 Success!</h1>
  <p>Your purchase is complete. Download your agent bundle here:</p>
  <a href="/downloads/agent.zip" download>Download agent.zip</a>
</body></html>
PAGE
echo "✔️  success.html in place"

# 5. Commit & push
git add pages/api/create-checkout-session.js pages/index.js public/success.html
git commit -m "chore: fix Stripe checkout flow + frontend + success page" || echo "✔️  No changes to commit"
git push origin main
echo "✔️  Pushed to GitHub"

# 6. Deploy to Vercel
vercel deploy --prod --yes
echo "🚀  Vercel deployment triggered"
