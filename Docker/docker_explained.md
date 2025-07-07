# Docker Examen Studiehulp - Uitgebreide Theorie

## 1. Docker Fundamentals

### Wat is Docker?
- **Containerization platform** (niet virtualisatie)
- **Container Engine** gebaseerd op Linux kernel features
- **Open source**, geschreven in **Go**
- **"Software bucket"** - bevat alles om software onafhankelijk te draaien
- **Process** draait geïsoleerd op host OS

### Geschiedenis & Context
- Gebaseerd op Linux containerization technologieën:
  - **LXC** (Linux Containers)
  - **FreeBSD jail**
  - **OpenVZ**
  - **AIX WPARs**
  - **Solaris Containers**
- Docker maakte containers mainstream door eenvoudige tooling

### Architectuur Principes

#### Shared OS Kernel
- Alle containers **delen de kernel** van het host OS
- Geen volledige OS virtualisatie zoals bij VMs
- Veel **efficiënter** in resource gebruik
- **Snellere startup** times

#### Geïsoleerde Processen
Docker gebruikt Linux kernel features voor isolatie:

**Namespaces:**
- **PID namespace**: Process isolatie
- **Network namespace**: Network stack isolatie
- **Mount namespace**: Filesystem isolatie
- **UTS namespace**: Hostname isolatie
- **IPC namespace**: Inter-process communication isolatie
- **User namespace**: User ID isolatie

**Control Groups (cgroups):**
- **CPU** limiting
- **Memory** limiting
- **Block I/O** limiting
- **Network** bandwidth limiting

#### Union File System
Het hart van Docker's storage efficiency:

**4 Lagen Architectuur:**
1. **Lower layer (base)**: Read-only base image
2. **Upper layer (diff)**: Read-write changes
3. **Merged layer (overlay)**: Gecombineerde view voor gebruiker
4. **Work layer (workdir)**: Temporary workspace

**Ondersteunde Types:**
- **AUFS** (Advanced Multi-layered Unification Filesystem)
- **Overlay2** (standaard sinds Docker 18.09)
- **BTRFS** (B-tree filesystem)
- **Device Mapper**

**Kernel Integratie:**
- Onderdeel van Linux kernel sinds **versie 3.18**
- **Copy-on-Write** mechanisme voor efficiency

## 2. Docker Terminologie & Concepten

### Images - Diepgaande Analyse

#### Eigenschappen
- **Read-only** filesystem met configuratie
- **Layered** architectuur - elke laag bouwt voort op vorige
- **Immutable** - kunnen niet gewijzigd worden
- **Template** voor container creatie
- **Versioned** via tags

#### Image Layers
```bash
# Voorbeeld van layer structuur
Layer 1: Base OS (ubuntu:20.04)
Layer 2: Package updates (apt-get update)
Layer 3: Application install (apache2)
Layer 4: Configuration files
Layer 5: Application code
```

#### Image Naming Convention
```
[registry]/[namespace]/[repository]:[tag]
docker.io/library/ubuntu:20.04
```

### Containers - Runtime Behavior

#### Container Lifecycle
1. **Created**: Container aangemaakt maar niet gestart
2. **Running**: Container actief met lopende processen
3. **Paused**: Container gepauzeerd (processen gestopt)
4. **Stopped**: Container gestopt (processen beëindigd)
5. **Removed**: Container verwijderd van systeem

#### Container Isolatie
- **Process isolation**: Elk container heeft eigen PID namespace
- **Network isolation**: Eigen network stack
- **Filesystem isolation**: Eigen root filesystem
- **Resource isolation**: CPU, memory, I/O limits

### Layered Filesystem - Technische Details

#### Bootfilesystem (bootfs)
- **Kernel** en **boot loader**
- **Tijdelijk** - gemount tijdens boot
- **Gedeeld** tussen containers

#### Root Filesystem (rootfs)
- **Read-only** base layer
- **OS bestanden** en directories
- **Union mount** van meerdere layers

#### Copy-on-Write Mechanisme
```
1. Container leest bestand → lees uit read-only layer
2. Container wijzigt bestand → kopieer naar read-write layer
3. Toekomstige reads → lees uit read-write layer
```

## 3. Docker Installatie & Configuratie

### System Requirements
- **Linux kernel** versie 3.10+
- **64-bit** architectuur
- **Storage driver** support (overlay2, aufs, etc.)
- **Network driver** support

### Post-Installation Setup
```bash
# Verificatie installatie
docker version          # Client en server versie
docker info             # Uitgebreide system info
docker system df        # Disk usage
docker system events    # Real-time events

# Non-root gebruiker setup
sudo usermod -aG docker $USER
# Logout/login of newgrp docker
```

