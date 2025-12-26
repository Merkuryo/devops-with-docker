# Exercise 3.5 Setup Guide

## Prerequisites

- Docker installed and running
- Basic understanding of Dockerfile directives
- Familiarity with user management concepts

## Understanding the Problem

### Original Issue (Root Execution)

In exercises 1.12 and 1.13, containers run as root by default:

```bash
docker run frontend-app
# Process running as root (UID 0)
# Security risk: full system access if container escapes
```

### Solution: Non-Root User

By running as non-root, we limit damage from:
- Buffer overflow vulnerabilities
- Container escape exploits
- Malicious code execution
- Kernel vulnerabilities

## Setup Steps

### Step 1: Create Directory Structure

```bash
mkdir -p 3.5-optimized-project
cd 3.5-optimized-project
```

### Step 2: Copy Source Files

You'll need the source code from exercises 1.12 and 1.13:

**Frontend (Node.js):**
```bash
# Copy from 1.12 exercise directory
cp -r ../1.12-hello-frontend/* ./frontend-src/
```

**Backend (Go):**
```bash
# Copy from 1.13 exercise directory
cp -r ../1.13-hello-backend/* ./backend-src/
```

### Step 3: Build Images

**Frontend:**
```bash
docker build -f Dockerfile.frontend -t frontend-secure .
```

**Backend:**
```bash
docker build -f Dockerfile.backend -t backend-secure .
```

## Testing

### Test 1: Verify User Execution

```bash
# Frontend
docker run frontend-secure whoami
# Expected output: appuser

# Backend
docker run backend-secure whoami
# Expected output: appuser
```

### Test 2: Check User ID

```bash
docker run frontend-secure id
# Expected output: uid=1000(appuser) gid=1000(appuser) groups=1000(appuser)

docker run backend-secure id
# Expected output: uid=1000(appuser) gid=1001(appgroup) groups=1001(appgroup)
```

### Test 3: Verify Directory Permissions

```bash
# Check working directory ownership
docker run frontend-secure ls -ld /usr/src/app
# Expected: drwxr-xr-x appuser appuser

docker run backend-secure ls -ld /usr/src/app
# Expected: drwxr-xr-x appuser appgroup
```

### Test 4: Port Binding Test

```bash
# Frontend (uses port 5000, unprivileged)
docker run -p 5000:5000 frontend-secure
# Should work fine

# If backend uses port 80 (privileged)
docker run -p 80:80 backend-secure
# May fail because non-root can't bind port < 1024
# Solution: Use port 8080 or higher
```

## Dockerfile Differences Explained

### Linux Distribution Differences

**Node.js image (Debian-based):**
```bash
useradd -m appuser    # Standard Linux command
```

Available in: Debian, Ubuntu, CentOS, RHEL, etc.

**Go image (Alpine-based):**
```bash
addgroup -S appgroup
adduser -S appuser -G appgroup
```

Available in: Alpine, BusyBox

### Why Alpine Uses Different Commands

Alpine Linux is minimal and uses BusyBox utilities instead of GNU coreutils:
- No `useradd` command
- Uses `adduser` and `addgroup` instead
- Different flag meanings
- Smaller image size

### Command Breakdown

**Debian approach:**
```dockerfile
RUN useradd -m appuser
# -m: Create home directory (/home/appuser)
# Creates standard system user
```

**Alpine approach:**
```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
# -S: Create system user (UID < 1000)
# -G: Set primary group
# Creates minimal system user suitable for containers
```

## Ownership Changes

### Why We Need chown

Without ownership change:
```dockerfile
FROM node:16
WORKDIR /usr/src/app    # Created by root
RUN useradd -m appuser  # Creates appuser
USER appuser            # Switch to appuser
# ERROR: Can't write to /usr/src/app (owned by root)
```

With ownership change:
```dockerfile
FROM node:16
WORKDIR /usr/src/app
RUN useradd -m appuser
RUN chown -R appuser:appuser /usr/src/app  # Transfer ownership
USER appuser            # Now can write
# ✅ Works correctly
```

