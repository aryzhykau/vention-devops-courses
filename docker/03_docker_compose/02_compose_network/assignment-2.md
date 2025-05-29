# Docker Compose Assignment 2 – Compose Networking

## Objective
Demonstrate container-to-container communication using Docker Compose DNS.

## What I Did
- Launched a web and db (Redis) service using Docker Compose.
- Opened a shell in the `web` container.
- Installed networking tools:
  ```bash
  apt update
  apt install -y iputils-ping dnsutils

Successfully pinged db using its service name.
ping db
64 bytes from db (172.19.0.2): icmp_seq=1 ttl=64 time=0.4 ms
64 bytes from db (172.19.0.2): icmp_seq=2 ttl=64 time=0.1 ms

Conclusion: Docker Compose automatically connects containers via an internal bridge network. Each container can resolve others by their service name (e.g., db) using internal DNS.

