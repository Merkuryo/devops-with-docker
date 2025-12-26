# Exercise 3.7 Setup & Verification Guide

## Prerequisites

```bash
# Verify Docker is running
docker --version

# Clone/navigate to exercise directory
cd 3.7-project-with-preinstalled-environments
```

## Step 1: Inspect Preinstalled Images

### Node.js Alpine Image

```bash
# Pull the image (if not already present)
docker pull node:16-alpine

# Verify Node.js and npm are available
docker run --rm node:16-alpine node --version
docker run --rm node:16-alpine npm --version

# Expected output:
# v16.x.x
# 7.x.x or 8.x.x
```

### Go Alpine Image

```bash
# Pull the image
docker pull golang:1.16-alpine

# Verify Go compiler is available
docker run --rm golang:1.16-alpine go version

# Expected output:
# go version go1.16.x linux/amd64
```

## Step 2: Build Frontend Image

### Build Command

```bash
docker build -f Dockerfile.frontend -t frontend:preinstalled .
```

### Verify Build

```bash
# Check image was created
docker images | grep frontend:preinstalled

# Expected output:
# frontend   preinstalled   <IMAGE_ID>   <CREATED>   ~200MB
```

### Analyze Layers

```bash
docker image history frontend:preinstalled --human --no-trunc

# Expected layers:
# FROM node:16-alpine          (176MB)
# RUN apk add dumb-init        (< 1MB)
# RUN addgroup + adduser       (0MB - metadata)
# COPY .                       (5MB - source code)
# RUN npm install --production (~15MB)
# WORKDIR /usr/src/app        (0MB - metadata)
# USER appuser               (0MB - metadata)
# EXPOSE 5000                (0MB - metadata)
# CMD npm start              (0MB - metadata)
```

## Step 3: Build Backend Image

### Build Command

```bash
docker build -f Dockerfile.backend -t backend:preinstalled .
```

### Verify Build

```bash
# Check image was created
docker images | grep backend:preinstalled

# Expected output:
# backend   preinstalled   <IMAGE_ID>   <CREATED>   ~400MB
```

### Analyze Layers

```bash
docker image history backend:preinstalled --human --no-trunc

# Expected layers:
# FROM golang:1.16-alpine      (376MB)
# RUN apk add git              (< 1MB)
# RUN addgroup + adduser       (0MB - metadata)
# COPY .                       (20MB - source code)
# RUN go build -o server       (~10MB - binary)
# WORKDIR /usr/src/app        (0MB - metadata)
# USER appuser               (0MB - metadata)
# EXPOSE 8080                (0MB - metadata)
# CMD ./server               (0MB - metadata)
```

## Step 4: Test Frontend

### Start Container

```bash
docker run -p 5000:5000 frontend:preinstalled
```

### Verify in Another Terminal

```bash
# Check if server is running
curl http://localhost:5000

# Expected: HTML response (the web app)

# Check logs
docker logs <CONTAINER_ID>

# Should show:
# npm info ok
# Server running on port 5000
```

### Container Details

```bash
# Get container ID
FRONTEND_ID=$(docker ps | grep frontend:preinstalled | awk '{print $1}')

# Check running process
docker top $FRONTEND_ID

# Should show:
# dumb-init (PID 1) - signal handler
# npm (child process) - app process
# node (child process) - actual app
```

## Step 5: Test Backend

### Start Container

```bash
docker run -p 8080:8080 backend:preinstalled
```

### Verify in Another Terminal

```bash
# Check if server is running
curl http://localhost:8080/health

# Expected: Health status response

# Check logs
docker logs <CONTAINER_ID>

# Should show:
# Server started on port 8080
```

### Container Details

```bash
# Get container ID
BACKEND_ID=$(docker ps | grep backend:preinstalled | awk '{print $1}')

# Check running process
docker top $BACKEND_ID

# Should show:
# main process (PID 1) - Go binary
# No shell (good for security)
```

## Step 6: Compare Image Sizes

### Size Analysis

```bash
# List all images with sizes
docker images

# Compare with previous exercises

# Expected frontend progression:
# node:16 (full Debian)    ~913MB
# node:16-alpine (3.6)     ~200MB
# node:16-alpine (3.7)     ~200MB
#
# Why same? Because 3.6 already used preinstalled!

# Expected backend progression:
# golang:1.16 (full Debian)     ~968MB
# golang:1.16-alpine (3.6)      ~400MB
# golang:1.16-alpine (3.7)      ~400MB
#
# Why same? Because 3.6 already used preinstalled!
```

### Detailed Size Breakdown

```bash
# Frontend layer sizes
docker image history frontend:preinstalled --human

# Add up layer sizes to understand composition:
# Base image (node:16-alpine): 176MB
# Application code: 5MB
# Dependencies (npm): 15MB
# Tools (dumb-init): <1MB
# Other: 4MB
# = ~200MB total

# Backend layer sizes
docker image history backend:preinstalled --human

# Composition:
# Base image (golang:1.16-alpine): 376MB
# Application code: 20MB
# Compiled binary: 10MB
# Total: ~400MB
```

## Step 7: Verify Non-Root User Execution

### Frontend User Check

```bash
# Start container and check user
docker run --rm frontend:preinstalled whoami

# Expected output:
# appuser
```

### Backend User Check

```bash
# Start container and check user
docker run --rm backend:preinstalled whoami

# Expected output:
# appuser
```

### Security Verification

