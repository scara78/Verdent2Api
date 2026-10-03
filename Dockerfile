# ── Build stage ──
FROM golang:1.24-alpine AS builder

WORKDIR /app

# Copy module files first for layer caching
COPY go.mod ./
RUN go mod download

# Copy source
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o verdent ./cmd/server

# ── Runtime stage ──
FROM alpine:3.20

# ca-certificates for outbound HTTPS calls
RUN apk --no-cache add ca-certificates tzdata

WORKDIR /app

COPY --from=builder /app/verdent .

EXPOSE 5084

ENTRYPOINT ["/app/verdent"]
