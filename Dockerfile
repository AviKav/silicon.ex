
# TODO: Add support for building DEV or PROD environment images.

ARG ALPINE_VERSION=3.18
ARG ALPINE_PATCH_VER=4

ARG RUST_VERSION=1.75.0
ARG ELIXIR_VERSION=1.16.0
ARG OTP_VERSION=26.2.1

ARG RUST_BUILDER="rust:${RUST_VERSION}-alpine${ALPINE_VERSION}"
ARG ELIXIR_BUILDER="hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION}.${ALPINE_PATCH_VER}"
ARG RUNNER_IMAGE="alpine:${ALPINE_VERSION}"

########
# Rust Builder using Cargo Chef
########
FROM ${RUST_BUILDER} AS chef
WORKDIR /usr/src/silicon_nif
RUN apk add --no-cache musl-dev # Necessary for building _BOTH_ cargo-chef and libsodium NIF
RUN cargo install cargo-chef

FROM chef AS planner
COPY native/silicon_nif .
RUN cargo chef prepare --recipe-path recipe.json

FROM planner AS nif
ENV RUSTFLAGS="-C target-feature=-crt-static"
ENV CARGO_TARGET_DIR=build
RUN apk add --no-cache fontconfig-dev \
    g++ \
    python3 \
    pkgconfig \
    harfbuzz-dev;
COPY --from=planner /usr/src/silicon_nif/recipe.json recipe.json
# NOTE: Rust dependencies are built with the chef cook command below, ensure all
# required Rust NIF compile-time dependencies are installed *BEFORE* this command
RUN cargo chef cook --release --recipe-path recipe.json
COPY native/silicon_nif .
RUN cargo build --release

########
# Elixir Builder
########
FROM ${ELIXIR_BUILDER} AS elixir
WORKDIR /usr/bin/silicon
ENV NIF_LOAD_PATH=priv/libsilicon_nif
COPY --from=nif /usr/src/silicon_nif/build/release/libsilicon_nif.so priv/libsilicon_nif.so
RUN mix local.hex --force
COPY mix.exs mix.lock .
RUN mix do deps.get, deps.compile
COPY . .
RUN mix release --path release

########
# Runner
########
FROM ${RUNNER_IMAGE}
WORKDIR /usr/bin/silicon
COPY --from=elixir /usr/bin/silicon/release .

# Install Rust NIF runtime dependencies
RUN apk upgrade --no-cache & apk add --no-cache \
  harfbuzz-dev;

CMD ["bin/silicon", "start"]
