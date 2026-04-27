FROM golang:1.25-bookworm AS builder

WORKDIR /usr/src/app

# dependencies (cache optimized)
COPY go.mod go.mod
COPY go.sum go.sum
RUN go mod download

# copy full source
COPY . .

# multi-arch support
ARG TARGETARCH

RUN CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH \
    go build -ldflags="-s -w" -o product-catalog .

# 🔥 production runtime (switch back to distroless)
FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /usr/src/app

COPY --from=builder /usr/src/app/product-catalog .

EXPOSE 8080
ENTRYPOINT ["./product-catalog"]