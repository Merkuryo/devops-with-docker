# Exercise 3.8: Multi-Stage Frontend

## Overview

This exercise demonstrates multi-stage Docker builds for the React frontend application. The multi-stage approach separates the build environment from the runtime environment, significantly reducing the final image size.

## Multi-Stage Build Concept

### Why Multi-Stage Builds?

In traditional single-stage builds, the final image includes:
- Build tools (Node.js, npm, webpack, etc.)
- Source code
- Dependencies (node_modules)
- Built assets

Multi-stage builds allow us to:
1. Build the application in one stage with all necessary tools
2. Copy only the built assets to a minimal runtime image
3. Discard build tools and source code from the final image

### Benefits

- **Smaller Image Size**: 60-80% reduction typical
- **Better Security**: No build tools in production image
- **Faster Deployment**: Less data to transfer/store
- **Cleaner Images**: Only essential files included

## Solution: Multi-Stage Dockerfile

### Stage 1: Build Stage

```dockerfile
FROM node:16-alpine AS build-stage

WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install

COPY . .
RUN npm run build
```

**Purpose**: Compile React application to static files in `build/` directory

**What's Included**:
- Node.js v16 runtime
- npm package manager
- node_modules (all dependencies)
- Source code (.js, .jsx, .css, etc.)
- Webpack and build tools
- Build output in /usr/src/app/build

**Size**: ~200MB (intermediate stage, not in final image)

### Stage 2: Production Stage

```dockerfile
FROM nginx:1.21-alpine

COPY --from=build-stage /usr/src/app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

**Purpose**: Serve static files with Nginx

**What's Included**:
- Nginx web server (minimal)
- Only compiled assets from `build/` folder
- No Node.js, no npm, no source code

**Size**: ~35MB (final image used in production)

## Key Implementation Details

### Stage Naming

```dockerfile
FROM node:16-alpine AS build-stage
```

The `AS build-stage` names the stage so it can be referenced in `COPY --from=`

### Copying Built Assets

```dockerfile
COPY --from=build-stage /usr/src/app/build /usr/share/nginx/html
```

- Source: `/usr/src/app/build` (from build-stage)
- Destination: `/usr/share/nginx/html` (Nginx document root)

### Nginx Configuration

Default nginx configuration serves files from `/usr/share/nginx/html` on port 80.

For custom routing (e.g., React Router SPA), create `nginx.conf`:

```nginx
server {
    listen 80;
    location / {
        root /usr/share/nginx/html;
        try_files $uri /index.html;
    }
}
```

Then add to Dockerfile:
```dockerfile
COPY nginx.conf /etc/nginx/nginx.conf
```

## Size Comparison

### Traditional Single-Stage Build

```dockerfile
FROM node:16-alpine

WORKDIR /usr/src/app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

EXPOSE 3000
CMD ["npm", "start"]
```

**Image Size**: ~250MB
- node:16-alpine: 176MB
- node_modules: 50MB
- Source code: 10MB
- Build output: 14MB

**Contains**:
- Build tools
- Source code
- Dependencies
- All unnecessary for serving static files

### Multi-Stage Build

```dockerfile
FROM node:16-alpine AS build-stage
...
FROM nginx:1.21-alpine
COPY --from=build-stage /usr/src/app/build ...
```

**Image Size**: ~35MB
- nginx:1.21-alpine: 23MB
- Built assets only: 12MB

**Savings**: **86% reduction** (250MB → 35MB)

**Contains**:
- Only compiled assets
- Nginx web server
- No build tools, no source code

## Real-World Size Example

### Example Frontend Project Sizes

| Component | Single-Stage | Multi-Stage | Notes |
|-----------|-------------|------------|-------|
| Base image | 176MB | 23MB | node vs nginx |
| node_modules | 50MB | — | Removed in multi-stage |
| Source code | 10MB | — | Removed in multi-stage |
| Build output | 14MB | 12MB | Compressed in multi-stage |
| **Total** | **250MB** | **35MB** | **86% reduction** |

## Building and Testing

### Build the Image

```bash
docker build -t frontend:multi-stage .
```

**Expected Output**:
```
Step 1/13 : FROM node:16-alpine AS build-stage
Step 2/13 : WORKDIR /usr/src/app
...
Step 7/13 : RUN npm run build
...
Step 8/13 : FROM nginx:1.21-alpine
Step 9/13 : COPY --from=build-stage /usr/src/app/build /usr/share/nginx/html
...
Successfully tagged frontend:multi-stage
```

### Run the Container

```bash
docker run -p 8080:80 frontend:multi-stage
```

Then visit: http://localhost:8080

### Verify Image Size

```bash
docker image ls | grep frontend
# Shows the final image size (~35MB)
```

### Inspect Build Layers

```bash
docker image history frontend:multi-stage --human

