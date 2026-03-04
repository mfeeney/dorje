import { useEffect, useState } from "react"

function App() {
  const [health, setHealth] = useState<"loading" | "ok" | "error">("loading")

  useEffect(() => {
    fetch("/api/health")
      .then((res) => res.json())
      .then((data) => setHealth(data.status === "ok" ? "ok" : "error"))
      .catch(() => setHealth("error"))
  }, [])

  return (
    <div className="bg-background text-foreground flex min-h-screen flex-col items-center justify-center">
      <h1 className="mb-4 text-4xl font-bold tracking-tight">Dorje</h1>
      <p className="text-muted-foreground mb-8">Personal AI Assistant</p>
      <div className="flex items-center gap-2 rounded-md border px-4 py-2 text-sm">
        <span
          className={`inline-block h-2 w-2 rounded-full ${
            health === "ok"
              ? "bg-green-500"
              : health === "error"
                ? "bg-red-500"
                : "animate-pulse bg-yellow-500"
          }`}
        />
        <span>
          API:{" "}
          {health === "loading"
            ? "connecting..."
            : health === "ok"
              ? "connected"
              : "disconnected"}
        </span>
      </div>
    </div>
  )
}

export default App
