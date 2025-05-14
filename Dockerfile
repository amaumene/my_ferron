FROM rust:alpine as builder

WORKDIR /app

RUN wget -O - https://api.github.com/repos/ferronweb/ferron/releases/latest | grep 'tarball_url' | cut -d '"' -f 4 | xargs wget -O ferron.tar.gz

RUN mkdir ferron

RUN tar xaf ferron.tar.gz -C ferron --strip-components=1

WORKDIR /app/ferron

RUN apk add musl-dev

RUN cargo update

RUN cargo build --release

FROM scratch

COPY --from=builder /app/ferron/target/release/ferron /usr/sbin/ferron

EXPOSE 80/tcp
EXPOSE 443/tcp

CMD ["/usr/sbin/ferron", "-c", "/etc/ferron.yaml"]
