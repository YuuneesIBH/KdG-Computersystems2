# Docker Examen Samenvatting - Commands & Dockerfile Focus

## 1. Docker Basic Commands

### Image Management
```bash
# Images zoeken
docker search centos

# Images downloaden (PULL)
docker pull ubuntu
docker pull ubuntu:18.04

# Lokale images bekijken
docker images
docker image ls

# Images verwijderen
docker rmi image_name
docker image rm image_name
```

### Container Management
```bash
# Container opstarten
docker run ubuntu
docker run -it ubuntu /bin/bash          # Interactive
docker run -d nginx                      # Detached (daemon)
docker run --name mycontainer ubuntu     # Met naam

# Running containers bekijken
docker ps
docker container ls

# Alle containers (ook stopped)
docker ps -a
docker container ls -a

# Container stoppen/starten
docker stop container_id
docker start container_id
docker restart container_id

# Container verwijderen
docker rm container_id
docker rm -f container_id               # Force remove running container
```

### Container Inspection
```bash
# Container details
docker inspect container_id
docker inspect --format='{{.NetworkSettings.IPAddress}}' container_id

# Container logs
docker logs container_id
docker logs -f container_id             # Follow logs

# In container gaan
docker exec -it container_id /bin/bash
```

## 2. Dockerfile - Complete Reference

### Basic Dockerfile Structure
```dockerfile
# Comments start with #
FROM ubuntu:18.04
MAINTAINER Jan Celis jan.celis@kdg.be    # DEPRECATED
LABEL maintainer="peter.cornelissen@kdg.be"
RUN apt-get update && apt-get install -y apache2
CMD echo "Hello World!"
```

### FROM - Base Image
```dockerfile
FROM ubuntu:18.04
FROM busybox:latest
FROM node:14-alpine
```

### LABEL - Metadata (vervangt MAINTAINER)
```dockerfile
LABEL maintainer="peter.cornelissen@kdg.be"
LABEL author="Jan Celis <jan.celis@kdg.be>"
LABEL version="1.0"
LABEL description="This image description \
can span multiple lines."
```

### RUN - Build Time Commands
```dockerfile
# Shell form (default: /bin/sh -c)
RUN apt-get update && apt-get install -y apache2
RUN echo "Hello" > /tmp/hello.txt

# Exec form (JSON array)
RUN ["apt-get", "update"]
RUN ["/bin/bash", "-c", "echo hello"]
```

### CMD - Runtime Commands
```dockerfile
# Shell form
CMD echo hello world!
CMD apache2ctl -D FOREGROUND

# Exec form
CMD ["echo", "hello world"]
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

# As parameters to ENTRYPOINT
CMD ["param1", "param2"]
```

### ENTRYPOINT - Application Entry Point
```dockerfile
# Shell form
ENTRYPOINT /bin/echo

# Exec form
ENTRYPOINT ["/bin/echo"]
ENTRYPOINT ["apache2ctl", "-D", "FOREGROUND"]

# Combined with CMD
ENTRYPOINT ["/bin/echo"]
CMD ["hello world"]
```

**BELANGRIJK:** 
- Slechts de LAATSTE CMD/ENTRYPOINT wordt gebruikt
- ENTRYPOINT kan overridden worden met `--entrypoint` option
- CMD kan overridden worden door arguments te geven aan `docker run`

### COPY vs ADD
```dockerfile
# COPY - Simple file/directory copy
COPY ./website/*.html /var/www/
COPY ["./app", "/usr/src/app"]

# ADD - Advanced copy (can handle TAR + remote URLs)
ADD ./website/website.tar /var/www/      # Auto-extracts TAR
ADD https://example.com/file.txt /tmp/   # Downloads from URL
ADD ./app /usr/src/app
```

### ENV - Environment Variables
```dockerfile
# New syntax (preferred)
ENV MYSQL_ROOT_PASSWORD="Secret007"
ENV NODE_ENV=production
ENV PATH="/usr/local/bin:$PATH"

# Old syntax (still works)
ENV MYSQL_ROOT_PASSWORD Secret007
```

### EXPOSE - Port Documentation
```dockerfile
EXPOSE 80
EXPOSE 8080/tcp
EXPOSE 53/udp
EXPOSE 80 443 8080
```