### Docker Daemon Configuratie
```json
# /etc/docker/daemon.json
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-address-pools": [
    {
      "base": "172.17.0.0/16",
      "size": 24
    }
  ]
}
```

## 4. Images & Containers - Geavanceerde Operaties

### Image Management
```bash
# Gedetailleerde image info
docker image inspect ubuntu:20.04
docker image history ubuntu:20.04    # Layer geschiedenis
docker image ls --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Image cleanup
docker image prune                    # Dangling images
docker image prune -a                 # Alle ongebruikte images
docker system prune -a --volumes      # Alles cleanup
```

### Container Management
```bash
# Geavanceerde container info
docker container inspect --format='{{.State.Status}}' mycontainer
docker container logs -f --tail=50 mycontainer
docker container stats mycontainer   # Resource usage

# Container export/import
docker export mycontainer > container.tar
docker import container.tar myimage:latest
```

### Runtime Opties
```bash
# Resource limits
docker run --cpus="1.5" --memory="2g" nginx
docker run --memory="512m" --memory-swap="1g" nginx

# Security opties
docker run --user 1000:1000 nginx
docker run --read-only --tmpfs /tmp nginx
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE nginx
```

## 5. Dockerfile - Geavanceerde Concepten

### Multi-Stage Builds
```dockerfile
# Build stage
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

# Production stage
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY . .
CMD ["node", "server.js"]
```

### Build Context & .dockerignore
```dockerignore
# .dockerignore - exclude from build context
**/.git
**/node_modules
**/npm-debug.log
Dockerfile*
.dockerignore
**/.DS_Store
**/README.md
```

### Dockerfile Instructies - Diepgaande Analyse

#### FROM - Base Image Selection
```dockerfile
# Specific version (recommended)
FROM ubuntu:20.04

# Multi-platform builds
FROM --platform=linux/amd64 ubuntu:20.04

# Scratch voor minimale images
FROM scratch
```

#### LABEL - Metadata Management
```dockerfile
# Structured metadata
LABEL maintainer="dev@company.com"
LABEL version="1.0"
LABEL description="Production web server"
LABEL build-date="2023-11-20"
LABEL vcs-url="https://github.com/company/repo"
LABEL vcs-ref="abc123"
```

#### RUN - Build-time Execution
```dockerfile
# Shell form (default: /bin/sh -c)
RUN apt-get update && apt-get install -y \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Exec form (geen shell interpretation)
RUN ["/bin/bash", "-c", "echo hello"]

# Multi-line optimization
RUN apt-get update \
    && apt-get install -y \
        package1 \
        package2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
```

#### CMD vs ENTRYPOINT - Diepgaande Verschillen

**CMD Characteristics:**
- **Overschrijfbaar** door docker run arguments
- **Default command** als geen argumenten gegeven
- **Laatste CMD** in Dockerfile wordt gebruikt

**ENTRYPOINT Characteristics:**
- **Niet overschrijfbaar** (behalve met --entrypoint)
- **Altijd uitgevoerd** 
- **Docker run argumenten** worden als parameters toegevoegd

**Combinatie Patterns:**
```dockerfile
# Pattern 1: ENTRYPOINT + CMD voor flexibiliteit
ENTRYPOINT ["python", "app.py"]
CMD ["--help"]

# Pattern 2: Script-based entry
ENTRYPOINT ["./docker-entrypoint.sh"]
CMD ["nginx", "-g", "daemon off;"]
```

#### COPY vs ADD - Wanneer Wat Gebruiken

**COPY - Voorkeur:**
```dockerfile
# Simpel, voorspelbaar
COPY src/ /app/src/
COPY requirements.txt /app/
```

**ADD - Speciale Features:**
```dockerfile
# Automatische tar extractie
ADD app.tar.gz /app/

# Remote URL download (niet aanbevolen)
ADD https://example.com/file.tar.gz /tmp/
```

#### Environment Variables - Geavanceerd
```dockerfile
# Build-time variables
ARG NODE_VERSION=16
FROM node:${NODE_VERSION}

# Runtime variables
ENV NODE_ENV=production
ENV PATH="/app/bin:${PATH}"

# Multi-line environment
ENV PYTHONPATH="/app:/app/lib" \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1
```

#### Volume Patterns
```dockerfile
# Anonymous volume
VOLUME /data

# Multiple volumes
VOLUME ["/var/log", "/var/cache"]

# Best practice: document expected mounts
VOLUME /app/data
LABEL volume.data.description="Application data storage"
```

### Build Optimization Strategies

