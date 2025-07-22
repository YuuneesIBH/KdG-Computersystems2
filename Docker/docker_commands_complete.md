# Alle Docker Commando's - Compleet Overzicht

## 1. Basis System Commando's
```bash
# Installatie verificatie
docker version                      # Client en server versie
docker info                        # Uitgebreide system info
docker system df                   # Disk usage
docker system events              # Real-time events

# Non-root gebruiker setup
sudo usermod -aG docker $USER      # Gebruiker toevoegen aan docker group
```

## 2. Image Management
```bash
# Basis image operaties
docker pull ubuntu                 # Image downloaden van Docker Hub
docker build -t naam .             # Image bouwen met Dockerfile
docker images                      # Overzicht van lokale images
docker rmi IMAGE                   # Image verwijderen
docker push NAME                   # Image uploaden naar registry

# Geavanceerde image operaties
docker image inspect ubuntu:20.04  # Detailinfo over image
docker image history ubuntu:20.04  # Layer geschiedenis
docker image ls --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"
docker image prune                 # Dangling images verwijderen
docker image prune -a              # Alle ongebruikte images verwijderen

# Image backup/restore
docker save myapp:latest > myapp.tar     # Image exporteren
docker load < myapp.tar                  # Image importeren
docker tag myapp:latest localhost:5000/myapp:latest  # Image taggen
```

## 3. Container Management
```bash
# Basis container operaties
docker run [OPTIONS] IMAGE         # Container starten
docker run -it IMAGE bash          # Interactieve sessie
docker run -d IMAGE                # Detached run
docker ps                          # Lopende containers
docker ps -a                       # Alle containers tonen
docker start/stop/restart CONTAINER
docker rm CONTAINER                # Container verwijderen
docker logs CONTAINER              # Logs bekijken
docker logs -f --tail=50 CONTAINER # Follow logs met laatste 50 lijnen
docker exec -it CONTAINER bash     # Command uitvoeren in container

# Geavanceerde container operaties
docker container inspect mycontainer
docker container inspect --format='{{.State.Status}}' mycontainer
docker container stats mycontainer # Resource usage
docker top mycontainer             # Processen in container
docker diff mycontainer            # Filesystem changes
docker cp mycontainer:/path/to/file ./  # Bestanden kopiëren

# Container export/import
docker export mycontainer > container.tar
docker import container.tar myimage:latest

# Resource limits
docker run --cpus="1.5" --memory="2g" nginx
docker run --memory="512m" --memory-swap="1g" nginx
docker run --cpu-shares=512 nginx

# Security opties
docker run --user 1000:1000 nginx
docker run --read-only --tmpfs /tmp nginx
docker run --cap-drop ALL --cap-add NET_BIND_SERVICE nginx
docker run --security-opt no-new-privileges nginx
```

## 4. Networking
```bash
# Basis networking
docker run -p 8080:80 nginx              # Port mapping host:container
docker run -p 127.0.0.1:8080:80 nginx   # Specifiek IP
docker run -p 127.0.0.1::80 nginx       # Random host port
docker run -P nginx                      # Alle EXPOSED ports
docker run -p 8080:80/tcp nginx         # Protocol specificatie
docker run -p 80:80 -p 443:443 nginx    # Multiple ports

# Network management
docker network ls                        # Netwerken tonen
docker network create mybridge          # Custom bridge netwerk
docker network create --driver bridge isolated_network
docker network create --subnet=192.168.1.0/24 mynetwork
docker network inspect bridge           # Network details
docker network rm NETWORK               # Network verwijderen

# Geavanceerde networking
docker run --network host nginx         # Host networking
docker run --network mynetwork --ip 192.168.1.100 nginx  # Static IP
docker run --dns 8.8.8.8 --dns 8.8.4.4 nginx            # Custom DNS
docker run --network mynetwork --network-alias webserver nginx

# Network troubleshooting
docker port mycontainer
docker exec mycontainer netstat -tlnp
docker inspect --format='{{.NetworkSettings.IPAddress}}' mycontainer
```

## 5. Volume Management
```bash
# Volume basis operaties
docker volume ls                        # Volumes tonen
docker volume create mydata             # Named volume aanmaken
docker volume inspect mydata            # Volume details
docker volume rm NAME                   # Volume verwijderen
docker volume prune                     # Ongebruikte volumes verwijderen

# Volume mounting
docker run -v mydata:/app/data nginx               # Named volume
docker run -v /host/path:/container/path nginx     # Bind mount
docker run -v /host/path:/container/path:ro nginx  # Read-only
docker run -v $(pwd):/app nginx                    # Current directory
docker run --tmpfs /tmp nginx                      # tmpfs mount

# Modern mount syntax
docker run --mount type=volume,source=myvolume,target=/data nginx
docker run --mount type=bind,source=/host/path,target=/app nginx
docker run --mount type=tmpfs,target=/tmp nginx
docker run --mount type=bind,source=/host/path,target=/app,readonly nginx

# Volume backup/restore
docker run --volumes-from mycontainer -v $(pwd):/backup busybox tar czf /backup/backup.tar.gz /data
docker run --volumes-from mycontainer -v $(pwd):/backup busybox tar xzf /backup/backup.tar.gz -C /

# Advanced volume creation
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.100,rw \
  --opt device=:/path/to/dir \
  nfsvolume
```

## 6. Build Commando's
```bash
# Basis build
docker build -t myapp:1.0 .
docker build -f Dockerfile.prod .

# Build met argumenten
docker build \
  --build-arg BUILD_DATE=$(date -u +'%Y-%m-%dT%H:%M:%SZ') \
  --build-arg VERSION=1.0 \
  -t myapp:1.0 .

# Multi-platform builds
docker build --platform linux/amd64 .
```

