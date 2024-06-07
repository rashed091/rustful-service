# version can be latest or specific like 1.73.0
ARG RUST_VERSION=latest
ARG APP_NAME="unknown"
ARG PORT=5001

# We only pay the installation cost once,
# it will be cached from the second build onwards
FROM rust:${RUST_VERSION} as chef

WORKDIR /app

# Install diesel CLI for migration
RUN cargo install diesel_cli --no-default-features --features postgres
# Install cargo-chef for Docker layer caching
RUN cargo install cargo-chef

FROM chef as planner

COPY . .

RUN cargo chef prepare  --recipe-path recipe.json


# Build the application. Leverage a cache to which will speed up subsequent builds.
FROM chef as builder

COPY --from=planner /app/recipe.json recipe.json
# Build dependencies - this is the caching Docker layer!
RUN cargo chef cook --release --recipe-path recipe.json
# Build application
COPY . .

RUN cargo build --release

################################################################################
# Create a new stage for running the application that contains the minimal
# runtime dependencies for the application. This often uses a different base
# image from the build stage where the necessary files are copied from the build
# stage. We do not need the Rust toolchain to run the binary!
FROM gcr.io/distroless/cc-debian12	as final

WORKDIR /app

# install required packges (failing, distroless does not have a packges manager)
# RUN apt update && apt install -y openssl libpq-dev pkg-config

COPY --from=builder /app/.env /app/.env
COPY --from=builder /app/target/release/${APP_NAME} /app/${APP_NAME}

# Expose the port that the application listens on.
EXPOSE ${PORT}

# What the container should run when it is started.
# CMD ["bash", "-c", "./author diesel migration run && ./author"]
CMD ["${APP_NAME}"]
