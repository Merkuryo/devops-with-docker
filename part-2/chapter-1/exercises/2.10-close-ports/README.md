# Exercise 2.10 - Close the Ports

## Objective

Remove unnecessary port mappings to ensure all external access goes through the reverse proxy on port 80.

## What Changed from 2.9

Exercise 2.9 had:
- Proxy listening on port 80 ✓
- Frontend exposing port 5000 ✗ (unnecessary)
- Backend exposing port 8080 ✗ (unnecessary)

Exercise 2.10 has:
- Proxy listening on port 80 ✓
- Frontend NOT exposing any port ✓
- Backend NOT exposing any port ✓
- Redis internal only ✓
- PostgreSQL internal only ✓

## Port Mapping Concept

### Before Understanding
Many services exposed their ports:
```yaml
frontend:
  ports:
    - 5000:5000  # Direct access possible
    
backend:
  ports:
    - 8080:8080  # Direct access possible
```

### After Understanding
Only the reverse proxy exposes a port:
```yaml
proxy:
  ports:
    - 80:80  # Single entry point
    
# No ports exposed for other services
```

## Docker Networking Basics

**Internal vs External Access:**

1. **Internal Communication (Docker Network)**
   - Services can reach each other using service names
   - `http://frontend:5000` works from other containers
   - No port mapping needed
   - Only needed for container-to-container communication

2. **External Access (Host Network)**
   - Requires port mapping with `ports:`
   - Makes ports accessible on localhost
   - Enables access from host machine or outside
   - Should only be done for entry points

## Why This Matters

### Security
- Reduces attack surface
- Prevents unauthorized direct backend access
- Forces all traffic through reverse proxy

### Architecture
- Single point of entry (Nginx on port 80)
- All routing decisions made at proxy
- Clean separation of concerns

### Scaling
- Easy to change internal ports without affecting users
- Reverse proxy handles routing consistently

## Port Exposure Changes

| Service | Old Ports | New Ports | Reason |
|---------|-----------|-----------|--------|
| Proxy (Nginx) | 80:80 | 80:80 | Entry point - must expose |
| Frontend | 5000:5000 | None | Only accessible internally |
| Backend | 8080:8080 | None | Only accessible internally |
| Redis | None | None | Internal service |
| PostgreSQL | None | None | Internal service |

## Internal Communication

Even without exposing ports, containers communicate fine:

```
Frontend container → http://backend:8080/ (works!)
Nginx container → http://frontend:5000/ (works!)
Backend container → http://redis:6379 (works!)
Backend container → postgresql://db:5432 (works!)
```

Why? Because they're all in the same Docker network.

## External Communication

All external access now goes through port 80:

```
Browser on host → http://localhost:80 (Nginx)
                     ↓
                Nginx routes based on path
                     ↓
              /      →  http://frontend:5000/
            /api/    →  http://backend:8080/
```

## Verification

### Port Scanning
Using nmap to confirm only port 80 is open:

```bash
docker run -it --rm --network host networkstatic/nmap localhost
```

Expected output shows only port 80:
```
PORT     STATE    SERVICE
80/tcp   filtered http
111/tcp  open     rpcbind
```

(111 is a system service, not our application)

### Functional Testing
```bash
# Access frontend
curl http://localhost/

# Access API
curl http://localhost/api/ping
# Output: pong

# Create message
curl -X POST http://localhost/api/messages \
  -H "Content-Type: application/json" \
  -d '{"body":"test"}'

# Get messages
curl http://localhost/api/messages
```

All work through the single port 80.

## Key Learning

**Port Publishing vs Network Communication**

- Publishing a port (docker run -p or ports: in compose) makes it accessible on the HOST
- Network communication (service names in Docker) only needs the container port and network
- Only publish ports that need external access

## Before and After

### Before (2.9)
```
Host: localhost:80 (Nginx)
Host: localhost:5000 (Frontend - direct access possible!)
Host: localhost:8080 (Backend - direct access possible!)
```

### After (2.10)
```
Host: localhost:80 (Nginx - only entry point)
Internal: frontend:5000 (only through Nginx)
Internal: backend:8080 (only through Nginx)
```

## Docker Network Architecture

All services in the same network:
```
┌─────────────────────────────────────────────┐
│         Docker Network (compose_default)    │
│                                             │
│  ┌──────────────┐  ┌──────────────┐       │
│  │   Nginx      │  │  Frontend    │       │
│  │  :80↑        │  │  :5000       │       │
│  │  (exposed)   │  │  (internal)  │       │
│  └──────────────┘  └──────────────┘       │
│         │                   ↑              │
│         └───────────────────┘              │
│                                             │
│  ┌──────────────┐  ┌──────────────┐       │
│  │   Backend    │  │   Redis      │       │
│  │  :8080       │  │  :6379       │       │
│  │  (internal)  │  │  (internal)  │       │
│  └──────────────┘  └──────────────┘       │
│         ↑                                   │
│         └───────────────────────────┐      │
│                                     │      │
│  ┌──────────────────────────────────┘      │
│  │   PostgreSQL                            │
│  │   :5432 (internal)                      │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
         ↑
    Only port 80
    exposed to host
```

## Real-World Application

In production:
- Only expose what's necessary (usually one entry point)
- Use reverse proxy/load balancer for everything
- Keep databases and internal services unexposed
- Implement proper firewall rules

## Testing Checklist

✓ Application accessible at http://localhost
✓ API accessible at http://localhost/api/
✓ nmap shows only port 80 exposed
✓ Direct backend access (http://localhost:8080) not possible
✓ All buttons and features work normally
✓ No performance issues

## Summary

Exercise 2.10 demonstrates proper Docker networking practices:
- Only expose necessary ports
- Use container names for internal communication
- Single entry point for all external access
- Reverse proxy handles all routing
