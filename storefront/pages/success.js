import { useRouter } from 'next/router'
import useSWR from 'swr'

const fetcher = url => fetch(url).then(r => r.json())

export default function SuccessPage() {
  const { query } = useRouter()
  const { data, error } = useSWR(
    () => query.session_id ? `/api/check-session?session_id=${query.session_id}` : null,
    fetcher
  )

  if (error) return <p>Failed to load order.</p>
  if (!data)  return <p>Loading…</p>

  return (
    <div className="max-w-lg mx-auto p-8">
      <h1 className="text-2xl font-bold mb-4">Thank you, {data.customer_email}!</h1>
      <p>Your purchase of <strong>{data.amount_total / 100} USD</strong> is confirmed.</p>
      <a
        href={data.download_url}
        className="mt-6 inline-block bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700"
      >
        Download your file
      </a>
    </div>
  )
}
