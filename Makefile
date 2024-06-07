SHELL := /bin/bash
NAME=$(shell rg --no-filename --color never 'name = .*' Cargo.toml | cut -d '"' -f 2)
VERSION=$(shell git rev-parse HEAD)
SEMVER_VERSION=$(shell grep version Cargo.toml | awk -F"\"" '{print $2}' | head -n 1)
REPO=mrasheduzzaman
PORT=$(shell rg --no-filename --color never 'PORT=*' .env | cut -d '=' -f 2)

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

run: has_postgres
	cargo watch -q -c -w src/ -x run

compile: has_postgres
		cargo build --release

build:
	docker build \
	--build-arg APP_NAME=$(NAME) \
	--build-arg PORT=$(PORT) \
	--tag $(REPO)/$(NAME):$(VERSION) .

tag: build
	docker tag $(REPO)/$(NAME):$(VERSION) $(REPO)/$(NAME):latest

push: tag
	docker push $(REPO)/$(NAME):latest

multi:
	docker buildx build \
	--build-arg APP_NAME=$(NAME) \
	--build-arg PORT=$(PORT) \
	--platform linux/amd64,linux/arm64 \
	--output "type=image,push=true" \
	--tag $(REPO)/$(NAME):latest --push .

testrun:
	docker container run --name $(NAME) \
	--rm \
	--publish $(PORT):$(PORT) \
	--detach $(REPO)/$(NAME):latest

logs:
	docker container logs \
	--follow \
	--tail \
	--timestamps $(NAME)

remove:
	docker container rm --force --volumes $(NAME)

list:
	docker container ls --all --no-trunc
