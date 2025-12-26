# Exercise 3.6 Setup Guide - Image Optimization

## Prerequisites

- Docker installed and running
- Basic understanding of Docker image layers
- Familiarity with Alpine Linux

## Understanding Image Size

### Why Image Size Matters

1. **Registry Bandwidth**: Large images slow down deployments
2. **Security**: Smaller images = smaller attack surface
3. **Storage**: Less disk space on registries and hosts
4. **Speed**: Faster container startup and pulling

### Layer Concept

Each Dockerfile instruction creates a layer:
```dockerfile
FROM node:16      # Layer 1: base image (913MB)
RUN npm install   # Layer 2: dependencies (~400MB)
RUN npm build     # Layer 3: build output (~150MB)
RUN serve -g      # Layer 4: serve install (~50MB)
```

Final image size = all layers combined (not deduplicated)

## Setup Steps

### Step 1: Prepare Source Files

You'll need the application source code:

**Frontend (Node.js):**
```bash
# Copy from original exercise (1.12)
cp -r ../1.12-hello-frontend ./frontend-src/
# Make sure package.json exists
```

**Backend (Go):**
```bash
# Copy from original exercise (1.13)
cp -r ../1.13-hello-backend ./backend-src/
# Make sure main.go or equivalent exists
```

### Step 2: Document Baseline Sizes

Build the unoptimized versions first (from Exercise 3.5):

**Frontend (Exercise 3.5):**
```bash
docker build -f Dockerfile.frontend.before -t frontend:before .
docker images | grep frontend
# Note the size
```

**Backend (Exercise 3.5):**
```bash
docker build -f Dockerfile.backend.before -t backend:before .
docker images | grep backend
# Note the size
```

**Record Baseline:**
- Frontend before: ~950MB
- Backend before: ~1000MB

### Step 3: Build Optimized Images

**Frontend (Optimized):**
```bash
docker build -f Dockerfile.frontend -t frontend:optimized .
docker images | grep frontend
# Record optimized size (~200MB)
```

**Backend (Optimized):**
```bash
docker build -f Dockerfile.backend -t backend:optimized .
docker images | grep backend
# Record optimized size (~400MB)
```

### Step 4: Analyze Image History

View layer breakdown:

```bash
# Frontend layers
docker image history frontend:optimized
# Look for layer sizes and purposes

# Backend layers
docker image history backend:optimized
# Note smaller layers and fewer total
```

## Optimization Breakdown

### Alpine Selection

**Why Alpine?**

Alpine Linux is extremely minimal:
```
Alpine base:      5MB
Node.js on Alpine: 176MB

vs

Debian base:      77MB
Node.js on Debian: 913MB
```

**Trade-offs:**
- ✅ Pros: Much smaller, faster pulls, secure
- ❌ Cons: Different libc (musl vs glibc), fewer tools

### Layer Reduction

**Before (Multiple RUN):**
```dockerfile
RUN apt-get update       # Layer (1-2MB)
RUN apt-get install ...  # Layer (400MB+)
RUN npm install          # Layer (400MB)
RUN npm cache clean      # Layer (cleanup)
```
Total: 4 layers, 800MB+

**After (Combined RUN):**
```dockerfile
RUN apk add --no-cache dumb-init && \
    addgroup ... && \
    adduser ...           # Layer (10MB)

RUN npm install --production && \
    npm cache clean       # Layer (200MB)
```
Total: 2 layers, 210MB

**Benefit:** Fewer layers = smaller image (no layer duplication)

### Cache Cleanup

**APT (Debian):**
```bash
apt-get install package && \
rm -rf /var/lib/apt/lists/*
# Removes package index (~20-50MB)
```

**Alpine:**
```bash
apk add --no-cache package
# --no-cache prevents caching package list
# Saves index download and storage
```

**NPM:**
```bash
npm install && \
npm cache clean --force
# Removes npm cache (~50-100MB)
```

### Production Dependencies

**npm install --production:**
```bash
npm install --production
# Excludes devDependencies
# Typical saving: 30% of node_modules
```

Example sizes:
- `npm install`: 200MB (includes dev tools)
- `npm install --production`: 140MB (runtime only)

## Testing & Verification

### Test 1: Size Comparison

```bash
# View all images
docker images | grep -E "frontend|backend"

# Compare before and after
echo "Frontend:"
docker images | grep frontend
echo "Backend:"
docker images | grep backend
```

Expected output:
```
REPOSITORY    TAG         SIZE
frontend      before      950MB
frontend      optimized   200MB
backend       before      1000MB
backend       optimized   400MB
```

### Test 2: Image History

```bash
# Detailed layer information
docker image history frontend:optimized --no-trunc

# Output shows:
# - Each layer's contribution to image size
# - Commands used to create layer
# - Creation date
```

### Test 3: Application Functionality

