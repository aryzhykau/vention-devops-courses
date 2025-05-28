# Docker Compose Assignment 1 – Compose Basics

## Task 1: Launching the Application
- Ran `docker-compose up -d` to start two services: `web` (nginx) and `db` (redis).
- Verified services with `docker-compose ps`.

## Task 2: Modifying HTML and Port
- Edited `web/index.html` to change displayed content.
- Updated `docker-compose.yml` to expose port 8085.
- Restarted services and verified changes via browser at `http://localhost:8085`.

## Task 3: Redis Interaction
- Connected to Redis using `docker-compose exec db redis-cli`.
- Set and retrieved a key:
SET mykey "Docker Compose Works!"
GET mykey

## Learnings
- Learned to define and run multi-container apps.
- Practiced live editing, restarting, and container communication.

