```bash
# Check Docker version
docker --version

# Verify that the Docker daemon is running
docker info

# Run nginx container in detached mode and map port 8080 to 80
docker run -d -p 8080:80 --name my-nginx nginx

# Check running containers
docker ps

# Verify web server is accessible
curl http://localhost:8080

# View container logs
docker logs my-nginx

# Stop the container
docker stop my-nginx

# Start the container again
docker start my-nginx

# Remove the container
docker rm -f my-nginx
```
