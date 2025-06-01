# Docker Assignment 2 – Additional Task: HEALTHCHECK Instruction

---

##  Goal

Add a `HEALTHCHECK` instruction to the Flask app image to monitor its availability automatically inside the container.

---

##  Dockerfile Excerpt

```dockerfile
RUN apt-get update && apt-get install -y curl && \
    pip install --no-cache-dir -r requirements.txt

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1

Explanation:
curl checks if the app is returning HTTP 200 on port 5000.
Docker will mark the container as healthy if the app responds correctly.
Otherwise, the container will be marked unhealthy after 3 failed attempts.

Result:
After building and running the container: docker inspect <container_name> | grep -i health
Output included "Status": "healthy" once the app started responding.
Docker UI and CLI both reflected the health status.