```bash
# Try to run as root (should fail or show non-root user)
docker run -u root:root frontend:preinstalled whoami

# Check UID/GID
docker run --rm frontend:preinstalled id

# Expected output:
# uid=1001(appuser) gid=1001(appgroup) groups=1001(appgroup)
```

## Step 8: Test Signal Handling (Frontend)

### Signal Propagation Test

```bash
# Start frontend
docker run --name frontend-test frontend:preinstalled

# In another terminal, send SIGTERM
docker stop frontend-test

# Check logs - should show graceful shutdown
docker logs frontend-test

# Without dumb-init: SIGTERM wouldn't reach npm/node properly
# With dumb-init: Signals propagate correctly
```

## Step 9: Inspect Image Configuration

### Frontend Image Config

```bash
docker image inspect frontend:preinstalled --format='{{.Config}}' | python3 -m json.tool

# Or specific fields:
docker image inspect frontend:preinstalled --format='{{.Config.User}}'
# Expected: appuser

docker image inspect frontend:preinstalled --format='{{.Config.Cmd}}'
# Expected: ["dumb-init","--","npm","start"]

docker image inspect frontend:preinstalled --format='{{.Config.ExposedPorts}}'
# Expected: 5000/tcp
```

### Backend Image Config

```bash
docker image inspect backend:preinstalled --format='{{.Config}}'

# Specific fields:
docker image inspect backend:preinstalled --format='{{.Config.User}}'
# Expected: appuser

docker image inspect backend:preinstalled --format='{{.Config.Cmd}}'
# Expected: ["./server"]

docker image inspect backend:preinstalled --format='{{.Config.ExposedPorts}}'
# Expected: 8080/tcp
```

## Step 10: Run Docker Compose (If Available)

### Combined Startup

If docker-compose.yml exists from previous exercises:

```bash
# Update service images to use preinstalled versions
# frontend:
#   build:
#     context: .
#     dockerfile: Dockerfile.frontend
# backend:
#   build:
#     context: .
#     dockerfile: Dockerfile.backend

docker-compose build
docker-compose up -d

# Verify both services
curl http://localhost:5000
curl http://localhost:8080/health

# Check logs
docker-compose logs

# Cleanup
docker-compose down
```

## Troubleshooting

### Issue: Image build fails with "not found"

```
Error: apk: not found
```

**Cause:** Not using Alpine base image
**Solution:** Ensure `FROM node:16-alpine` (not `FROM node:16`)

### Issue: npm command not found

```
Error: npm: command not found
```

**Cause:** Base image doesn't include npm
**Solution:** Use `node:16-alpine` (includes npm)

### Issue: Container exits immediately

```
docker run frontend:preinstalled
# Container exits
```

**Cause:** Application not starting correctly
**Solution:**
```bash
# Check logs
docker run frontend:preinstalled npm list
# Check if node_modules installed
# Verify npm install ran
```

### Issue: Port already in use

```
Error: bind: address already in use
```

**Solution:**
```bash
# Use different port
docker run -p 5001:5000 frontend:preinstalled

# Or stop existing container
docker ps
docker stop <CONTAINER_ID>
```

### Issue: Permission denied on /usr/src/app

```
Error: EACCES: permission denied
```

**Cause:** Files not owned by appuser
**Solution:** Ensure `chown -R appuser:appgroup` in Dockerfile

## Performance Comparison

### Build Time

```bash
# Time frontend build
time docker build -f Dockerfile.frontend -t frontend:preinstalled .

# Expected: ~20-30 seconds
# (Mainly npm install time, not image download)

# Time backend build
time docker build -f Dockerfile.backend -t backend:preinstalled .

# Expected: ~10-15 seconds
# (Mainly go build time, not compilation from source)
```

### Startup Time

```bash
# Frontend startup
time docker run -p 5000:5000 frontend:preinstalled &
sleep 2 && curl http://localhost:5000
# Expected: <3 seconds to ready

# Backend startup
time docker run -p 8080:8080 backend:preinstalled &
sleep 2 && curl http://localhost:8080/health
# Expected: <2 seconds to ready
```

## Key Verification Points

- [ ] node:16-alpine image pulls successfully
- [ ] golang:1.16-alpine image pulls successfully
- [ ] Frontend image builds without errors
- [ ] Backend image builds without errors
- [ ] Frontend container runs on port 5000
- [ ] Backend container runs on port 8080
- [ ] Both containers execute as non-root user (appuser)
- [ ] Applications respond to requests correctly
- [ ] Image sizes are reasonable (~200MB frontend, ~400MB backend)
- [ ] Layer analysis shows efficient composition
- [ ] Signal handling works correctly (dumb-init)

## Cleanup

```bash
# Remove test containers
docker ps -a | grep preinstalled | awk '{print $1}' | xargs docker rm -f

# Remove test images (optional)
docker rmi frontend:preinstalled
docker rmi backend:preinstalled

# Verify cleanup
docker images | grep preinstalled
# Should show no results
```

## Summary

This exercise demonstrates:
1. **Preinstalled images** are the recommended approach
2. **Alpine variants** provide optimal size/performance tradeoff
3. **Official images** are maintained and secure
4. **Layer efficiency** is achieved through proper base image selection
5. **Security** is maintained with non-root user execution
6. **Signal handling** requires proper container init (dumb-init)

The key insight: Exercise 3.6 already used preinstalled images (`node:16-alpine`, `golang:1.16-alpine`). Exercise 3.7 reinforces why this is the right approach rather than manual environment installation.
