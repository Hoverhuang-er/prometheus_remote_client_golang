# Stage 1: build golang binary
FROM golang:1.22.3-alpine3.20 AS builder
LABEL maintainer="Hover Huang <hoverhuang@outlook.com>"
WORKDIR /opt
COPY . .
RUN CGO_ENABLED=0 go build -ldflags "--extldflags '-static -s -w'" -o /opt/promremotecli cmd/promremotecli/main.go
# Stage 2: promremotecli "release"
FROM debian:trixie
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.8.3 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=builder /opt/promremotecli /opt/promremotecli
LABEL maintainer="Hover Huang <hoverhuang@outlook.com>"
WORKDIR /opt
COPY --from=builder /opt/promremotecli /opt/promremotecli
ENTRYPOINT ["/opt/promremotecli"]
