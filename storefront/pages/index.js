import { useState } from 'react'
import { loadStripe } from '@stripe/stripe-js'

export default function Home() {
  const [stripePromise] = useState(() =>
    loadStripe(process.env.NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY)
  )

  const handleCheckout = async () => {
    const res = await fetch('/api/create-checkout-session', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' }
    })
    if (!res.ok) throw new Error(res.status)
    const { url } = await res.json()
    const stripe = await stripePromise
    const sessionId = url.split('/').pop()
    await stripe.redirectToCheckout({ sessionId })
  }

  return (
    <div style={{ textAlign: 'center', marginTop: '4rem' }}>
      <h1>Your Product — $50.00</h1>
      <button onClick={handleCheckout} style={{ padding: '0.75rem 1.5rem', fontSize: '1rem', cursor: 'pointer' }}>
        Buy Now
      </button>
    </div>
  )
}
