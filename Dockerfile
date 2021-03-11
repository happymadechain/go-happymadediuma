# Build Ghpmc in a stock Go builder container
FROM golang:1.12-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git

ADD . /go-happymadediuma
RUN cd /go-happymadediuma && make ghpmc

# Pull Ghpmc into a second stage deploy alpine container
FROM alpine:latest

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-happymadediuma/build/bin/ghpmc /usr/local/bin/

EXPOSE 7364 7365 33860 33860/udp
ENTRYPOINT ["ghpmc"]
