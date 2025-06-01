# Docker Assignment 2 – Task 2: Dockerfile Optimization

This task involved optimizing a basic Flask web app image by improving the Dockerfile.

## Image Comparison

- Unoptimized (`python-app:bad`): ~1.01GB  
- Optimized (`python-app:good`): ~136MB

## Optimizations Applied

- Switched to `python:3.9-slim` base image  
- Added `--no-cache-dir` to `pip install`  
- Installed dependencies before copying app code  
- Removed unused layers and files  
- Pinned compatible package versions in `requirements.txt`:
  - `flask==2.0.1`
  - `werkzeug==2.0.3`

## Build & Run

```bash
# Build
docker build -t python-app:bad -f Dockerfile.bad .
docker build -t python-app:good -f Dockerfile.good .

# Run
docker run -d -p 5000:5000 --name python-app python-app:good

# Test
curl http://localhost:5000
# Output: Hello from a Python app in Docker!
```
