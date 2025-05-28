# Docker Assignment 2 – Additional Task: .dockerignore

This task focused on using a `.dockerignore` file to exclude unnecessary files from the Docker build context.

---

## 🎯 Goal

- Reduce image size
- Speed up build time
- Keep sensitive or irrelevant files out of the container

---

## 📄 .dockerignore Contents

```dockerignore
*.pyc
__pycache__/
*.log
*.md
.dockerignore
Dockerfile.bad

These rules exclude:
Python bytecode files
Cached directories
Logs and Markdown notes
Bad/unoptimized Dockerfiles

Rebuilt Image:
docker build -t python-app:clean .

After rebuild:
Confirmed excluded files were not included in the image (docker exec, ls)
Verified that the app still runs as expected

Result:
Image is smaller and cleaner
Build context is faster to transfer
Follows best practices for production-ready containers

