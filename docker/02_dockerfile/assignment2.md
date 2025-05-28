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
## Task 4: Creating and Publishing Your Own Image

# I created a Docker Hub account and successfully published a Docker image based on my optimized Flask app.

### Steps Followed

# 1. Verified my email and created a personal access token with read/write scope.
# 2. Logged in to Docker Hub from my Ubuntu terminal:
   ```bash
   docker login -u petert800
   
# 3. Tagged my image for Docker Hub:
docker tag python-app:good petert800/python-app:good

# 4. Pushed the image to my public repository:
docker push petert800/python-app:good

### Result:
# My image is now available at:
https://hub.docker.com/r/petert800/python-app

```
---

## Task 4: Creating and Publishing Your Own Image

I created a Docker Hub account and successfully published a Docker image based on my optimized Flask app.

### Steps Followed

# 1. Verified my email and created a personal access token with read/write scope.
# 2. Logged in to Docker Hub from my Ubuntu terminal:
   ```bash
   docker login -u petert800
   
# 3. Tagged my image for Docker Hub:
docker tag python-app:good petert800/python-app:good

# 4. Pushed the image to my public repository:
docker push petert800/python-app:good

### Result:
# My image is now available at:
https://hub.docker.com/r/petert800/python-app

```
---

### Additional Task: .dockerignore

I created a `.dockerignore` file to exclude unnecessary files from the build context. This helps keep the image clean and reduces build time.

Contents of `.dockerignore`:
*.pyc
pycache/
*.log
*.md
.dockerignore
Dockerfile.bad


Rebuilt the image as `python-app:clean`, confirmed that ignored files are not included.

### Additional Task: Alpine vs Ubuntu Base Image

I compared two images of the same Flask app — one built using `python:3.9-slim` (Ubuntu-based) and another using `python:3.9-alpine`.

#### Initial Result

- `flask-ubuntu`: ~136MB
- `flask-alpine`: ~240MB

The Alpine image was larger because build tools like `gcc`, `libffi-dev`, and `musl-dev` were required to compile dependencies.

#### Optimization

I rebuilt the Alpine image using precompiled dependencies only (`flask==2.0.1`, `werkzeug==2.0.3`) and **removed the build tools**. The result:

- `flask-alpine-light`: ~59.7MB

#### Result

Both images ran successfully and returned the correct output.

```bash
curl http://localhost:5002  # Ubuntu version
curl http://localhost:5003  # Alpine version

# Output:
Hello from a Python app in Docker!
---
### Additional Task: HEALTHCHECK Instruction

I added a `HEALTHCHECK` instruction to my Flask app Docker image to automatically monitor app health.

#### Final Dockerfile Excerpt

```Dockerfile
RUN apt-get update && apt-get install -y curl && \
    pip install --no-cache-dir -r requirements.txt

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl -f http://localhost:5000/ || exit 1

The health check ensures the container responds on port 5000 with an HTTP 200. After building and running the image, Docker correctly reported the container as (healthy).
---
### Additional Task: Multi-Stage Build

###  Objective  
Create a multi-stage Docker build for a React application to reduce image size, optimize performance, and follow containerization best practices.

---

### What Was Done

I implemented a **multi-stage Dockerfile** for a React app that:
- Builds the app in a lightweight Node.js environment
- Serves the static files using an optimized NGINX image
- Excludes unnecessary files using `.dockerignore`

---

###  Final Dockerfile

```Dockerfile
#### Stage 1: Build React app
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

### Stage 2: Serve with NGINX
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

### Explanation:
- The first stage installs dependencies and compiles the React app.
- The second stage copies only the static output and uses NGINX to serve the production build.

### .dockerignore Used
```
node_modules
build
.dockerignore
Dockerfile
*.log

### Build the optimized image
docker build -t react-demoapp:latest .

### Run it on port 8081 to avoid conflict with Jenkins
docker run -d -p 8081:80 --name react-demo react-demoapp:latest

### Open in browser:
 http://localhost:8081
```
### Result:
- Production React app is served via NGINX
- Lightweight, deployment-ready Docker image
- Clean separation of build and runtime environments



