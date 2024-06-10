FROM golang:1.22-alpine AS builder

RUN apk upgrade --update --no-cache
COPY . /go/src/mercure
WORKDIR /go/src/mercure/caddy
RUN --mount=type=cache,mode=0755,target=/go/pkg/mod go mod tidy
WORKDIR /go/src/mercure/caddy/mercure
RUN --mount=type=cache,mode=0755,target=/go/pkg/mod go build

FROM caddy:2-alpine
ENV MERCURE_TRANSPORT_URL=bolt:///data/mercure.db

RUN apk upgrade --update --no-cache
COPY --from=builder /go/src/mercure/caddy/mercure/mercure /usr/bin/caddy
COPY --from=builder /go/src/mercure/Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /go/src/mercure/dev.Caddyfile /etc/caddy/dev.Caddyfile
