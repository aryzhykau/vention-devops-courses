# Docker Compose Assignment 3 – Volumes

## What Was Done
- Used `docker-compose.yml` to define a Redis container with a named volume
- Verified data persistence across container restarts
- Inspected volume on host using Docker CLI

## Commands Used
docker-compose up -d
docker-compose exec redis redis-cli
docker volume inspect redis-data

## Result
- Redis key persisted after stopping and starting the container
- Data is stored in Docker volume outside the container lifecycle

