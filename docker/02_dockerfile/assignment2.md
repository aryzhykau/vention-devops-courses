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

