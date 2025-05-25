## Task 1: Creating a Simple Dockerfile

```bash
# Create project directory
mkdir -p my-web-app
cd my-web-app

# Create HTML file (index.html)
# Create Dockerfile
# Build and run the container
docker build -t my-web-app:v1 .
docker run -d -p 8081:80 --name my-web-app my-web-app:v1
```

**Findings:**
- The image was built from a minimal nginx:alpine base and served a custom HTML page.

- Port 8080 was already in use by Jenkins on my Windows host, so I used port 8081 instead.

- Because I’m using Ubuntu in VirtualBox with NAT networking, I had to configure port forwarding in VirtualBox to access the app via http://localhost:8081 on my Windows machine.


**Explanation:** 
This task taught me how to create a simple Docker image using a Dockerfile, serve static content with nginx, and troubleshoot access issues by adjusting container ports and VirtualBox network settings. I learned how Docker uses COPY to include files and how to make the container available from the host system using port mappings.

## Task 2: Dockerfile Optimization

I created a simple Flask application and built two Docker images using an unoptimized and an optimized Dockerfile.

### Image Comparison

- Unoptimized (`python-app:bad`): ~1.01GB
- Optimized (`python-app:good`): ~136MB

### Optimizations Applied

- Switched base image from `python:3.9` to `python:3.9-slim` to reduce image size.
- Used `--no-cache-dir` with `pip install` to avoid storing pip cache and reduce layer size.
- Installed dependencies before copying the app to leverage Docker layer caching.
- Initially added `USER nobody` for security, but removed it for compatibility during development.
- Fixed dependency issue by pinning compatible versions:
  - `flask==2.0.1`
  - `werkzeug==2.0.3`

### Running the Container

The optimized image was run with:

```bash
docker run -d -p 5000:5000 --name python-app python-app:good

# Tested using:

curl http://localhost:5000

# Output:

Hello from a Python app in Docker!

```
## Task 3: Multi-stage Builds

I created a multi-stage Dockerfile to build and run a Flask application more efficiently by separating the build environment from the runtime environment.

### Why Multi-Stage?

- Stage 1 installs Python dependencies using `pip`.
- Stage 2 (final image) copies only the necessary runtime files.
- This results in a cleaner, smaller, and more secure image.

### Image Size

- Multi-stage image (`python-multistage-app`): ~166MB

### Running the Container

```bash
docker run -d -p 5001:5000 --name multistage-app python-multistage-app

# Tested using:

curl http://localhost:5001

# Output:

Hello from a multi-stage build Docker container!
---
