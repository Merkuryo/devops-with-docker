# Exercise 3.9: Multi-Stage Backend with FROM Scratch

## Overview

This exercise demonstrates the ultimate optimization technique for Go applications: using multi-stage builds with `FROM scratch`. The `scratch` image is the smallest possible base image—completely empty—and we only include the compiled Go binary.

## The Challenge

Building a Go binary that works in a `FROM scratch` image requires understanding:
1. **Static Compilation**: The binary must be self-contained with no external dependencies
2. **Symbol Stripping**: Remove debug symbols to minimize binary size
3. **CGO Disabled**: Prevent C library dependencies
4. **No Runtime Dependencies**: No libc, no shell, nothing but the binary

## Solution: Multi-Stage Dockerfile with FROM Scratch

```dockerfile
# Stage 1: Build stage
FROM golang:1.16-alpine AS build-stage

WORKDIR /usr/src/app

COPY . .

# Static compilation flags:
# CGO_ENABLED=0: Disable cgo to avoid C library dependencies
# -a: Rebuild packages
# -ldflags="-s -w": Strip symbols (-s) and dwarf (-w) debug info
RUN CGO_ENABLED=0 go build -a -ldflags="-s -w" -o server .

# Stage 2: Production stage
FROM scratch

# Copy only the compiled binary
COPY --from=build-stage /usr/src/app/server /server

EXPOSE 8080

ENTRYPOINT ["/server"]
```

## Key Concepts

### Stage 1: Build Stage

**Base Image**: `golang:1.16-alpine` (376MB intermediate stage)

**Build Command**: 
```bash
CGO_ENABLED=0 go build -a -ldflags="-s -w" -o server .
```

**Flags Explained**:

| Flag | Purpose | Impact |
|------|---------|--------|
| `CGO_ENABLED=0` | Disable cgo (C bindings) | Static binary, no libc needed |
| `-a` | Force rebuild all packages | Ensures proper static linking |
| `-ldflags="-s -w"` | Strip symbols | Reduces binary size significantly |
| `-s` | Strip symbol table | ~30-40% size reduction |
| `-w` | Strip DWARF debug info | ~10% additional size reduction |
| `-o server` | Output filename | Creates `/usr/src/app/server` binary |

### Stage 2: Production Stage

**Base Image**: `FROM scratch` (0 bytes—literally empty)

```dockerfile
FROM scratch

COPY --from=build-stage /usr/src/app/server /server

EXPOSE 8080

ENTRYPOINT ["/server"]
```

**Why Scratch?**

`scratch` is a reserved Docker image representing an empty base:
- No operating system
- No shell
- No libc
- No package manager
- Literally nothing
- 0 bytes

This is the smallest possible base image and the most secure because there's nothing to exploit.

## Size Comparison

### Single-Stage Build (Traditional)

```dockerfile
FROM golang:1.16-alpine

WORKDIR /usr/src/app
COPY . .
RUN go build -o server .

EXPOSE 8080
CMD ["./server"]
```

**Image Size**: ~400MB
- golang:1.16-alpine: 376MB
- Source code: 20MB
- Build cache: 4MB

**Includes**:
- Go compiler
- Build tools
- Source code
- All development dependencies

**Not ideal for production** because image includes unnecessary build tools.

### Multi-Stage with Alpine (Exercise 3.7 Backend)

```dockerfile
FROM golang:1.16-alpine AS build-stage
RUN go build -o server .

FROM golang:1.16-alpine
COPY --from=build-stage /usr/src/app/server /server
```

**Image Size**: ~400MB
- golang:1.16-alpine: 376MB (still includes compiler)
- Binary: ~20MB
- Runtime dependencies: 4MB

**Better than single-stage** but still carries Alpine OS overhead.

### Multi-Stage with FROM Scratch (This Solution)

```dockerfile
FROM golang:1.16-alpine AS build-stage
RUN CGO_ENABLED=0 go build -a -ldflags="-s -w" -o server .

FROM scratch
COPY --from=build-stage /usr/src/app/server /server
```

**Image Size**: ~12-15MB
- Binary only: 10-12MB (stripped)
- No OS overhead: 0MB
- No runtime: 0MB

**Size Reduction**: 
- vs single-stage: **97% reduction** (400MB → 12MB)
- vs multi-stage Alpine: **96% reduction** (400MB → 12MB)

## Compilation Flags Deep Dive

### CGO_ENABLED=0 - Static Linking

Without this flag:
```bash
go build -o server .
# Output: dynamically linked binary
# Depends on: /lib64/ld-linux-x86-64.so.2 (libc)
# Error in scratch: "not found" (no libc available)
```

With this flag:
```bash
CGO_ENABLED=0 go build -o server .
# Output: statically linked binary
# No external dependencies
# Works in scratch ✓
```

### -a Flag - Force Rebuild

Ensures all packages are rebuilt with static linking:
```bash
go build -o server .
# May use cached dynamic builds

CGO_ENABLED=0 go build -a -o server .
# Forces rebuild, guarantees static linking
```

### -ldflags="-s -w" - Symbol Stripping

**Without stripping**:
```bash
go build -o server .
# Binary size: 20-25MB
# Includes: all symbols, debug info, function names
```

