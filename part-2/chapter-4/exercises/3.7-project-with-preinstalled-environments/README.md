# Exercise 3.7: Project with Preinstalled Environments

## Overview

Optimize frontend and backend by using preinstalled environment images instead of manually installing dependencies. This approach leverages purpose-built base images like `node:16-alpine` and `golang:1.16-alpine` that come with required runtimes pre-configured.

## Preinstalled Environment Images

### What Are Preinstalled Images?

Preinstalled images come with the development environment already configured:

**Manual Installation (Old Approach):**
```dockerfile
FROM ubuntu:24.04
RUN apt-get update && apt-get install -y nodejs npm
# Larger, slower, more complexity
```

**Preinstalled Image (Better Approach):**
```dockerfile
FROM node:16-alpine
# Node.js and npm already installed
# Smaller, optimized, official support
```

### Benefits

✅ **Pre-optimized**: Maintained by language communities  
✅ **Smaller Size**: Only needed tools included  
✅ **Better Performance**: Optimized for production use  
✅ **Reliability**: Official support and security updates  
✅ **Multiple Variants**: Choose exact version and base image  

## Frontend: Node.js Preinstalled Image

**Base Image:** `node:16-alpine`
- Contains Node.js 16
- Contains npm package manager
- Based on Alpine Linux (~176MB)
- Official Node.js Docker image

**Dockerfile:**
```dockerfile
FROM node:16-alpine

WORKDIR /usr/src/app

RUN apk add --no-cache dumb-init && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup

COPY . .

RUN npm install --production && \
    npm cache clean --force && \
    chown -R appuser:appgroup /usr/src/app

USER appuser

EXPOSE 5000

ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "start"]
```

**Key Points:**
- No need to install Node.js or npm (already in image)
- Still installs minimal tools (dumb-init for signal handling)
- Uses --production for runtime-only dependencies
- Alpine base keeps image lightweight

## Backend: Go Preinstalled Image

**Base Image:** `golang:1.16-alpine`
- Contains Go 1.16 compiler
- Contains necessary build tools
- Based on Alpine Linux (~376MB)
- Official Go Docker image

**Dockerfile:**
```dockerfile
FROM golang:1.16-alpine

WORKDIR /usr/src/app

RUN apk add --no-cache git && \
    addgroup -S appgroup && \
    adduser -S appuser -G appgroup

COPY . .

RUN go build -o server && \
    chown -R appuser:appgroup /usr/src/app

USER appuser

EXPOSE 8080

CMD ["./server"]
```

**Key Points:**
- Go compiler comes with image (no installation needed)
- Minimal additional dependencies (only git if needed)
- Natural Go binary output is small
- Alpine base suitable for Go applications

## Image Size Comparison

### Frontend

| Image | Size | Notes |
|-------|------|-------|
| node:16 | 913MB | Full Debian-based |
| node:16-alpine | 176MB | Lightweight Alpine |
| **Reduction** | **81%** | Huge saving |

**Example Project Sizes:**
- node:16 + app: ~950MB
- node:16-alpine + app: ~200MB

### Backend

| Image | Size | Notes |
|-------|------|-------|
| golang:1.16 | 968MB | Full Debian-based |
| golang:1.16-alpine | 376MB | Lightweight Alpine |
| **Reduction** | **61%** | Significant saving |

**Example Project Sizes:**
- golang:1.16 + app: ~1000MB
- golang:1.16-alpine + app: ~400MB

## Version Selection

### Frontend: Node.js 16 Required

Must use older Node.js image (16 is LTS but no longer latest):

**Available Variants:**
```
node:16              # Debian-based
node:16-alpine       # Alpine-based (recommended)
node:16-slim         # Debian minimal
node:16-bullseye     # Specific Debian version
```

**Why node:16-alpine:**
- Smallest size (176MB)
- Alpine proven stable
- Best performance for containers
- Security updates included

### Backend: Go 1.16

Go versions are consistently available:

**Available Variants:**
```
golang:1.16              # Debian-based
golang:1.16-alpine       # Alpine-based (recommended)
golang:1.16-alpine3.18   # Specific Alpine version
```

**Why golang:1.16-alpine:**
- Small base image
- Suitable for compiled Go binaries
- All build tools included
- Go naturally works well with Alpine

## Finding Preinstalled Images

### Docker Hub Official Images

Official images follow naming patterns:

**Node.js**: https://hub.docker.com/_/node/
```
node:16-alpine
node:18-alpine
node:20-alpine
node:16-slim
node:16-bullseye
```

**Go**: https://hub.docker.com/_/golang/
```
golang:1.16-alpine
golang:1.20-alpine
golang:1.21-alpine
golang:1.16-alpine3.18
```

**Python**: https://hub.docker.com/_/python/
```
python:3.12-alpine
python:3.11-slim
python:3.12-bullseye
```

### Checking Image Details

```bash
# View image info
docker pull node:16-alpine
docker inspect node:16-alpine

# Check installed tools
docker run node:16-alpine npm --version
docker run node:16-alpine node --version
docker run golang:1.16-alpine go version
```

## Benefits vs Manual Installation

### Manual Installation

```dockerfile
FROM alpine:3.21
RUN apk add --no-cache python3 pip
RUN pip install requests
```

**Issues:**
- Extra steps needed
- More complex Dockerfile
- Potential version mismatches
- Less optimized

### Preinstalled Image

```dockerfile
FROM python:3.12-alpine
RUN pip install requests
```

**Benefits:**
- One step (image already has Python)
- Simpler Dockerfile
- Consistent versions
- Officially optimized

## Production Readiness

Preinstalled images are production-ready:

✅ **Security Updates**: Regular base image updates  
✅ **Performance**: Optimized for production use  
✅ **Compatibility**: Tested with language ecosystem  
✅ **Support**: Official Docker image maintenance  
✅ **Documentation**: Clear version guarantees  

## Testing Applications

After switching to preinstalled images:

```bash
# Build images
docker build -f Dockerfile.frontend -t frontend-new .
docker build -f Dockerfile.backend -t backend-new .

# Test frontend
docker run -p 5000:5000 frontend-new
# Browser: http://localhost:5000

# Test backend
docker run -p 8080:8080 backend-new
# API: http://localhost:8080
```

**Verify they work identically to previous versions.**

## Image History Analysis

```bash
# View layers
docker image history frontend-new
docker image history backend-new

# Compare sizes
docker images | grep -E "frontend|backend"
```

Expected output:
```
REPOSITORY   TAG      SIZE
frontend     new      200MB
backend      new      400MB
```

## Key Learnings

1. **Preinstalled Environments**: Use official images for major tools
2. **Version Selection**: Choose appropriate language version and base
3. **Alpine Variants**: Generally recommended for container use
4. **Size Impact**: Base image choice is most significant optimization
5. **Simplicity**: Less to install = simpler, smaller Dockerfile

## Related Exercises

- **3.5**: Security hardening (non-root users)
- **3.6**: Image optimization (layer reduction)
- **3.7**: Preinstalled environments (better base images)

All three work together for optimal, secure, minimal images.

## Summary

Preinstalled environment images like `node:16-alpine` and `golang:1.16-alpine` provide:
- Pre-configured development environments
- Optimized base images (Alpine)
- Official support and updates
- Significantly smaller image sizes (60-80% reduction)
- Simpler, more maintainable Dockerfiles

This is a best practice for modern container development.
