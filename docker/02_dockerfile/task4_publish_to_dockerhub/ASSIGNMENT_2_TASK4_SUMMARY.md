# Docker Assignment 2 – Task 4: Publishing to Docker Hub

This task focused on publishing a Docker image to Docker Hub, making it publicly available for reuse and deployment.

---

## 🐳 What Was Done

1. **Created a Docker Hub account** at [https://hub.docker.com](https://hub.docker.com)
2. **Generated a personal access token** with write access
3. **Logged in from the terminal:**

```bash
docker login -u petert800

Tagged the optimized Flask app image:
docker tag python-app:good petert800/python-app:good

Pushed the image:
docker push petert800/python-app:good
Result
The image is now available publicly on Docker Hub:
https://hub.docker.com/r/petert800/python-app

It can be pulled from anywhere using:
docker pull petert800/python-app:good

Notes
A .dockerignore file was used to exclude unnecessary files from the image.

The image is based on python:3.9-slim, optimized for size (~136MB).

Uploaded image follows clean version tagging (e.g. :good for stable).

Benefits
Reusable across projects and teammates

Works in CI/CD pipelines

Saves time when deploying to new environments
```
