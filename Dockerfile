# Stage 1: build
FROM golang:1.22.3-alpine3.20 AS builder
LABEL maintainer="Hover Huang <hoverhuang@outlook.com>"
WORKDIR /opt
COPY . .
RUN CGO_ENABLED=0 go build -ldflags "--extldflags '-static -s -w'" -o /opt/promremotecli cmd/promremotecli/main.go
# Stage 2: lightweight "release"
FROM debian:trixie
LABEL maintainer="Hover Huang <hoverhuang@outlook.com>"
WORKDIR /opt
COPY --from=builder /opt/promremotecli /opt/promremotecli
ENTRYPOINT ["/opt/promremotecli"]