#### Layer Caching
```dockerfile
# Bad - cache busting
FROM ubuntu:20.04
COPY . /app
RUN apt-get update && apt-get install -y python3

# Good - cache friendly
FROM ubuntu:20.04
RUN apt-get update && apt-get install -y python3
COPY requirements.txt /app/
RUN pip install -r /app/requirements.txt
COPY . /app
```

#### Cache Invalidation
```dockerfile
# Force rebuild vanaf bepaald punt
FROM ubuntu:20.04
LABEL maintainer="dev@company.com"
ENV REFRESHED_AT=2023-11-20
RUN apt-get update
```

#### Build Arguments
```dockerfile
ARG BUILD_DATE
ARG VERSION
LABEL build-date=$BUILD_DATE
LABEL version=$VERSION
```

```bash
# Build met argumenten
docker build \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VERSION=1.0 \
  -t myapp:1.0 .
```

## 6. Networking - Diepgaande Theorie

### Network Architecture

#### Docker0 Bridge
- **Virtual interface** op host systeem
- **Default bridge** voor containers
- **Private IP range**: 172.17.0.0/16
- **Automatic IP assignment**

#### Network Drivers
```bash
# Available drivers
docker network ls
# bridge, host, none, overlay, macvlan
```

### Network Types

#### Bridge Network (Default)
```bash
# Create custom bridge
docker network create mybridge
docker run --network mybridge nginx

# Network isolation
docker network create --driver bridge isolated_network
```

#### Host Network
```bash
# Direct host networking
docker run --network host nginx
# Container gebruikt host's network stack
```

#### Overlay Network (Swarm)
```bash
# Multi-host networking
docker network create --driver overlay myoverlay
```

### Port Mapping - Geavanceerd
```bash
# Basis port mapping
docker run -p 8080:80 nginx              # host:container
docker run -p 127.0.0.1:8080:80 nginx   # specific IP
docker run -p 127.0.0.1::80 nginx       # random host port
docker run -P nginx                       # alle EXPOSED ports

# Protocol specificatie
docker run -p 8080:80/tcp nginx
docker run -p 53:53/udp nginx

# Multiple ports
docker run -p 80:80 -p 443:443 nginx
```

### Advanced Network Configuration
```bash
# Custom network met subnet
docker network create --subnet=192.168.1.0/24 mynetwork

# Static IP assignment
docker run --network mynetwork --ip 192.168.1.100 nginx

# Custom DNS
docker run --dns 8.8.8.8 --dns 8.8.4.4 nginx

# Network aliases
docker run --network mynetwork --network-alias webserver nginx
```

### Network Troubleshooting
```bash
# Network inspection
docker network inspect bridge
docker port mycontainer
docker exec mycontainer netstat -tlnp

# Container networking info
docker inspect --format='{{.NetworkSettings.IPAddress}}' mycontainer
```

## 7. Volumes - Storage Management

### Volume Types - Diepgaande Analyse

#### Named Volumes
```bash
# Managed by Docker
docker volume create mydata
docker volume inspect mydata
# Located at: /var/lib/docker/volumes/mydata/_data

# Usage
docker run -v mydata:/app/data nginx
```

#### Bind Mounts
```bash
# Host directory mounting
docker run -v /host/path:/container/path nginx
docker run -v /host/path:/container/path:ro nginx  # read-only

# Current directory shortcut
docker run -v $(pwd):/app nginx
```

#### tmpfs Mounts
```bash
# Memory-only storage
docker run --tmpfs /tmp nginx
docker run --mount type=tmpfs,destination=/tmp,tmpfs-size=100m nginx
```

### Volume Drivers
```bash
# Local driver (default)
docker volume create --driver local myvolume

# NFS driver
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/dir \
  nfsvolume
```

### Mount Syntax - Modern Approach
```bash
# Volume mount
docker run --mount type=volume,source=myvolume,target=/data nginx

# Bind mount
docker run --mount type=bind,source=/host/path,target=/app nginx

# tmpfs mount
docker run --mount type=tmpfs,target=/tmp nginx

# Read-only mount
docker run --mount type=bind,source=/host/path,target=/app,readonly nginx
```

### Volume Best Practices
```bash
# Backup volumes
docker run --volumes-from mycontainer -v $(pwd):/backup busybox tar czf /backup/backup.tar.gz /data

# Restore volumes
docker run --volumes-from mycontainer -v $(pwd):/backup busybox tar xzf /backup/backup.tar.gz -C /

# Volume cleanup
docker volume prune                    # Remove unused volumes
docker system prune --volumes         # Remove all unused data
```

## 8. Docker Compose - Orchestration