### chown Syntax

```bash
chown user:group /path
# user = username (appuser)
# group = groupname (appuser or appgroup)
# /path = target directory
```

**-R flag (recursive):**
```bash
chown -R appuser:appuser /usr/src/app
# Changes ownership of:
#  - /usr/src/app directory itself
#  - All files inside /usr/src/app
#  - All subdirectories and their contents
```

## Directive Ordering

### Critical: USER Must Be Last

```dockerfile
# ❌ Wrong order
FROM alpine:latest
RUN useradd appuser
RUN chown appuser /app     # Fails: USER is already appuser!
RUN mkdir -p /app
USER appuser

# ✅ Correct order
FROM alpine:latest
RUN useradd appuser
RUN mkdir -p /app
RUN chown -R appuser /app  # Still running as root
USER appuser               # NOW switch to non-root
```

**Why it matters:**
- Commands before `USER` run as root
- Commands after `USER` run as specified user
- Non-root can't change file ownership
- Non-root can't create other users

## Common Issues & Solutions

### Issue: Permission Denied

```
Error: [Errno 13] Permission denied: '/usr/src/app/file.txt'
```

**Cause:** Directory owned by root, appuser can't write

**Solution:**
```dockerfile
RUN chown -R appuser:appuser /usr/src/app
```

### Issue: User Not Found

```
Error: adduser: user appuser in use
```

**Cause:** User already exists or wrong base image

**Solution:**
```dockerfile
# Check if user exists first
RUN id appuser || useradd -m appuser

# Or use different username
RUN useradd -m myapp
```

### Issue: Port Binding Fails

```
Error: bind: permission denied
```

**Cause:** Non-root users can't bind ports < 1024

**Solution:**
- Use port ≥ 1024 in application
- Or expose via docker run: `-p 80:8080`
- Or use CAP_NET_BIND_SERVICE

### Issue: Alpine Image Doesn't Have useradd

```
Error: /bin/sh: useradd: not found
```

**Cause:** Using wrong commands for Alpine

**Solution:** Use Alpine commands
```dockerfile
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
```

## Verification Checklist

- [ ] Frontend image builds without errors
- [ ] Backend image builds without errors
- [ ] `docker run frontend-secure whoami` returns `appuser`
- [ ] `docker run backend-secure whoami` returns `appuser`
- [ ] Images start processes as non-root
- [ ] Applications function normally
- [ ] Directory permissions correct (ls -ld shows appuser)

## Security Validation

```bash
# Run as root would be:
docker run --user 0 frontend-secure whoami
# Output: root
# This proves USER directive works

# Normal execution:
docker run frontend-secure whoami
# Output: appuser
# This proves security is in effect
```

## Next Steps

1. Build both Dockerfiles
2. Test with whoami and id commands
3. Verify applications still work
4. Commit to repository
5. Understand how this protects against container escape

## Quick Reference

### Build
```bash
docker build -f Dockerfile.frontend -t frontend-secure .
docker build -f Dockerfile.backend -t backend-secure .
```

### Test User
```bash
docker run frontend-secure whoami
docker run backend-secure whoami
```

### View Dockerfile (What Changed)
```bash
# Added to both:
# 1. User creation (different commands for Alpine vs Debian)
# 2. Ownership change: chown -R appuser ...
# 3. USER directive to switch execution context
```

### Key Differences

| Aspect | Frontend (Node) | Backend (Go/Alpine) |
|--------|-----------------|-------------------|
| Base Image | Debian-based | Alpine-based |
| User Creation | `useradd -m` | `adduser -S` |
| Group Creation | Implicit | Explicit `addgroup` |
| User Command | `useradd` | `adduser` |
| Full Command | `useradd -m appuser` | `addgroup -S appgroup && adduser -S appuser -G appgroup` |

## Support & Learning Resources

- Docker docs on USER: https://docs.docker.com/engine/reference/builder/#user
- Alpine Linux package docs: https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management
- Security best practices: https://docs.docker.com/develop/dev-best-practices/
