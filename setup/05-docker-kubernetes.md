# Docker & Kubernetes

Complete containerization and orchestration setup for development.

## Prerequisites

- [System Setup](01-system-setup.md) completed
- Homebrew installed
- At least 8GB RAM available

## 1. Docker Desktop

Docker Desktop is the easiest way to get Docker on macOS with full GUI support.

```bash
# Install Docker Desktop
brew install --cask docker

# Start Docker Desktop
open -a Docker

# Wait for Docker to start (check menu bar icon)
# Once running, verify installation
docker --version
docker compose version

# Expected output:
# Docker version 24.0.x
# Docker Compose version v2.x.x
```

### Configure Docker Desktop

1. Open Docker Desktop preferences (⌘,)
2. **Resources** → Set memory to at least 4GB (8GB recommended)
3. **General** → Enable "Start Docker Desktop when you log in"
4. **Features in development** → Enable "Use containerd for pulling and storing images"

### Verify Docker is Running

```bash
# Check Docker daemon
docker ps

# Run test container
docker run hello-world

# Should see: "Hello from Docker!"
```

## 2. Kubernetes Tools

### kubectl (Kubernetes CLI)

```bash
# Install kubectl
brew install kubectl

# Verify installation
kubectl version --client

# Set up autocomplete
echo 'source <(kubectl completion zsh)' >> ~/.zshrc
source ~/.zshrc

# Alias for convenience (optional)
echo 'alias k=kubectl' >> ~/.config/zsh/aliases/aliases.zsh
```

### Minikube (Local Kubernetes)

```bash
# Install minikube
brew install minikube

# Start minikube (uses Docker driver on macOS)
minikube start --driver=docker

# Verify cluster is running
kubectl cluster-info
kubectl get nodes

# Enable useful addons
minikube addons enable dashboard
minikube addons enable metrics-server
minikube addons enable ingress

# Access Kubernetes dashboard
minikube dashboard
```

### Helm (Package Manager for Kubernetes)

```bash
# Install Helm
brew install helm

# Verify installation
helm version

# Add common repositories
helm repo add stable https://charts.helm.sh/stable
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Search for charts
helm search repo postgresql
```

### k9s (Terminal UI for Kubernetes)

```bash
# Install k9s
brew install k9s

# Launch k9s (must have kubectl configured)
k9s

# Keyboard shortcuts in k9s:
# - :pods (or just :po) - view pods
# - :svc - view services
# - :deploy - view deployments
# - Ctrl+a - show all namespaces
# - / - filter resources
# - d - describe resource
# - l - view logs
# - ? - help
```

## 3. Docker Commands Reference

### Container Management

```bash
# List running containers
docker ps

# List all containers (including stopped)
docker ps -a

# Run container
docker run nginx

# Run container in background
docker run -d nginx

# Run with port mapping
docker run -d -p 8080:80 nginx

# Run with name
docker run -d --name my-nginx nginx

# Stop container
docker stop my-nginx

# Start stopped container
docker start my-nginx

# Remove container
docker rm my-nginx

# Force remove running container
docker rm -f my-nginx

# View container logs
docker logs my-nginx

# Follow logs in real-time
docker logs -f my-nginx

# Execute command in container
docker exec -it my-nginx bash

# Inspect container
docker inspect my-nginx
```

### Image Management

```bash
# List images
docker images

# Pull image
docker pull nginx

# Pull specific version
docker pull nginx:1.25

# Build image from Dockerfile
docker build -t my-app:latest .

# Tag image
docker tag my-app:latest my-app:v1.0

# Push to registry
docker push my-app:latest

# Remove image
docker rmi nginx

# Remove unused images
docker image prune

# Remove all images
docker image prune -a
```

### Docker Compose

```bash
# Start services defined in docker-compose.yml
docker compose up

# Start in background
docker compose up -d

# Stop services
docker compose down

# Stop and remove volumes
docker compose down -v

# View logs
docker compose logs

# Follow logs
docker compose logs -f

# List running services
docker compose ps

# Restart services
docker compose restart

# Build images
docker compose build

# Pull latest images
docker compose pull
```

### System Maintenance

```bash
# View disk usage
docker system df

# Clean up everything (use with caution!)
docker system prune

# Remove stopped containers, unused networks, dangling images
docker system prune -a

# Remove volumes
docker volume prune

# Show Docker info
docker info
```

