NAME=restful
VERSION=$(shell git rev-parse HEAD)
SEMVER_VERSION=$(shell grep version Cargo.toml | awk -F"\"" '{print $$2}' | head -n 1)
REPO=mrasheduzzaman
SHELL := /bin/bash

no_postgres:
	@[ -z "$$(docker ps -q -f ancestor="postgres:latest")" ] || (echo "db running"; exit 2)
has_postgres:
	@[ -n "$$(docker ps -q -f ancestor="postgres:latest")" ] || (echo "db not running"; exit 2)

db:	no_postgres
	@echo "Starting postgres container"
	docker compose up -d db

stop:
	@docker ps -aq | xargs -r docker rm -f
	@pkill $(NAME) || true

setup:
	cargo install cargo-watch
	cargo install diesel_cli --no-default-features --features postgres

test:
	./test.sh

compose:
	docker compose up -d
	docker compose logs $(NAME)

run: has_postgres
	cargo watch -q -c -w src/ -x run

compile: has_postgres
		cargo build --release

build:
	@echo "Reusing built binary in current directory from make compile"
	@ls -lah ./$(NAME)
	docker build -t $(REPO)/$(NAME):$(VERSION) .

tag-latest: build
	docker tag $(REPO)/$(NAME):$(VERSION) $(REPO)/$(NAME):latest