**Frontend:**
```bash
docker run -p 5000:5000 frontend:optimized
# Browser: http://localhost:5000
# Should display application normally
```

**Backend:**
```bash
docker run -p 8080:8080 backend:optimized
# Test API endpoints
# Should work identically to before
```

### Test 4: Signal Handling (Frontend)

dumb-init ensures proper shutdown:

```bash
# Start container
docker run -p 5000:5000 frontend:optimized &
CONTAINER_ID=$!

# Send SIGTERM (graceful shutdown)
docker kill --signal TERM $CONTAINER_ID

# Should stop gracefully, not abruptly
```

## Size Analysis Tools

### docker image history

Detailed layer breakdown:
```bash
docker image history frontend:optimized --human --no-trunc
```

Shows:
- Created date
- Command that created layer
- Size contribution
- Total image size

### docker image inspect

Metadata and detailed info:
```bash
docker image inspect frontend:optimized | jq '.[]'
```

Shows layer IDs, Dockerfile commands, etc.

### Dive Tool (Advanced)

Interactive image explorer:
```bash
# Install (if available in your system)
dive frontend:optimized

# Shows:
# - Layer breakdown
# - File system analysis
# - Wasted space identification
```

## Troubleshooting

### Issue: Alpine Image Doesn't Work

```
Error: /app: sh: command not found
```

**Cause:** Required tool not in Alpine

**Solution:**
- Alpine comes with minimal tools
- May need to add: `apk add --no-cache bash`
- Or refactor to not require the tool

### Issue: npm install Fails

```
Error: node-gyp ERR!
```

**Cause:** Native module requires compilation

**Solution:**
- Alpine uses musl libc, some modules don't compile
- Either use non-Alpine base
- Or install build tools: `apk add --no-cache python3 make g++`

### Issue: Size Not Reduced

```
docker images shows same size
```

**Cause:** Layers still too large (cache not cleaned properly)

**Solution:**
```bash
# Check layer sizes
docker image history image:tag

# Verify --no-cache and cache clean are present
docker build --no-cache -f Dockerfile .
```

## Optimization Checklist

- [ ] Changed base image to Alpine
- [ ] Combined RUN commands with &&
- [ ] Added `--no-cache` flags where applicable
- [ ] Added `cache clean` for package managers
- [ ] Used production-only dependencies
- [ ] Removed unnecessary layers
- [ ] Tested application functionality
- [ ] Verified image sizes reduced by 60%+
- [ ] Documented before/after sizes
- [ ] Verified docker image history shows improvements

## Documentation Template

Use this format for your ANSWER section:

```
## Image Size Comparison

### Frontend
Before:  950MB (9 layers)
After:   200MB (6 layers)
Reduction: 79% smaller

### Backend
Before:  1000MB (8 layers)
After:   400MB (6 layers)
Reduction: 60% smaller

## Optimizations Applied

1. Alpine base image (81% base reduction)
2. Combined RUN commands (3 layers removed)
3. Cache cleanup (50MB saved)
4. Production dependencies (30% smaller)
```

## Key Metrics to Report

1. **Total Image Size**
   - Before: [SIZE]
   - After: [SIZE]
   - Reduction: [PERCENTAGE]

2. **Layer Count**
   - Before: [COUNT]
   - After: [COUNT]
   - Reduction: [COUNT]

3. **Build Time** (bonus)
   - Before: [TIME]
   - After: [TIME]

4. **Base Image Contribution**
   - Before: [SIZE]
   - After: [SIZE]

## Advanced Optimization (Not Required)

### Multi-Stage Builds

Further size reduction for frontend:

```dockerfile
# Build stage
FROM node:16-alpine AS builder
WORKDIR /app
COPY . .
RUN npm install && npm run build

# Runtime stage
FROM node:16-alpine
WORKDIR /app
COPY --from=builder /app/build /app/build
USER appuser
EXPOSE 5000
CMD ["npm", "start"]
```

This removes all build tools from final image, reducing size further.

## Quick Commands Reference

```bash
# Build
docker build -f Dockerfile.frontend -t frontend .
docker build -f Dockerfile.backend -t backend .

# View sizes
docker images | grep -E "frontend|backend"

# View layers
docker image history frontend
docker image history backend

# Compare specific images
docker image history frontend:optimized --human
docker image history frontend:before --human
```

## Performance Impact Summary

| Metric | Frontend | Backend |
|--------|----------|---------|
| Base Image Reduction | 81% | 61% |
| Total Size Reduction | 79% | 60% |
| Layer Reduction | 33% | 25% |
| Pull Time Saved | ~10min | ~12min |

## Success Criteria

✅ Frontend image: ~200MB (was ~950MB)  
✅ Backend image: ~400MB (was ~1000MB)  
✅ Both applications function identically  
✅ Documented size reductions  
✅ Explained optimization techniques  