# Shows all stages:
# nginx:1.21-alpine base
# COPY --from=build-stage (12MB assets)
```

## Nginx Server Configuration

### Default Behavior

Serves files from `/usr/share/nginx/html` on port 80:
```
http://localhost:8080/         → index.html
http://localhost:8080/page     → page.html or 404
```

### For Single Page Applications (React Router)

If your React app uses client-side routing, create `nginx.conf`:

```nginx
server {
    listen 80;
    
    location / {
        root /usr/share/nginx/html;
        try_files $uri /index.html;
    }
}
```

Then in Dockerfile:
```dockerfile
FROM nginx:1.21-alpine

COPY nginx.conf /etc/nginx/nginx.conf
COPY --from=build-stage /usr/src/app/build /usr/share/nginx/html

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

This ensures all routes load `index.html` so React Router can handle them.

## Advanced Multi-Stage Patterns

### Using External Images as Build Stages

```dockerfile
FROM node:16-alpine AS build-stage
# Build your app
RUN npm run build

FROM python:3.9 AS docs
# Generate documentation from source
RUN sphinx-build ...

FROM nginx:1.21-alpine
COPY --from=build-stage /app/build /usr/share/nginx/html
COPY --from=docs /docs /usr/share/nginx/html/docs
```

### Conditional Build Stages

Build different outputs for different environments:

```dockerfile
FROM node:16-alpine AS build-prod
RUN npm run build:prod

FROM node:16-alpine AS build-dev
RUN npm run build:dev

FROM nginx:1.21-alpine
# Choose which stage to copy from based on build argument
COPY --from=build-prod /app/build /usr/share/nginx/html
```

## Comparison with Other Approaches

### Build Locally, Copy Assets

```dockerfile
FROM nginx:1.21-alpine
COPY build/ /usr/share/nginx/html/
```

- Pros: Very simple, smallest image
- Cons: Manual build step outside Docker, not repeatable in CI/CD

### Multi-Stage Build

```dockerfile
FROM node:16-alpine AS build-stage
RUN npm run build

FROM nginx:1.21-alpine
COPY --from=build-stage /app/build /usr/share/nginx/html
```

- Pros: Complete Docker build process, reproducible, no external build step
- Cons: Slightly larger image than pre-built copy

### Single-Stage with Node Dev Server

```dockerfile
FROM node:16-alpine
RUN npm install
COPY . .
CMD ["npm", "start"]
```

- Pros: Useful for development, live reload
- Cons: Large image, not suitable for production

## Production Checklist

- ✓ Multi-stage build with Node.js build stage
- ✓ Nginx Alpine for minimal production image
- ✓ Static files copied from build-stage
- ✓ Port 80 exposed
- ✓ Proper nginx configuration for SPA (if needed)
- ✓ No source code in final image
- ✓ No build tools in final image
- ✓ Image size ~35MB or less

## Troubleshooting

### Issue: "Cannot find module" during build

**Cause**: npm install didn't run
**Solution**: Ensure COPY package*.json and RUN npm install are before COPY . .

### Issue: Static files not serving

**Cause**: Incorrect path or nginx misconfiguration
**Solution**: Verify build/ folder exists and path matches /usr/share/nginx/html

### Issue: React Router routes return 404

**Cause**: Nginx doesn't know to serve index.html for client-side routes
**Solution**: Add nginx.conf with try_files directive

## Summary

Multi-stage builds for frontend applications achieve:
- **86% size reduction** (250MB → 35MB)
- **Better security** (no build tools in production)
- **Faster deployment** (smaller images transfer quicker)
- **Cleaner separation** of build and runtime environments

This is a recommended production pattern for containerized frontend applications.
