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