### Compose File Versions
- **Version 1**: Legacy (geen version key)
- **Version 2**: Networks en volumes support
- **Version 3**: Swarm deployment support

### Advanced Compose Features

#### Service Configuration
```yaml
version: '3.8'
services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.prod
      args:
        - BUILD_DATE
        - VERSION
    image: myapp:${VERSION:-latest}
    ports:
      - "8080:80"
    environment:
      - NODE_ENV=production
    env_file:
      - .env
    volumes:
      - ./src:/app/src
      - web_data:/app/data
    depends_on:
      - db
      - redis
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:80/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

#### Network Configuration
```yaml
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true
  external_network:
    external: true
```

#### Volume Configuration
```yaml
volumes:
  db_data:
    driver: local
  nfs_data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=192.168.1.100,rw
      device: ":/path/to/dir"
```

### Service Dependencies
```yaml
depends_on:
  - db
  - redis
# Wait for containers to start (not healthy)

# Healthcheck-based waiting
depends_on:
  db:
    condition: service_healthy
```

### Scaling Services
```bash
# Scale specific service
docker-compose up --scale web=3

# Scale with resource limits
docker-compose up --scale worker=5
```

### Environment Variable Substitution
```yaml
services:
  web:
    image: nginx:${NGINX_VERSION:-latest}
    ports:
      - "${WEB_PORT:-80}:80"
    environment:
      - DEBUG=${DEBUG:-false}
```

## 9. Docker Swarm - Cluster Management

### Swarm Architecture

#### Node Types
- **Manager Nodes**: Cluster management, scheduling
- **Worker Nodes**: Container execution
- **Leader**: Active manager (één per cluster)

#### Consensus Algorithm
- **Raft consensus** voor manager nodes
- **Quorum** requirement voor decisions
- **Odd number** van managers aanbevolen

### Swarm Initialization
```bash
# Initialize swarm
docker swarm init --advertise-addr <MANAGER-IP>

# Join as worker
docker swarm join --token <WORKER-TOKEN> <MANAGER-IP>:2377

# Join as manager
docker swarm join --token <MANAGER-TOKEN> <MANAGER-IP>:2377

# Token management
docker swarm join-token worker
docker swarm join-token manager
```

### Service Management
```bash
# Service creation
docker service create \
  --name web \
  --replicas 3 \
  --publish 80:80 \
  --network mynetwork \
  nginx

# Service updates
docker service update --replicas 5 web
docker service update --image nginx:1.20 web

# Rolling updates
docker service update \
  --update-parallelism 1 \
  --update-delay 10s \
  web
```

### Service Discovery
```bash
# DNS-based service discovery
dig web.mynetwork

# VIP (Virtual IP) resolution
docker service inspect web
```

### Constraints & Placement
```bash
# Node constraints
docker service create \
  --constraint 'node.role == manager' \
  --name management-app \
  myapp

# Node labels
docker node update --label-add environment=production worker1
docker service create \
  --constraint 'node.labels.environment == production' \
  myapp
```

### Secrets Management
```bash
# Secret creation
echo "mypassword" | docker secret create db_password -

# Secret usage
docker service create \
  --secret db_password \
  --name app \
  myapp
```

### Stack Deployment
```yaml
# docker-compose.yml for stack
version: '3.8'
services:
  web:
    image: nginx
    ports:
      - "80:80"
    deploy:
      replicas: 3
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
      placement:
        constraints:
          - node.role == worker
```

```bash
# Deploy stack
docker stack deploy -c docker-compose.yml mystack

# Stack management
docker stack ps mystack
docker stack services mystack
docker stack rm mystack
```

## 10. Security & Best Practices

### Container Security
```bash
# Run as non-root user
docker run --user 1000:1000 nginx

# Read-only root filesystem
docker run --read-only --tmpfs /tmp nginx

# Drop capabilities
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE nginx

# No new privileges
docker run --security-opt no-new-privileges nginx
```

### Image Security
```dockerfile
# Multi-stage build voor minimale images
FROM node:16 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

FROM node:16-alpine
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nextjs -u 1001
WORKDIR /app
COPY --from=builder --chown=nextjs:nodejs /app/node_modules ./node_modules
USER nextjs
```

### Secrets Management
```bash
# Docker secrets (Swarm mode)
docker secret create app_secret /path/to/secret

# External secrets management
docker run -v /run/secrets:/run/secrets:ro myapp
```

## 11. Monitoring & Logging

### Container Monitoring
```bash
# Resource usage
docker stats
docker system df
docker system events

