#!/bin/sh
#-------------------------------------docker multiple architecture build script------------------------------------------
#Note: you cannot export a buildx container image into a local docker instance with multiple architecture manifests so for local testing you have to select just a single architecture.

APP_NAME=$(rg --no-filename --color never 'name = .*' Cargo.toml | cut -d '"' -f 2)
PORT=$(rg --no-filename --color never 'PORT=*' .env | cut -d '=' -f 2)
DB_CONTAINER_NAME=$(rg --no-filename --color never 'DATABASE_CONTAINER_NAME=*' .env | cut -d '=' -f 2)


# Set variables to emulate running in the workflow/pipeline,
# this helps tracking docker image changes for each commit
GIT_REPOSITORY=$(basename `git rev-parse --show-toplevel`)
GIT_BRANCH=$(git branch --show-current)
GIT_COMMIT_SHA=$(git rev-parse HEAD)
GIT_TAG="latest"

DOCKER_HUB_REPO=mrasheduzzaman
IMAGE_NAME="$DOCKER_HUB_REPO/$APP_NAME:$GIT_TAG"

PLATFORMS="linux/amd64,linux/arm64"

#Create a new builder instance
#https://github.com/docker/buildx/blob/master/docs/reference/buildx_create.md
docker buildx use multi-platform-builder

docker buildx inspect --bootstrap

#Start a build
#https://github.com/docker/buildx/blob/master/docs/reference/buildx_build.md

docker buildx build \
  --label "GIT_BRANCH=$GIT_BRANCH" \
  --label "IMAGE_NAME=$IMAGE_NAME" \
  --label "IMAGE_VERSION=$GIT_COMMIT_SHA" \
  --label "GIT_REPOSITORY=$GIT_REPOSITORY" \
  --build-arg APP_NAME=$(APP_NAME) \
  --build-arg PORT=$(PORT) \
  --platform $PLATFORMS \
  --output "type=image,push=true" \
  --tag $IMAGE_NAME --push .

docker buildx stop multi-platform-builder
