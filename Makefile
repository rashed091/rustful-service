SHELL := /bin/bash
DOCKER_HUB_REPO=mrasheduzzaman
APP_NAME=$(shell rg --no-filename --color never 'name = .*' Cargo.toml | cut -d '"' -f 2)
VERSION=$(shell git rev-parse HEAD)
PORT=$(shell rg --no-filename --color never 'PORT=*' .env | cut -d '=' -f 2)
DB_CONTAINER_NAME=$(shell rg --no-filename --color never 'DATABASE_CONTAINER_NAME=*' .env | cut -d '=' -f 2)


.PHONY: is_running

setup:
	cargo install cargo-watch
	cargo install diesel_cli --no-default-features --features postgres

db:
	@echo "Starting postgres container"
	docker compose up -d db

is_db_running:
	@./check_container.sh $(DB_CONTAINER_NAME)

stop:
	docker container stop $(APP_NAME)

test:
	./test.sh

compose:
	docker compose up -d

run: is_db_running
	cargo watch -q -c -w src/ -x run

compile: has_postgres
		cargo build --release

build:
	docker build \
	--build-arg APP_NAME=$(APP_NAME) \
	--build-arg PORT=$(PORT) \
	--tag $(DOCKER_HUB_REPO)/$(APP_NAME):$(VERSION) .

tag: build
	docker tag $(DOCKER_HUB_REPO)/$(APP_NAME):$(VERSION) $(DOCKER_HUB_REPO)/$(APP_NAME):latest

push: tag
	docker push $(DOCKER_HUB_REPO)/$(APP_NAME):latest

multi:
	docker buildx build \
	--build-arg APP_NAME=$(APP_NAME) \
	--build-arg PORT=$(PORT) \
	--platform linux/amd64,linux/arm64 \
	--output "type=image,push=true" \
	--tag $(DOCKER_HUB_REPO)/$(APP_NAME):latest --push .

testrun:
	docker container run --name $(APP_NAME) \
	--rm \
	--publish $(PORT):$(PORT) \
	--detach $(DOCKER_HUB_REPO)/$(APP_NAME):latest

logs:
	docker container logs \
	--follow \
	--tail \
	--timestamps $(APP_NAME)

remove:
	docker container rm --force --volumes $(APP_NAME)

list:
	docker container ls --all --no-trunc
