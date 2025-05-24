## Task 3: Working with Containers

```bash
# Run nginx container in detached mode
docker run -d -p 8080:80 --name my-nginx nginx

# Check running containers
docker ps

# View logs
docker logs my-nginx

# Stop the container
docker stop my-nginx

# Start the container again
docker start my-nginx

# Delete the container
docker rm -f my-nginx
```

**Explanation:**  
This task involved managing the lifecycle of an `nginx` container. After starting it, we verified it was running, checked the logs, stopped and restarted it, and finally removed it using the `rm -f` flag which forces deletion even if the container is running.

