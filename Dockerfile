FROM rust:slim-bullseye AS builder

WORKDIR /app
COPY ./Cargo.toml ./Cargo.lock ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release

COPY ./src ./src
COPY ./web ./web
RUN cargo build --release

FROM debian:bullseye-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/target/release/pyetimes /usr/local/bin/pyetimes

EXPOSE 3000

CMD ["pyetimes"]