# Docker Compose Assignment 4 – Scaling Services

## Task Summary

Scaled the `web` service to 3 replicas using Docker Compose:

```bash
docker-compose up -d --scale web=3
- Confirmed that all 3 containers are running: docker ps

## Verification
- Verified each container's web service from inside using: docker exec -it <container_id> wget -qO- localhost
- All containers returned the expected default Nginx page.

## Notes
- Exposed ports were removed from docker-compose.yml to avoid conflicts.
- expose: "80" used instead of ports.
- Nginx load balancing can be added if public-facing access to all replicas is needed.
```
