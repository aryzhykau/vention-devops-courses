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

## Task 5: Running Interactive Containers

```bash
# Run Ubuntu container in interactive mode
docker run -it --name ubuntu-container ubuntu:latest bash

# Inside the container:
apt update
apt install -y curl
apt install -y iproute2
ip addr

# Exit the container
exit

# Start the container again and reattach
docker start -ai ubuntu-container

# Check if curl is still installed
curl --version
```

**Findings:**
- The container had its own IP address: 172.17.0.2

**Explanation:**  
The `ip addr` command showed two interfaces:  
- `lo` (loopback) for internal container communication (127.0.0.1)  
- `eth0` as the main interface with IP `172.17.0.2`, assigned by Docker's default bridge network

- curl was installed and persisted after restarting the container.

**Explanation:**  
Running containers interactively is useful for debugging and manual setup. This task showed that containers can retain changes (like installed packages) if not deleted. It also demonstrated that containers have their own network interfaces.