### VOLUME - Mount Points
```dockerfile
# Shell form
VOLUME /var/log

# JSON form
VOLUME ["/var/log"]
VOLUME ["/var/log", "/var/db"]
```

### WORKDIR - Working Directory
```dockerfile
WORKDIR /app
WORKDIR /usr/src/app
RUN mkdir -p /scripts
WORKDIR /scripts
```

### USER - Run as User
```dockerfile
# Create user first
RUN groupadd user1
RUN useradd -r -u 1001 -g user1 user1
USER user1

# Or with UID/GID
USER 1008:1200
USER webadmin:webgroup
```

### ONBUILD - Triggered Instructions
```dockerfile
ONBUILD ADD . /app/src
ONBUILD RUN /usr/bin/python-build --dir /app/src
```

## 3. Building & Running

### Build Commands
```bash
# Build from Dockerfile in current directory
docker build .
docker build -t myapp .
docker build -t username/myapp:v1.0 .
docker build -f CustomDockerfile .

# No cache
docker build --no-cache -t myapp .
```

### Run Commands with Options
```bash
# Basic run
docker run myapp
docker run username/myapp:v1.0

# Interactive
docker run -it myapp /bin/bash

# Detached
docker run -d myapp

# With name
docker run --name mycontainer myapp

# Override CMD
docker run myapp echo "Different command"

# Override ENTRYPOINT
docker run --entrypoint="" myapp /bin/bash
```

## 4. Volume Commands

### Volume Management
```bash
# Create volume
docker volume create myvol
docker volume create --name webdata

# List volumes
docker volume ls

# Inspect volume
docker volume inspect myvol

# Remove volume
docker volume rm myvol
docker volume rm $(docker volume ls -q)  # Remove all
```

### Using Volumes
```bash
# Named volume
docker run -v myvol:/var/www/html nginx

# Bind mount (host directory)
docker run -v /host/path:/container/path nginx
docker run -v $(pwd):/app node:14

# Read-only
docker run -v /host/path:/container/path:ro nginx

# Using --mount (preferred)
docker run --mount type=volume,src=myvol,dst=/var/www/html nginx
docker run --mount type=bind,src=/host/path,dst=/container/path nginx
```

### Volume in Dockerfile
```dockerfile
VOLUME /mymountpoint
# Creates mount-point, can be linked with -v option
```

## 5. Networking Commands

### Basic Networking
```bash
# List networks
docker network ls

# Inspect network
docker network inspect bridge

# Container IP
docker inspect --format='{{.NetworkSettings.IPAddress}}' container_id
```

### Port Mapping
```bash
# Auto-assign host port
docker run -p 80 nginx

# Specific host:container port
docker run -p 8080:80 nginx

# Specific IP and ports
docker run -p 192.168.1.10:8080:80 nginx

# Multiple ports
docker run -p 80:80 -p 443:443 nginx

# Use EXPOSE ports automatically
docker run -P nginx  # Uses all EXPOSED ports
```

### Port Information
```bash
# Show port mappings
docker ps
docker port container_id
docker inspect container_id  # Look for "PortBindings"
```

### Network Options
```bash
# Custom network settings
docker run --net=bridge nginx
docker run --ip="172.17.17.3" nginx
docker run --mac="02:42:ac:11:00:02" nginx
docker run --dns="8.8.8.8" nginx
```

## 6. Docker Hub & Publishing

### Login & Push
```bash
# Login to Docker Hub
docker login

# Tag image for pushing
docker tag myapp username/myapp:latest
docker tag myapp username/myapp:v1.0

# Push to Docker Hub
docker push username/myapp:latest
docker push username/myapp:v1.0
```

### Build with Username
```bash
# Build directly with username
docker build -t username/myapp:latest .
```

## 7. Docker Compose

### docker-compose.yml Structure
```yaml
version: "3"
services:
  web:
    build: .                    # Build from Dockerfile
    # OR
    image: nginx:latest         # Use existing image
    ports:
      - "8080:80"
    volumes:
      - ./html:/var/www/html
      - webdata:/var/log/nginx
    environment:
      - NODE_ENV=production
    depends_on:
      - db
    
  db:
    image: mysql:5.7
    environment:
      MYSQL_ROOT_PASSWORD: secret
      MYSQL_DATABASE: myapp
    volumes:
      - dbdata:/var/lib/mysql

volumes:
  webdata:
  dbdata:
```

