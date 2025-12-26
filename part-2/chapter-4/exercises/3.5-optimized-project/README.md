# Exercise 3.5: Optimized Project - Security Hardening

## Overview

Secure the frontend and backend applications from exercises 1.12 and 1.13 by implementing non-root user execution. This mitigates security risks from potential container escapes or vulnerabilities.

## Security Motivation

When containers run as root:
- Any vulnerability can compromise the entire host
- Escaped processes have full system access
- Security best practice: principle of least privilege

By running as non-root:
- Damage from escaped container is limited
- Process has only necessary permissions
- Aligns with container security standards

## Frontend Optimization (Node.js)

**Changes from Exercise 1.12:**

```dockerfile
# Create non-root user
RUN useradd -m appuser

# Change ownership of working directory
RUN chown -R appuser:appuser /usr/src/app

# Switch to non-root user
USER appuser
```

**Key Points:**
- `useradd -m appuser`: Creates user with home directory
- `chown -R appuser:appuser`: Changes directory ownership (must be root)
- `USER appuser`: All subsequent commands run as appuser

## Backend Optimization (Alpine/Go)

**Changes from Exercise 1.13:**

```dockerfile
# Alpine Linux doesn't have useradd, uses addgroup/adduser
RUN addgroup -S appgroup && adduser -S appuser -G appgroup

# Change ownership of working directory
RUN chown -R appuser:appgroup /usr/src/app

# Switch to non-root user
USER appuser
```

**Key Differences:**
- Alpine uses `addgroup` and `adduser` instead of `useradd`
- `-S` flag creates system user (minimal privileges)
- Group management explicit with `addgroup`
- `chown` syntax: `appuser:appgroup` (user:group)

## Command Explanation

| Command | Purpose |
|---------|---------|
| `useradd -m appuser` | Create system user with home directory |
| `addgroup -S appgroup` | Alpine: create system group |
| `adduser -S appuser -G appgroup` | Alpine: create system user in group |
| `chown -R appuser:appuser /path` | Change ownership (recursive) |
| `USER appuser` | Switch execution user |

## Security Benefits

✅ **Least Privilege**: Process runs with minimal necessary permissions  
✅ **Container Escape Mitigation**: Escaped process can't access host as root  
✅ **File Permissions**: Directory ownership prevents unauthorized access  
✅ **Compliance**: Meets security standards and best practices  

## Important Notes

**Order Matters:**
- User creation and permission changes must happen as root
- `USER` directive must come AFTER `chown` command
- All commands after `USER` run as non-root user

**Directory Permissions:**
- If not using bind mounts, must set ownership of working directory
- Without `chown`, appuser won't have write permissions
- Permission denied errors indicate ownership issues

## Testing

```bash
# Build frontend
docker build -f Dockerfile.frontend -t frontend-secure .

# Build backend
docker build -f Dockerfile.backend -t backend-secure .

# Run containers (they should start as non-root)
docker run frontend-secure
docker run backend-secure

# Verify user in running container
docker run frontend-secure whoami
# Output: appuser
```

## Comparison: Before and After

**Before (Security Risk):**
```dockerfile
CMD ["serve", "-s", "-l", "5000", "build"]
# Runs as root - full system access if escaped
```

**After (Secure):**
```dockerfile
USER appuser
CMD ["serve", "-s", "-l", "5000", "build"]
# Runs as appuser - limited privileges if escaped
```

## Alpine vs Debian/Ubuntu

**Debian/Ubuntu (Node image):**
```bash
useradd -m appuser        # Standard Linux command
```

**Alpine Linux (Go image):**
```bash
addgroup -S appgroup      # Alpine specific
adduser -S appuser -G appgroup
```

Alpine is lighter but uses different user management tools. Always check base image documentation for user creation syntax.

## Real-World Application

This pattern is used by:
- Web service containers
- API servers
- Worker processes
- Any long-running service exposed to network

Default practice: **Always run as non-root unless root is required.**

## Related Exercises

- **1.12**: Frontend containerization (original)
- **1.13**: Backend containerization (original)
- **3.4**: Docker-in-Docker (related security concepts)

## Key Learnings

1. Container security through user separation
2. Dockerfile directive ordering
3. Alpine Linux specific commands
4. File ownership and permissions in Docker
5. Principle of least privilege
