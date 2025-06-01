# Docker Assignment 2 – Task 3: Multi-Stage Build

This task focused on creating a clean and optimized multi-stage Docker image for a simple Flask application.

## Objective

Use multi-stage builds to:
- Separate build-time dependencies from runtime
- Minimize image size
- Improve maintainability and security

## Dockerfile

```Dockerfile
# Stage 1: Build environment
FROM python:3.9-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Runtime image
FROM python:3.9-slim
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.9 /usr/local/lib/python3.9
COPY app.py .
EXPOSE 5000
CMD ["python", "app.py"]

Image Details
Final image: python-multistage-app

Size: ~166MB (smaller than unoptimized version)

Dependencies copied from builder stage only

Running the App:
docker build -t python-multistage-app .
docker run -d -p 5001:5000 --name multistage-app python-multistage-app

curl http://localhost:5001
# Output: Hello from a multi-stage build Docker container!


