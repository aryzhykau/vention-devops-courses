## Task 3: Working with Containers

```bash
# Run nginx container in detached mode
docker run -d -p 8080:80 --name my-nginx nginx

# Check running containers
docker ps

# View logs
docker logs my-nginx

# Stop the container
docker stop my-nginx

# Start the container again
docker start my-nginx

# Delete the container
docker rm -f my-nginx
```

**Explanation:**  
This task involved managing the lifecycle of an `nginx` container. After starting it, we verified it was running, checked the logs, stopped and restarted it, and finally removed it using the `rm -f` flag which forces deletion even if the container is running.

## Task 4: Exploring Images

```bash
# View list of local images
docker images

# Inspect the nginx image
docker inspect nginx
```

**Findings:**
- **Image size:** ~183.5 MB
- **Architecture:** amd64
- **Layers:**  
  The nginx image has 7 layers. Docker uses these to cache and optimize builds. Each layer represents changes made to the base image.  
  Examples:
  - sha256:ace34d1d...
  - sha256:deb7d887...
  - sha256:cb857378...

**Explanation:**  
Inspecting images helps us understand how Docker stores and builds containers. Layers are key to Docker’s efficiency. Knowing the image size, architecture, and layer structure is useful when debugging, optimizing, or auditing images.