## 4. Dockerfile Examples

### Node.js Application

```dockerfile
FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production

# Copy application files
COPY . .

# Expose port
EXPOSE 3000

# Start application
CMD ["node", "index.js"]
```

### Python Application

```dockerfile
FROM python:3.12-slim

WORKDIR /app

# Copy requirements
COPY requirements.txt .

# Install dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Expose port
EXPOSE 8000

# Run application
CMD ["python", "app.py"]
```

### Java Spring Boot

```dockerfile
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Copy JAR file
COPY target/*.jar app.jar

# Expose port
EXPOSE 8080

# Run application
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Multi-stage Build (Node.js)

```dockerfile
# Build stage
FROM node:20-alpine AS builder

WORKDIR /app
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM node:20-alpine

WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules
COPY package*.json ./

EXPOSE 3000
CMD ["node", "dist/index.js"]
```

## 5. Docker Compose Examples

### Full Stack Application

```yaml
version: '3.8'

services:
  # Frontend
  frontend:
    build: ./frontend
    ports:
      - "3000:3000"
    environment:
      - API_URL=http://backend:8080
    depends_on:
      - backend

  # Backend API
  backend:
    build: ./backend
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://user:pass@db:5432/myapp
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis

  # PostgreSQL Database
  db:
    image: postgres:15
    environment:
      POSTGRES_USER: user
      POSTGRES_PASSWORD: pass
      POSTGRES_DB: myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

  # Redis Cache
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

## 6. Kubernetes Quick Start

### Deploy Application

```bash
# Create deployment
kubectl create deployment nginx --image=nginx

# Expose deployment as service
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Get service URL (minikube)
minikube service nginx --url

# Scale deployment
kubectl scale deployment nginx --replicas=3

# View pods
kubectl get pods

# View services
kubectl get services

# Delete deployment
kubectl delete deployment nginx
```

### Using YAML Files

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:latest
        ports:
        - containerPort: 8080

---
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
  - port: 80
    targetPort: 8080
  type: LoadBalancer
```

```bash
# Apply configuration
kubectl apply -f deployment.yaml

# Delete resources
kubectl delete -f deployment.yaml
```

## 7. Troubleshooting

### Docker Desktop Not Starting

```bash
# Restart Docker Desktop
killall Docker && open -a Docker

# Check Docker daemon logs
# In Docker Desktop: Troubleshoot → View logs

# Reset Docker Desktop (last resort)
# Docker Desktop menu → Troubleshoot → Reset to factory defaults
```

### Port Already in Use

```bash
# Find process using port
lsof -i :5432

# Kill process
kill -9 <PID>

# Or change Docker port mapping
# In docker-compose.yml: "5433:5432" instead of "5432:5432"
```

### Container Won't Start

```bash
# Check logs
docker logs <container-name>

# Check container status
docker inspect <container-name>

# Try running interactively
docker run -it <image-name> sh
```

### Minikube Issues

```bash
# Delete and recreate cluster
minikube delete
minikube start

# Check minikube status
minikube status

# Access minikube VM
minikube ssh

# View minikube logs
minikube logs
```

## 8. Best Practices

### 1. Use .dockerignore

```
# .dockerignore
node_modules/
npm-debug.log
.git/
.env
.DS_Store
dist/
build/
*.md
```

### 2. Multi-stage Builds

Use multi-stage builds to keep images small:
- Build stage: install all dependencies, compile
- Production stage: copy only what's needed to run

### 3. Don't Run as Root

```dockerfile
# Create non-root user
RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
USER nodejs
```

### 4. Use Specific Tags

```dockerfile
# Bad: uses latest (unpredictable)
FROM node:latest

# Good: uses specific version
FROM node:20.10.0-alpine
```

### 5. Layer Caching

Order Dockerfile commands from least to most frequently changing:

```dockerfile
# Dependencies (rarely change)
COPY package*.json ./
RUN npm install

# Source code (changes often)
COPY . .
```

## Next Steps

Continue with:
- **[Databases](06-databases.md)** - Context-aware database setup
- **[IDEs & Editors](09-ides-editors.md)** - Development environment setup

---

**Estimated Time**: 25 minutes  
**Difficulty**: Intermediate  
**Last Updated**: October 5, 2025
