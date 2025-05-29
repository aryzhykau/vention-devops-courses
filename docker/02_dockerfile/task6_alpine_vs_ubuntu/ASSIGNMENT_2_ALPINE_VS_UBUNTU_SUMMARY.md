# Docker Assignment 2 – Additional Task: Alpine vs Ubuntu Base Image Comparison

---

## 🧪 Objective

Compare the size and behavior of two Flask app Docker images:
- One based on **Ubuntu (python:3.9-slim)**
- One based on **Alpine (python:3.9-alpine)**

---

## 🔧 Base Image Differences

| Base Image         | Size      | Notes |
|--------------------|-----------|-------|
| `python:3.9-slim`  | ~136MB    | Ubuntu-based, works with most Python packages out-of-the-box |
| `python:3.9-alpine`| ~240MB    | Required extra packages to build dependencies (initially larger) |
| `flask-alpine-light` | ~59.7MB | After removing build tools from Alpine image |

---

## ⚙️ Optimization for Alpine

Installed only necessary packages:

```dockerfile
RUN pip install flask==2.0.1 werkzeug==2.0.3
Then removed compilers and dev libraries to shrink the final Alpine image.

Images Built:
# Ubuntu
docker build -t flask-ubuntu -f Dockerfile.ubuntu .

# Alpine (lightweight)
docker build -t flask-alpine-light -f Dockerfile.alpine .

Ports Used:
docker run -d -p 5002:5000 --name flask-ubuntu flask-ubuntu
docker run -d -p 5003:5000 --name flask-alpine flask-alpine-light

Result- Both containers return:
curl http://localhost:5002  # Ubuntu
curl http://localhost:5003  # Alpine
# Output: Hello from a Python app in Docker!
```