### Docker Compose Commands
```bash
# Start services
docker-compose up
docker-compose up -d              # Detached

# Stop services
docker-compose down
docker-compose down -v            # Remove volumes too

# Build services
docker-compose build
docker-compose build --no-cache

# View services
docker-compose ps
docker-compose logs
docker-compose logs -f service_name

# Scale services
docker-compose up --scale web=3

# Remove containers
docker-compose rm
docker-compose rm -v             # Remove volumes too
```

## 8. Docker Swarm Commands

### Initialize Swarm
```bash
# Initialize swarm (becomes manager)
docker swarm init

# Join as worker
docker swarm join --token <token> <manager-ip>:2377

# View nodes
docker node ls
```

### Services in Swarm
```bash
# Create service
docker service create --name webserver --publish 8080:80 nginx

# Scale service
docker service update --replicas 5 webserver
docker service scale webserver=3

# List services
docker service ls

# Service details
docker service ps webserver
docker service inspect webserver

# Remove service
docker service rm webserver
```

### Stack Deployment
```bash
# Deploy stack from compose file
docker stack deploy --compose-file docker-compose.yml mystack

# List stacks
docker stack ls

# Stack services
docker stack services mystack

# Remove stack
docker stack rm mystack
```

## 9. Optimization & Best Practices

### .dockerignore File
```
# Comments
temp*
*.tmp
.git
node_modules
PASSWORDFILE
```

### Cache & Refresh
```dockerfile
# Force cache miss for updates
FROM ubuntu:18.04
LABEL maintainer="jan.celis@kdg.be"
ENV REFRESHED_AT 2024-01-15      # Change date to bust cache
RUN apt-get -qq update
```

### Multi-stage Build Example
```dockerfile
# Build stage
FROM node:14 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

# Production stage
FROM nginx:alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## 10. Troubleshooting Commands

### Cleanup Commands
```bash
# Remove stopped containers
docker container prune

# Remove unused images
docker image prune
docker image prune -a            # Remove all unused

# Remove unused volumes
docker volume prune

# Remove unused networks
docker network prune

# Complete cleanup
docker system prune
docker system prune -a           # Remove everything unused

# Remove specific items
docker rm $(docker ps -aq)      # Remove all containers
docker rmi $(docker images -q)   # Remove all images
```

### Debug Commands
```bash
# Container processes
docker top container_id

# Resource usage
docker stats
docker stats container_id

# Container changes
docker diff container_id

# Export/Import
docker export container_id > container.tar
docker import container.tar newimage:tag

# Save/Load images
docker save image_name > image.tar
docker load < image.tar
```

## 11. Exam Tips & Key Points

### Dockerfile Best Practices
- **FROM**: Altijd een base image specificeren
- **RUN**: Chain commands met `&&` voor minder layers
- **CMD vs ENTRYPOINT**: CMD kan overridden, ENTRYPOINT niet (behalve met --entrypoint)
- **COPY vs ADD**: Gebruik COPY tenzij je TAR extract of URL download nodig hebt
- **VOLUME**: Maak mountpoints voor persistent data
- **EXPOSE**: Documenteer welke poorten gebruikt worden
- **USER**: Run als non-root user voor security

### Command Patterns
- **Build**: `docker build -t name:tag .`
- **Run Interactive**: `docker run -it image bash`
- **Run Detached**: `docker run -d image`
- **Port Mapping**: `docker run -p host:container image`
- **Volume Mount**: `docker run -v host:container image`
- **Exec into Container**: `docker exec -it container bash`

### Volume Patterns
- **Named Volume**: `-v volumename:/path`
- **Bind Mount**: `-v /host/path:/container/path`
- **Read-only**: `-v /host/path:/container/path:ro`

### Network Patterns
- **Port**: `-p 8080:80` (host:container)
- **All EXPOSE ports**: `-P`
- **Get Container IP**: `docker inspect --format='{{.NetworkSettings.IPAddress}}' container`

### Remember
- Containers zijn **temporary** - gebruik volumes voor persistent data
- Images zijn **read-only** - containers voegen R/W layer toe
- **Union filesystem** zorgt voor layering
- **Copy-on-Write** voor efficiëntie
- Docker Hub is default registry
- Swarm voor clustering en scaling
- Docker Compose voor multi-container applicaties