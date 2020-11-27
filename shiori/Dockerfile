# build stage
FROM golang:alpine AS builder
RUN apk add --no-cache build-base git
# Prevent errors from screwing up build process
RUN go get -u -v github.com/go-shiori/shiori ; exit 0
WORKDIR /go/src/github.com/go-shiori/shiori
RUN go build

# server image
FROM alpine:latest
COPY --from=builder /go/src/github.com/go-shiori/shiori/shiori /usr/local/bin/
ENV SHIORI_DIR /srv/shiori/
VOLUME /srv/shiori/
EXPOSE 8080
CMD ["/usr/local/bin/shiori", "serve"]

# docker build . -t fth/shiori
