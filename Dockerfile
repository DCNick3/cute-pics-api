# syntax = docker/dockerfile:1.2

FROM clux/muslrust:stable as build
# Build application
COPY src/ ./src
COPY Cargo.toml Cargo.lock ./

RUN --mount=type=cache,target=/root/.cargo/registry --mount=type=cache,target=/volume/target \
    cargo b --profile ship --target x86_64-unknown-linux-musl && \
    cp target/x86_64-unknown-linux-musl/ship/cute-pics-api cute-pics-api

FROM bash AS get-tini

# Add Tini init-system
ENV TINI_VERSION v0.19.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /tini
RUN chmod +x /tini

FROM gcr.io/distroless/static

LABEL org.opencontainers.image.source https://github.com/DCNick3/cute-pics-api
EXPOSE 8080

COPY --from=get-tini /tini /tini
COPY --from=build /volume/cute-pics-api /cute-pics-api
COPY cute_pics /cute_pics

ENTRYPOINT ["/tini", "--", "/cute-pics-api"]