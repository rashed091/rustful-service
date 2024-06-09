#!/bin/bash

# Get the container name as the first argument
container_name="$1"

# Check if a container name was provided
if [ -z "$container_name" ]; then
  echo "Error: Please provide a container name as an argument."
  exit 1
fi

# Use docker ps to filter for the container and get its container ID
container_id=$(docker ps -q --filter name=^/$container_name$ --filter status=running)

# Check if the container ID is empty (meaning the container is not running)
if [ -z "$container_id" ]; then
  echo "Error: $container_name is not running. Please make sure $container_name is running."
  exit 2
else
  echo "$container_name is running."
fi
