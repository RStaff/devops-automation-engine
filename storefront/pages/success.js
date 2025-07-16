// pages/success.js
import useSWR from "swr"
import { useRouter } from "next/router"

const fetcher = (url) => fetch(url).then((res) => res.json())

export default function Success() {
  const { query } = useRouter()
  const { session_id } = query

  const { data: order, error } = useSWR(
    session_id ? `/api/check-session?session_id=${session_id}` : null,
    fetcher
  )

  if (error) return <p className="p-4 text-red-600">Failed to load order.</p>
  if (!order) return <p className="p-4">Loading…</p>

  return (
    <div className="max-w-xl mx-auto py-12 text-center">
      <h1 className="text-3xl font-bold mb-4">🎉 Thank you for your purchase!</h1>
      <p className="mb-2">
        <strong>Session ID:</strong> {order.stripeSessionId}
      </p>
      <p className="mb-2">
        <strong>Amount paid:</strong> ${(order.amountTotal / 100).toFixed(2)}
      </p>
      <p className="mb-2">
        <strong>Receipt sent to:</strong> {order.customerEmail}
      </p>
    </div>
  )
}
