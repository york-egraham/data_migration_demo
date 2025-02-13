# Docker Reference

## Starting Containers
```bash
# Building and Starting a local dockerfile
docker build -t <custom_image_name> .
docker run <custom_image_name>

# Starting a docker-compose file (detached mode)
docker-compose up -d

# Starting a docker-compose file (that uses a local Dockerfile to build)
# --build forces a rebuild of your images before starting the containers.
docker-compose up --build -d

# Start a specific service within the docker-compose file
docker-compose up -d <service_name>

# Start a specific docker-compose file
docker-compose -f <file_name> up -d

```

## Managing Containers
```bash
# Stopping a container (this stops but doesn't remove it)
docker-compose stop <service_name>

# Stopping all containers defined in your compose file
docker-compose down

# Restarting a container (stops and then starts the specified container)
docker-compose restart <service_name>

# Deleting (removing) a stopped container
docker-compose rm <service_name>

# Deleting all containers, networks, and (with -v) volumes created by docker-compose
docker-compose down -v

```

## Accessing Containers
```bash
# Run commands in a running container
docker-compose exec <container_name> bash

```

## File Handling (Files & Directories)
```bash
# Copying from Container to Host
docker cp <container_name>:/app/logs/app.log ./app.log

# Copying from Host to Container
docker cp ./config/settings.json <container_name>:/app/config/settings.json

```