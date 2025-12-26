# Exercise 2.8 - Reverse Proxy (Mandatory)

## Objective

Add Nginx as a reverse proxy to serve the application on a single port (80) with the frontend at the root path and backend API under the `/api/` prefix.

## What is a Reverse Proxy?

A reverse proxy sits in front of web servers and forwards client requests to those servers. In this case:
- Single entry point: http://localhost (port 80)
- Forwards `/` requests to frontend
- Forwards `/api/` requests to backend
- Clients don't know about individual services

## Architecture

```
Browser → Nginx (localhost:80) → Frontend (localhost:5000) internal
                              → Backend (localhost:8080) internal
                              → Redis (internal)
                              → PostgreSQL (internal)
```

## Key Configuration Changes

### 1. Added Nginx Service

```yaml
proxy:
  image: nginx:latest
  container_name: nginx-proxy
  ports:
    - 80:80
  volumes:
    - ./nginx.conf:/etc/nginx/nginx.conf:ro
  depends_on:
    - frontend
    - backend
  restart: unless-stopped
```

**Key points:**
- Listens on port 80 (external)
- Mounts `nginx.conf` as read-only
- Depends on frontend and backend
- Only Nginx exposes external ports

### 2. Nginx Configuration (nginx.conf)

```nginx
events { worker_connections 1024; }

http {
  server {
    listen 80;

    # Forward / to frontend
    location / {
      proxy_pass http://frontend:5000/;
    }

    # Forward /api/ to backend
    location /api/ {
      proxy_set_header Host $host;
      proxy_pass http://backend:8080/;
    }
  }
}
```

**How it works:**
- `listen 80` - Nginx listens on port 80
- `location /` - Matches requests to root path
- `proxy_pass http://frontend:5000/` - Forwards to frontend service
- `location /api/` - Matches requests starting with `/api/`
- `proxy_pass http://backend:8080/` - Forwards to backend service
- `proxy_set_header` - Preserves original Host header for backend

### 3. Backend Changes

**Removed port mapping:**
```yaml
# No longer exposed: 8080:8080
```

**Updated environment variables:**
```yaml
environment:
  - REQUEST_ORIGIN=http://localhost
  - REACT_APP_BACKEND_URL=http://localhost/api
```

Now uses `http://localhost` instead of `http://localhost:5000` or direct ports.

### 4. Frontend Changes

**Removed port mapping:**
```yaml
# No longer exposed: 5000:5000
```

**Updated environment variable:**
```yaml
environment:
  - REACT_APP_BACKEND_URL=http://localhost/api
```

Frontend makes requests to `/api/` which Nginx forwards to backend.

### 5. Redis and PostgreSQL

No changes - still internal only (no port mappings).

## Service Communication

### Before (Direct Ports)
```
Frontend (http://localhost:5000)
Backend (http://localhost:8080)
Redis (no external access)
PostgreSQL (no external access)
```

### After (Reverse Proxy)
```
Frontend (http://localhost/)
Backend (http://localhost/api/)
Redis (no external access)
PostgreSQL (no external access)
```

## URL Routing

| Request | Nginx Action | Destination |
|---------|--------------|-------------|
| `GET /` | Match `/` | Frontend |
| `GET /static/...` | Match `/` | Frontend |
| `GET /api/ping` | Match `/api/` | Backend |
| `POST /api/messages` | Match `/api/` | Backend |

## Docker Networking

All services are in the same Docker network, so:
- `http://frontend:5000` - Resolves to frontend container
- `http://backend:8080` - Resolves to backend container
- Service names work as DNS hostnames internally

## Testing

### Test reverse proxy is working:
```bash
# Frontend on root
curl http://localhost/
curl http://localhost/static/css/main.eaa5d75e.chunk.css

# Backend API
curl http://localhost/api/ping
curl http://localhost/api/messages
```

All should return expected responses without exposing internal ports.

### Browser test:
- Go to `http://localhost`
- Frontend loads
- Click buttons (some may not work until frontend is reconfigured)
- Check console for requests to `/api/`

## Important Notes

### Trailing Slashes Matter
```nginx
location /api/ {
  proxy_pass http://backend:8080/;
}
```

Notice the trailing `/` on both sides:
- `location /api/` - Matches `/api/something` (not `/api`)
- `proxy_pass http://backend:8080/;` - Adds trailing slash

### Read-Only Volume
```yaml
volumes:
  - ./nginx.conf:/etc/nginx/nginx.conf:ro
```

The `:ro` makes it read-only - Nginx can't accidentally modify the config.

## Why Use a Reverse Proxy?

1. **Single Entry Point** - One port for entire application
2. **Load Balancing** - Could distribute across multiple backends
3. **SSL/TLS Termination** - Encrypt HTTPS in one place
4. **Request Routing** - Complex routing rules
5. **Security** - Hide internal service details
6. **Caching** - Cache responses
7. **Compression** - Compress responses

## Port Summary

| Service | Internal | External |
|---------|----------|----------|
| Nginx | 80 | 80 |
| Frontend | 5000 | None (through Nginx) |
| Backend | 8080 | None (through Nginx) |
| Redis | 6379 | None |
| PostgreSQL | 5432 | None |

## Common Issues

### "Connection refused" to backend
Check `proxy_pass` URL in nginx.conf matches service name and port.

### Trailing slash issues
Ensure both sides of `proxy_pass` have matching slashes.

### Host header errors
Use `proxy_set_header Host $host;` to preserve original host.

## Docker Compose Execution Order

1. `depends_on` lists create startup order:
   - Redis and PostgreSQL start first
   - Then backend (after deps)
   - Then frontend (after backend)
   - Finally Nginx (after frontend and backend)

2. All services wait in Docker network for dependencies

## Testing Checklist

✓ Nginx container starts
✓ Frontend accessible at http://localhost/
✓ Backend API accessible at http://localhost/api/ping
✓ All services in same network
✓ Direct ports (5000, 8080) not accessible
✓ PostgreSQL data persists in ./database
✓ Redis works internally

## Success Indicators

1. `curl http://localhost/api/ping` returns `pong`
2. `curl http://localhost/` returns HTML frontend
3. Browser at `http://localhost` loads application
4. No errors in Nginx logs
5. Services can communicate internally