**With stripping**:
```bash
go build -ldflags="-s -w" -o server .
# Binary size: 10-12MB (50% reduction)
# Removed: symbol table (-s), DWARF debug info (-w)
```

**Impact by flag**:
- `-s`: Strips symbol table (~30-40% reduction)
- `-w`: Removes DWARF debug info (~10% additional reduction)
- Combined: ~50% binary size reduction

## Building and Testing

### Build the Image

```bash
docker build -t backend:scratch .
```

**Expected output**:
```
Step 1/6 : FROM golang:1.16-alpine AS build-stage
Step 2/6 : WORKDIR /usr/src/app
Step 3/6 : COPY . .
Step 4/6 : RUN CGO_ENABLED=0 go build -a -ldflags="-s -w" -o server .
Step 5/6 : FROM scratch
Step 6/6 : COPY --from=build-stage /usr/src/app/server /server
```

### Check Image Size

```bash
docker image ls | grep backend:scratch

# Output should show image < 35MB
# Example:
# backend       scratch  abc123def456  2 seconds ago  12.5MB
```

### Run the Container

```bash
docker run -p 8080:8080 backend:scratch
```

**Note**: With `FROM scratch`, you cannot use:
- `docker exec` (no shell)
- `docker run -it` (no interactive shell)
- Standard Linux tools

You can only interact via the network interface (port 8080).

### Verify Functionality

```bash
# In another terminal
curl http://localhost:8080

# Server should respond correctly
# No shell needed—just the binary running
```

## Advanced: Adding CA Certificates

If your Go app makes HTTPS requests, you need SSL certificates:

### Option 1: Copy from Alpine (Recommended)

```dockerfile
FROM golang:1.16-alpine AS build-stage
...

FROM scratch

COPY --from=build-stage /usr/src/app/server /server
COPY --from=build-stage /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

EXPOSE 8080
ENTRYPOINT ["/server"]
```

**Size impact**: +500KB (ca-certificates)
**Final size**: ~13MB total

### Option 2: Build certificates into binary

Some Go projects use embedding tools to include certificates. This requires additional build configuration.

## Debugging FROM Scratch Issues

### Issue: "exec /server: no such file or directory"

**Cause**: Binary compiled for wrong architecture or not found

**Solution**:
```bash
# Verify binary exists in build-stage
docker build --target build-stage -t backend:build .
docker run backend:build ls -la /usr/src/app/server

# Verify binary is executable
docker run backend:build file /usr/src/app/server
# Should show: ELF 64-bit LSB executable, x86-64, statically linked
```

### Issue: "standard_init_linux.go:211 error"

**Cause**: Trying to use shell or run with interactive flags

**Solution**: Don't use `-it` with scratch images
```bash
# Wrong (will fail)
docker run -it backend:scratch

# Correct
docker run -d backend:scratch
docker logs <container_id>
```

### Issue: "Cannot open file /etc/ssl/certs/ca-certificates.crt"

**Cause**: App makes HTTPS but certificates not copied

**Solution**: Add to Dockerfile
```dockerfile
COPY --from=build-stage /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
```

Or update code to not validate certificates (not recommended for production).

## Comparison: All Backend Approaches

| Approach | Size | Build Time | Security | Use Case |
|----------|------|-----------|----------|----------|
| Single-stage Alpine | 400MB | 30s | Medium | Development |
| Multi-stage Alpine | 400MB | 30s | Medium | Testing |
| Multi-stage Scratch | **<15MB** | 30s | **Excellent** | **Production** |

## Docker Best Practices for Go

1. **Always use CGO_ENABLED=0** for containerized Go apps
2. **Always use -a flag** with static linking
3. **Always strip symbols** for production (-ldflags="-s -w")
4. **Use FROM scratch** for final production images
5. **Consider CA certificates** if making HTTPS requests
6. **Test thoroughly** - no shell means limited debugging

## Real-World Example: Complete Dockerfile

```dockerfile
# Build stage
FROM golang:1.16-alpine AS builder

WORKDIR /usr/src/app

# Copy source
COPY go.mod go.sum ./
RUN go mod download

COPY . .

# Compile with static linking and symbol stripping
RUN CGO_ENABLED=0 go build \
    -a \
    -ldflags="-s -w" \
    -o /app/server \
    .

# Runtime stage
FROM scratch

# Copy binary
COPY --from=builder /app/server /server

# Copy CA certificates for HTTPS (if needed)
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Health check (if implemented in app)
EXPOSE 8080

# No need for CMD - binary runs directly
ENTRYPOINT ["/server"]
```

**Resulting image size**: 10-15MB (depending on binary size)

## Summary

The `FROM scratch` approach is the gold standard for containerized Go applications:

✅ **Minimal Size**: 97% reduction (400MB → 12MB)
✅ **Maximum Security**: No OS, no tools, no shell
✅ **Fast Deployment**: Very small transfers
✅ **Production Ready**: Standard approach for Go services
✅ **Immutable**: Binary and nothing else

This is why you see tiny Go Docker images (~1-20MB) in production services worldwide.

## Key Takeaway

Multi-stage builds with `FROM scratch` leverage Go's unique strength: **statically compiled binaries that need no runtime dependencies**. This makes Go ideal for containerization and why Go-based microservices are so popular.
