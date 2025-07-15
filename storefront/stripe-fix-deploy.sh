#!/usr/bin/env bash
# stripe-fix-deploy.sh
# Automated patch + deploy for Stripe checkout flow on Vercel

set -euo pipefail

# 1. Ensure NEXT_PUBLIC_APP_URL is set
if [[ -z "${NEXT_PUBLIC_APP_URL:-}" ]]; then
  echo "ERROR: NEXT_PUBLIC_APP_URL must be set (locally or in Vercel env)."
  exit 1
fi

# 2. Overwrite the checkout-session API with the fixed version
cat > pages/api/create-checkout-session.js <<EOF
import Stripe from 'stripe';
const stripe = new Stripe(process.env.STRIPE_SECRET_KEY);

export default async function handler(req, res) {
  const YOUR_DOMAIN = process.env.NEXT_PUBLIC_APP_URL;
  
  try {
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
    
    res.status(200).json({ url: session.url });
  } catch (err) {
    console.error('Stripe checkout error:', err);
    res.status(500).json({ error: 'Checkout session creation failed' });
  }
}
EOF

echo "✔️  Patched create-checkout-session.js"

# 3. Ensure success page is in place
cat > public/success.html <<EOF
<!DOCTYPE html>
<html><body>
  <h1>🎉 Success!</h1>
  <p>Your purchase is complete. Download your agent bundle here:</p>
  <a href="/downloads/https://your-bucket.s3.amazonaws.com/agent_v2.zip" download>Download https://your-bucket.s3.amazonaws.com/agent_v2.zip</a>
</body></html>
EOF

echo "✔️  Ensured public/success.html exists"

# 4. Commit & push
git add pages/api/create-checkout-session.js public/success.html
git commit -m "fix: patch Stripe checkout API and ensure success page" || echo "✔️  No changes to commit"
git push origin main
echo "✔️  Changes pushed to GitHub"

# 5. Deploy on Vercel
vercel deploy --prod --yes
echo "🚀  Vercel deployment triggered"
