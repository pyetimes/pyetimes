FROM rust:slim-bullseye AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
    libssl-dev \
    pkg-config

WORKDIR /app
COPY ./Cargo.toml ./Cargo.lock ./
COPY ./build.rs ./
RUN mkdir src && echo "fn main() {}" > src/main.rs
RUN cargo build --release

COPY ./src ./src
COPY ./web ./web
RUN cargo build --release

# Install sqlx-cli for migrations
RUN cargo install sqlx-cli --no-default-features --features postgres

FROM debian:bullseye-slim AS runtime

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    libssl-dev \
    pkg-config \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY --from=builder /app/target/release/pyetimes /usr/local/bin/pyetimes
COPY --from=builder /usr/local/cargo/bin/sqlx /usr/local/bin/sqlx
COPY ./migrations ./migrations
COPY ./docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

EXPOSE 3000

ENTRYPOINT ["docker-entrypoint.sh"]