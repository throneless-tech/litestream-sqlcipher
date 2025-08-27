FROM golang:bookworm as builder

WORKDIR /src/litestream
COPY . .

ARG LITESTREAM_VERSION=latest
RUN apt update && apt install -y libssl-dev libsqlcipher-dev
RUN --mount=type=cache,target=/root/.cache/go-build \
	--mount=type=cache,target=/go/pkg \
	go build -ldflags "-s -w -X 'main.Version=${LITESTREAM_VERSION}' -extldflags '-static -lcrypto'" -tags libsqlcipher,osusergo,netgo,sqlite_omit_load_extension -o /usr/local/bin/litestream ./cmd/litestream


FROM alpine:3
COPY --from=builder /usr/local/bin/litestream /usr/local/bin/litestream
ENTRYPOINT ["/usr/local/bin/litestream"]
CMD []
