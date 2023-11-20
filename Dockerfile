FROM alpine:latest as builder

ENV GOROOT=/usr/lib/go
ENV PATH="${GOROOT}/bin:${PATH}"
RUN apk upgrade --update --no-cache && apk add --no-cache go
WORKDIR /usr/src/mercure
COPY . .
RUN cd caddy && \
    go mod tidy && \
    cd mercure && \
    go build

FROM caddy:latest
ENV MERCURE_TRANSPORT_URL=bolt:///data/mercure.db

RUN apk upgrade --update --no-cache
COPY --from=builder /usr/src/mercure/caddy/mercure/mercure /usr/bin/caddy
COPY --from=builder /usr/src/mercure/Caddyfile /etc/caddy/Caddyfile
COPY --from=builder /usr/src/mercure/Caddyfile.dev /etc/caddy/Caddyfile.dev
