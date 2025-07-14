// pages/index.js
import React from 'react';

export default function Home() {
  const handleCheckout = async () => {
    const res = await fetch('/api/create-checkout-session', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
    });
    if (!res.ok) {
      const { error } = await res.json().catch(() => ({ error: res.status }));
      return alert('Checkout failed: ' + error);
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

