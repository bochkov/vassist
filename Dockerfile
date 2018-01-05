FROM alpine:latest AS builder1
RUN apk add --no-cache git build-base cmake linux-headers
RUN git clone https://github.com/bochkov/cxxgrad.git /cxxgrad
WORKDIR /cxxgrad
RUN make

FROM nimlang/nim:alpine AS builder2
RUN apk add --no-cache build-base
COPY src .
RUN nimble install jester -y
RUN nim c -d:release app.nim

FROM alpine:latest
RUN apk add --no-cache pcre-dev && ln -s /usr/lib/libpcre.so /usr/lib/libpcre.so.3
RUN mkdir /vassist
WORKDIR /vassist
COPY --from=builder1 /cxxgrad/cmake-build/libthermo.so /usr/lib/libthermo.so
COPY --from=builder2 app .
COPY public ./public
EXPOSE 5000
CMD ["./app"]