# Container metrics
docker exec mycontainer cat /proc/meminfo
docker exec mycontainer cat /proc/loadavg
```

### Logging Configuration
```bash
# Log drivers
docker run --log-driver json-file --log-opt max-size=10m nginx
docker run --log-driver syslog nginx
docker run --log-driver none nginx

# Centralized logging
docker run --log-driver fluentd --log-opt fluentd-address=localhost:24224 nginx
```

### Health Checks
```dockerfile
# In Dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

```bash
# At runtime
docker run --health-cmd="curl -f http://localhost:8080/health" nginx
```

## 12. Performance Optimization

### Resource Limits
```bash
# CPU limits
docker run --cpus="1.5" nginx                    # 1.5 CPU cores
docker run --cpu-shares=512 nginx                # Relative weight

# Memory limits
docker run --memory="2g" nginx                   # 2GB RAM
docker run --memory="1g" --memory-swap="2g" nginx # 1GB RAM + 1GB swap

# I/O limits
docker run --device-read-bps=/dev/sda:1mb nginx
docker run --device-write-bps=/dev/sda:1mb nginx
```

### Storage Optimization
```bash
# Multi-stage builds
FROM golang:1.19 AS builder
WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 go build -o app

FROM scratch
COPY --from=builder /app/app /app
CMD ["/app"]
```

### Network Optimization
```bash
# Host networking voor performance
docker run --network host nginx

# Custom bridge voor isolatie
docker network create --driver bridge optimized
```

## 13. Production Deployment

### CI/CD Integration
```yaml
# GitHub Actions example
name: Docker Build and Deploy
on:
  push:
    branches: [main]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .
      - name: Push to registry
        run: |
          echo ${{ secrets.DOCKER_PASSWORD }} | docker login -u ${{ secrets.DOCKER_USERNAME }} --password-stdin
          docker push myapp:${{ github.sha }}
```

### Registry Management
```bash
# Private registry
docker run -d -p 5000:5000 --name registry registry:2

# Tag voor private registry
docker tag myapp:latest localhost:5000/myapp:latest

# Push naar private registry
docker push localhost:5000/myapp:latest
```

### Backup & Recovery
```bash
# Image backup
docker save myapp:latest > myapp.tar
docker load < myapp.tar

# Volume backup
docker run --volumes-from mycontainer -v $(pwd):/backup busybox tar czf /backup/backup.tar.gz /data

# Container export
docker export mycontainer > container.tar
cat container.tar | docker import - myimage:latest
```

## 14. Troubleshooting

### Common Issues
```bash
# Container won't start
docker logs mycontainer
docker inspect mycontainer
docker events --filter container=mycontainer

# Network issues
docker network ls
docker network inspect bridge
docker exec mycontainer netstat -tlnp

# Storage issues
docker system df
docker volume ls
docker volume inspect myvolume
```

### Debug Techniques
```bash
# Interactive debugging
docker run -it --entrypoint /bin/bash myimage
docker exec -it mycontainer /bin/bash

# Process inspection
docker top mycontainer
docker exec mycontainer ps aux

# File system inspection
docker diff mycontainer
docker cp mycontainer:/path/to/file ./
```

## 15. Examen Tips & Belangrijke Commando's

### Meest Belangrijke Commando's
```bash
# Images
docker images
docker pull IMAGE
docker build -t NAME .
docker push NAME
docker rmi IMAGE

# Containers
docker ps -a
docker run [OPTIONS] IMAGE [COMMAND]
docker start/stop/restart CONTAINER
docker rm CONTAINER
docker logs CONTAINER
docker exec -it CONTAINER bash

# Volumes
docker volume ls
docker volume create NAME
docker volume inspect NAME
docker volume rm NAME

# Networks
docker network ls
docker network create NAME
docker network inspect NAME

# Compose
docker-compose up -d
docker-compose down
docker-compose ps
docker-compose logs

# Swarm
docker swarm init
docker service create --name NAME --replicas N IMAGE
docker service ls
docker service scale NAME=N
docker stack deploy -c docker-compose.yml STACK
```

### Veelvoorkomende Vragen
1. **Verschil CMD vs ENTRYPOINT**
2. **COPY vs ADD wanneer gebruiken**
3. **Volume vs Bind Mount**
4. **Dockerfile best practices**
5. **Networking in Docker**
6. **Swarm vs Compose**
7. **Multi-stage builds**
8. **Security considerations**

### Praktische Scenario's
- Web applicatie met database
- Microservices architectuur
- Load balancing setup
- Development environment
- CI/CD pipeline integration
- Production deployment
- Backup & recovery procedures

Deze uitgebreide studiehulp dekt alle aspecten van Docker die relevant zijn voor een examen, van basis concepten tot geavanceerde productie-scenario's.