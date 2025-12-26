# Exercise 3.6: Optimized Project Images

## Overview

Optimize the frontend and backend Dockerfiles from Exercise 3.5 by reducing image size through:
1. Combining RUN commands to reduce layers
2. Removing unnecessary files and cache
3. Using lightweight base images (Alpine)
4. Removing build dependencies

## Optimization Techniques

### 1. Reduce Layers

**Before (Multiple RUN commands):**
```dockerfile
RUN apt-get update
RUN apt-get install -y curl python3 ffmpeg
RUN curl -L https://...
RUN chmod a+x ...
```
Each RUN creates a layer.

**After (Combined RUN commands):**
```dockerfile
RUN apt-get update && \
    apt-get install -y curl && \
    curl -L https://... && \
    chmod a+x ...
```
Single layer = smaller image.

### 2. Remove Cache and Unnecessary Files

**APT/Package Manager Cache:**
```bash
apt-get install ... && \
rm -rf /var/lib/apt/lists/*
```

**NPM Cache:**
```bash
npm install && \
npm cache clean --force
```

### 3. Use Alpine Base Images

Alpine Linux is ~5MB vs 77MB for Debian-based images.

**Debian Node:**
```dockerfile
FROM node:16  # ~913MB
```

**Alpine Node:**
```dockerfile
FROM node:16-alpine  # ~176MB
```

### 4. Remove Build Dependencies

Don't include tools only needed during build if possible.

## Frontend Optimization

**Changes from Exercise 3.5:**

1. **Base Image**: `node:16` → `node:16-alpine`
   - Size reduction: ~900MB to ~176MB base image

2. **Combined RUN Commands**:
   ```dockerfile
   RUN apk add --no-cache dumb-init && \
       addgroup -S appgroup && \
       adduser -S appuser -G appgroup
   
   RUN npm install --production && \
       npm cache clean --force && \
       chown -R appuser:appgroup /usr/src/app
   ```

3. **Removed npm build**:
   - Using `--production` flag for install only
   - Assumes pre-built files in source

4. **Added dumb-init**:
   - Proper signal handling for Node processes
   - Lightweight init system for containers

### Expected Size Reduction

- **Original (Exercise 3.5)**: ~913MB
- **Optimized**: ~180-200MB (80% reduction)

## Backend Optimization

**Changes from Exercise 3.5:**

1. **Base Image**: `golang:1.16` → `golang:1.16-alpine`
   - Size reduction: ~968MB to ~376MB base image

2. **Combined RUN Commands**:
   ```dockerfile
   RUN apk add --no-cache git && \
       addgroup -S appgroup && \
       adduser -S appuser -G appgroup
   
   RUN go build -o server && \
       chown -R appuser:appgroup /usr/src/app
   ```

3. **Removed Unnecessary Steps**:
   - Minimal dependencies
   - Go naturally produces small binaries

### Expected Size Reduction

- **Original (Exercise 3.5)**: ~968MB
- **Optimized**: ~380-400MB (60% reduction)

## Alpine Linux Commands

Alpine uses BusyBox instead of GNU tools:

| Task | Command |
|------|---------|
| Install packages | `apk add --no-cache` |
| Update packages | `apk update` |
| Remove cache | (no separate cache directory like apt) |
| Create user/group | `addgroup`, `adduser` |

`--no-cache` prevents downloading package index (saves space).

## Image History Commands

To see image layers and sizes:

```bash
# Build images first
docker build -f Dockerfile.frontend -t frontend-optimized .
docker build -f Dockerfile.backend -t backend-optimized .

# View layer breakdown
docker image history frontend-optimized
docker image history backend-optimized

# Get total size
docker images | grep optimized
```

## Optimization Comparison

### Frontend

| Metric | Unoptimized | Optimized | Reduction |
|--------|------------|-----------|-----------|
| Base Image | 913MB | 176MB | 81% |
| Total Size | ~950MB | ~200MB | 79% |
| Layers | 8+ | 6 | 25% |

### Backend

| Metric | Unoptimized | Optimized | Reduction |
|--------|------------|-----------|-----------|
| Base Image | 968MB | 376MB | 61% |
| Total Size | ~1000MB | ~400MB | 60% |
| Layers | 8+ | 6 | 25% |

## Key Improvements

✅ **Layer Reduction**: Combined RUN commands  
✅ **Alpine Base**: Lightweight alternative to Debian  
✅ **Cache Cleanup**: Removed npm cache  
✅ **Minimal Dependencies**: Only necessary packages  
✅ **Security**: Smaller attack surface  
✅ **Performance**: Faster image pulls  

## Important Considerations

### Alpine Compatibility

Alpine works for most Node.js and Go applications, but:
- Some native modules may not compile
- Different libc (musl vs glibc)
- Test thoroughly before production

### dumb-init for Node

Ensures proper signal handling (SIGTERM, SIGKILL):
```dockerfile
ENTRYPOINT ["dumb-init", "--"]
CMD ["npm", "start"]
```

Without it, Node may not handle shutdown signals properly.

### Production Readiness

For production, consider:
- Multi-stage builds (even smaller images)
- Health checks
- Resource limits
- Logging configuration

## Size Verification

```bash
# After building, check actual sizes
docker images | grep frontend-optimized
docker images | grep backend-optimized

# View history
docker image history frontend-optimized --no-trunc
docker image history backend-optimized --no-trunc
```

## Multi-Stage Builds (Advanced)

For even smaller images, use multi-stage builds:

```dockerfile
# Build stage
FROM node:16-alpine AS builder
WORKDIR /app
COPY . .
RUN npm install

# Runtime stage
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/package*.json ./
USER appuser
CMD ["npm", "start"]
```

This is not included in this exercise but is a powerful optimization technique.

## Related Exercises

- **3.5**: Security hardening (non-root users)
- **1.12**: Original frontend (unoptimized)
- **1.13**: Original backend (unoptimized)

## Key Learning Outcomes

1. Layer reduction through RUN command combining
2. Alpine Linux benefits and usage
3. Cache management in Docker builds
4. Image size analysis with `docker history`
5. Trade-offs between optimization and compatibility
