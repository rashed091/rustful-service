SHELL := /bin/bash
DOCKER_HUB_REPO=mrasheduzzaman
APP_NAME=$(shell rg --no-filename --color never 'name = .*' Cargo.toml | cut -d '"' -f 2)
VERSION=$(shell git rev-parse HEAD)
PORT=$(shell rg --no-filename --color never 'PORT=*' .env | cut -d '=' -f 2)
DB_CONTAINER_NAME=$(shell rg --no-filename --color never 'DATABASE=*' .env | cut -d '=' -f 2)

.PHONY: is_running

setup:
	cargo install cargo-watch
	cargo install diesel_cli --no-default-features --features postgres

compose:
	@echo "Starting all services in detach mode"
	docker compose up --build

detach:
	@echo "Starting all services in detach mode"
	docker compose up -d

up:
	@echo "Starting all services"
	docker compose up

down:
	@echo "Down all services"
	docker compose down

stop:
	@echo "Stop service named $(APP_NAME)"
	docker container stop $(APP_NAME)


data:
	@echo "Starting postgres container"
	docker compose up -d postgres

test:
	./test.sh

is_db_running:
	@./check_container.sh $(DB_CONTAINER_NAME)

run: is_db_running
	cargo watch -q -c -w src/ -x run

compile: is_db_running
		cargo build --release

build:
	docker image build \
	--build-arg APP_NAME=$(APP_NAME) \
	--build-arg PORT=$(PORT) \
	--tag $(DOCKER_HUB_REPO)/$(APP_NAME):$(VERSION) .

tag: build
	docker image tag $(DOCKER_HUB_REPO)/$(APP_NAME):$(VERSION) $(DOCKER_HUB_REPO)/$(APP_NAME):latest

push: tag
	docker image push $(DOCKER_HUB_REPO)/$(APP_NAME):latest

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
	docker container ls --all

multiplatform:
	./build.sh
