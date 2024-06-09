######################################-Variables-##########################################
# version can be latest or specific like 1.73.0
ARG RUST_VERSION=latest
ARG APP_NAME="unknown"
ARG PORT=5001

######################################-Chef-##########################################
# We only pay the installation cost once,
# it will be cached from the second build onwards
FROM rust:${RUST_VERSION}-slim as chef

WORKDIR /app

RUN apt update && apt upgrade --no-install-recommends -y && \
    apt install --no-install-recommends pkg-config libssl-dev libpq-dev -y

# Install diesel CLI for migration
RUN cargo install diesel_cli --no-default-features --features postgres
# Install cargo-chef for Docker layer caching
RUN cargo install cargo-chef

######################################-Planner-##########################################
FROM chef as planner

COPY . .

RUN cargo chef prepare  --recipe-path recipe.json

######################################-Cacher-##########################################
# Build the application. Leverage a cache to which will speed up subsequent builds.
FROM chef as builder

COPY --from=planner /app/recipe.json recipe.json
# Build dependencies - this is the caching Docker layer!
RUN cargo chef cook --release --recipe-path recipe.json
# Build application
COPY . .

RUN cargo build --release

######################################-Migration-##########################################
# If your service have db connection and required to perform a db migration then
# use this section, otherwise coment it out.
FROM builder as migration

CMD ["diesel", "migration", "run"]

######################################-Application-##########################################
# Create a new stage for running the application that contains the minimal
# runtime dependencies for the application. This often uses a different base
# image from the build stage where the necessary files are copied from the build
# stage. We do not need the Rust toolchain to run the binary!
FROM gcr.io/distroless/cc-debian12	as final

WORKDIR /app

# Create a non-privileged user that the app will run under.
# See https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#user
ARG UID=10001
RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/nonexistent" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    appuser
USER appuser

COPY --from=builder /app/.env /app/.env
COPY --from=builder /app/target/release/${APP_NAME} /app/${APP_NAME}

# Expose the port that the application listens on.
EXPOSE ${PORT}

# What the container should run when it is started.
# CMD ["bash", "-c", "./author diesel migration run && ./author"]
CMD ["${APP_NAME}"]

#------------------------------------------End-----------------------------------------------
