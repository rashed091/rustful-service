# Create a stage for building the application.
# version can be latest or specific like 1.73.0
ARG RUST_VERSION=latest
ARG APP_NAME="rustful"

FROM rust:${RUST_VERSION} AS builder

ARG APP_NAME

WORKDIR /app

# Install diesel CLI for migration
RUN cargo install diesel_cli --no-default-features --features postgres

# Build the application.
# Leverage a cache mount to ~/.cargo/registry
# for downloaded dependencies and a cache mount to /app/target/ for
# compiled dependencies which will speed up subsequent builds.
# Leverage a bind mount to the src directory to avoid having to copy the
# source code into the container. Once built, copy the executable to an
# output directory before the cache mounted /app/target is unmounted.
RUN --mount=type=bind,source=src,target=src \
    --mount=type=bind,source=Cargo.toml,target=Cargo.toml \
    --mount=type=bind,source=Cargo.lock,target=Cargo.lock \
    --mount=type=cache,target=/app/target/ \
    --mount=type=cache,target=~/.cargo/registry \
    <<EOF
set -e
cargo build --locked --release
cp ./target/release/$APP_NAME /bin/server
EOF

################################################################################
# Create a new stage for running the application that contains the minimal
# runtime dependencies for the application. This often uses a different base
# image from the build stage where the necessary files are copied from the build
# stage.
FROM debian:bullseye-slim AS final

# install required packges
RUN apt update && apt install -y openssl libpq-dev pkg-config

# Copy the executable from the "build" stage.
COPY --from=builder /bin/server /bin/

# Expose the port that the application listens on.
EXPOSE 5001

# What the container should run when it is started.
# CMD ["bash", "-c", "./author diesel migration run && ./author"]
CMD ["/bin/server"]