## 7. Docker Compose
```bash
# Basis compose operaties
docker-compose up                   # Services starten
docker-compose up -d               # Detached mode
docker-compose down                # Services stoppen en verwijderen
docker-compose ps                  # Service status
docker-compose logs                # Logs van alle services
docker-compose logs SERVICE        # Logs van specifieke service
docker-compose stop                # Services stoppen
docker-compose start               # Services starten
docker-compose restart             # Services herstarten

# Geavanceerde compose operaties
docker-compose up --scale web=3    # Service scaling
docker-compose up --scale worker=5
docker-compose build              # Images rebuilden
docker-compose pull               # Images updaten
docker-compose config             # Configuratie valideren
docker-compose exec SERVICE bash  # Command in service
```

## 8. Docker Swarm
```bash
# Swarm initialisatie
docker swarm init --advertise-addr <MANAGER-IP>
docker swarm join --token <WORKER-TOKEN> <MANAGER-IP>:2377
docker swarm join --token <MANAGER-TOKEN> <MANAGER-IP>:2377

# Token management
docker swarm join-token worker
docker swarm join-token manager

# Node management
docker node ls                     # Nodes in swarm
docker node inspect NODE
docker node update --label-add environment=production worker1

# Service management
docker service create --name web --replicas 3 --publish 80:80 nginx
docker service ls                  # Services tonen
docker service ps SERVICE         # Service tasks
docker service inspect SERVICE    # Service details
docker service update --replicas 5 web
docker service update --image nginx:1.20 web
docker service scale NAME=N       # Service scaling
docker service rm SERVICE         # Service verwijderen

# Advanced service creation
docker service create \
  --name web \
  --replicas 3 \
  --publish 80:80 \
  --network mynetwork \
  --constraint 'node.role == manager' \
  --update-parallelism 1 \
  --update-delay 10s \
  nginx

# Stack deployment
docker stack deploy -c docker-compose.yml mystack
docker stack ls                   # Stacks tonen
docker stack ps mystack          # Stack tasks
docker stack services mystack    # Stack services
docker stack rm mystack          # Stack verwijderen

# Secrets management
echo "mypassword" | docker secret create db_password -
docker secret ls
docker secret inspect SECRET
docker service create --secret db_password --name app myapp
```

## 9. Logging & Monitoring
```bash
# Container stats en monitoring
docker stats                      # Resource usage alle containers
docker stats CONTAINER           # Resource usage specifieke container
docker events --filter container=mycontainer

# Logging configuratie
docker run --log-driver json-file --log-opt max-size=10m nginx
docker run --log-driver syslog nginx
docker run --log-driver none nginx
docker run --log-driver fluentd --log-opt fluentd-address=localhost:24224 nginx

# Health checks
docker run --health-cmd="curl -f http://localhost:8080/health" nginx
```

## 10. System Management
```bash
# System cleanup
docker system prune               # Cleanup ongebruikte resources
docker system prune -a           # Cleanup alles ongebruikt
docker system prune -a --volumes # Cleanup inclusief volumes
docker container prune           # Cleanup stopped containers
docker image prune               # Cleanup dangling images
docker image prune -a            # Cleanup alle ongebruikte images
docker volume prune              # Cleanup ongebruikte volumes
docker network prune             # Cleanup ongebruikte networks

# System info
docker system df                 # Disk usage
docker system events            # System events
```

## 11. Registry Management
```bash
# Private registry
docker run -d -p 5000:5000 --name registry registry:2

# Registry login
docker login
docker login registry.example.com
echo $PASSWORD | docker login -u $USERNAME --password-stdin

# Image pushing/pulling
docker push localhost:5000/myapp:latest
docker pull localhost:5000/myapp:latest
```

## 12. Debug & Troubleshooting
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

# Network debugging
dig web.mynetwork                 # DNS resolution in swarm
```

## 13. Dockerfile Instructies
```dockerfile
# Base image
FROM ubuntu:20.04
FROM --platform=linux/amd64 ubuntu:20.04
FROM scratch

# Metadata
LABEL maintainer="dev@company.com"
LABEL version="1.0"
LABEL description="Production web server"

# Build-time execution
RUN apt-get update && apt-get install -y curl
RUN ["/bin/bash", "-c", "echo hello"]

# File operations
COPY src/ /app/src/               # Voorkeur voor simpel kopiëren
ADD app.tar.gz /app/             # Automatische extractie

# Runtime configuration
CMD ["echo", "Hello World"]      # Default command (overschrijfbaar)
ENTRYPOINT ["python", "app.py"]  # Entry point (niet overschrijfbaar)

# Environment
ENV NODE_ENV=production
ENV PATH="/app/bin:${PATH}"
ARG BUILD_DATE
ARG VERSION

# File system
WORKDIR /app                     # Working directory
VOLUME /data                     # Volume mount point
USER appuser                     # Run as user

# Network
EXPOSE 8080                      # Document ports

# Build triggers
ONBUILD COPY . /app              # Voor base images

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8080/health || exit 1
```

## 14. I/O & Performance
```bash
# I/O limits
docker run --device-read-bps=/dev/sda:1mb nginx
docker run --device-write-bps=/dev/sda:1mb nginx

# Performance monitoring
docker exec mycontainer cat /proc/meminfo
docker exec mycontainer cat /proc/loadavg
```

Deze lijst bevat alle commando's die in het studiemateriaal besproken werden, van basis operaties tot geavanceerde productie-scenario's.