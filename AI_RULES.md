# Tech Stack

- **Language:** Go (module `verdent`, requires Go 1.24+)
- **Architecture:** Single-binary HTTP server; no framework — uses only `net/http` from stdlib
- **Entry point:** `cmd/server/main.go` → calls `internal/app.Main()`
- **All business logic lives in:** `internal/app/` (flat package, no sub-packages)
- **Configuration:** Environment variables + optional `.env` file (loaded at startup via `loadEnvFile`)
- **No external Go dependencies** — go.mod has none; use stdlib only unless a dep is explicitly added
- **Dashboard UI:** Single-file inline HTML (`internal/app/dashboard_html.go`) served at `/`; no separate frontend build step
- **API surface:** OpenAI-compatible (`/v1/chat/completions`), Anthropic-compatible (`/v1/messages`), and a custom Responses endpoint (`/v1/responses`)

# Rules

## Go conventions
- All new Go files go in `internal/app/`; add a new `cmd/` entry point only for a new binary
- Package name is always `app` inside `internal/app/`
- No `var` block globals for mutable state — use struct fields on `Server` or `AccountPool`
- Error strings lowercase, no trailing period (Go stdlib convention)
- Use `context.WithTimeout` for every outbound network call; never block indefinitely

## Libraries
- **HTTP routing:** `net/http` stdlib `ServeMux` — do NOT introduce gorilla/mux, chi, gin, echo, or any other router
- **JSON:** `encoding/json` stdlib only
- **Logging:** `log` stdlib only — no zap, logrus, zerolog, etc.
- **HTTP client:** `net/http` stdlib — no resty, got, etc.
- **Environment / config:** `os.Getenv` + the existing `loadEnvFile` helper — no viper, godotenv, etc.
- **Testing:** `testing` stdlib — no testify unless already present
- **No ORM, no database driver** — this service is stateless except for in-memory conversation history

## Dashboard / frontend
- The dashboard is a self-contained HTML string in `dashboard_html.go`; keep it that way
- Inline CSS and vanilla JS only — no npm, no bundler, no React
- Template variables injected via `strings.ReplaceAll` (`__HOST__`, `__AUTH_TOKEN__`)

## Security
- Auth middleware (`withAuth`) must wrap every `/v1/` and `/api/` route
- Never log full tokens or JWTs — truncate or omit
- Validate and limit request body size with `http.MaxBytesReader` before reading
- Reject non-UTF-8 request bodies before JSON decode (already done in `handleChatCompletions`; apply same pattern elsewhere)
