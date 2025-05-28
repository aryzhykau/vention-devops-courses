# Docker Assignment 2 – Task 1: Creating a Simple Dockerfile

This task involved creating a basic Docker image using the `nginx:alpine` base image and serving static content with a custom `index.html`.

## Steps Taken

1. Created a minimal HTML file.
2. Created a Dockerfile to copy the file into the correct nginx location.
3. Built and ran the container:
```bash
docker build -t my-web-app:v1 .
docker run -d -p 8081:80 --name my-web-app my-web-app:v1
##Observations
Used port 8081 to avoid conflict with Jenkins on host.

Set up port forwarding in VirtualBox (NAT) to expose it on http://localhost:8081.

Page loaded successfully in the browser.
```
