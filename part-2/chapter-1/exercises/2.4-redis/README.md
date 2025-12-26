# Exercise 2.4 - Redis (Mandatory)

## Objective

Expand the configuration from Exercise 2.3 and set up Redis as a caching layer for the backend service.

## Project Details

- **Frontend:** React application on port 5000
- **Backend:** Go application on port 8080 (with Redis support)
- **Redis:** In-memory cache for performance optimization
- **Tool:** Docker Compose with networking

## Success Criteria

- docker-compose.yaml file created correctly
- All three services start with `docker compose up`
- Backend can access Redis via internal Docker network
- Redis is NOT exposed to the outside (no ports published)
- Exercise 2.4 button in frontend turns green when clicked
- Performance improved due to Redis caching

## Key Concepts

**Docker Networking:**
- Services in the same docker-compose.yaml share a network automatically
- Services communicate using service names (redis:6379)
- No need to publish Redis port (security best practice)
- Internal DNS resolves service names to IP addresses

**Redis Setup:**
- Uses official redis:7 image
- Runs on default port 6379 (internal only)
- Accessed by backend via REDIS_HOST environment variable
- No ports exposed to the host machine

**Restart Policy:**
- `restart: unless-stopped` on backend ensures it restarts if Redis isn't ready
- Handles race conditions where Redis takes time to start

## Docker Compose YAML Syntax

```yaml
services:
  backend:
    ...
    environment:
      - REDIS_HOST=redis
    depends_on:
      - redis
    restart: unless-stopped

  redis:
    image: redis:7
    # Note: NO ports configuration - only accessible internally
```

## How It Works

1. Backend service has REDIS_HOST=redis environment variable
2. Redis service runs without exposing ports
3. Backend can access Redis at redis:6379 (service name:default port)
4. Internal Docker DNS translates "redis" to the Redis container IP
5. Caching layer improves performance for slow API calls

## Performance Improvement

- **Without Redis:** Each /ping?redis=true request is slow (calls slow API)
- **With Redis:** First request is slow, subsequent requests are fast (cached)
- The button will show response time differences

## Security Best Practice

- Redis is NOT accessible from outside Docker
- Only backend service can access it
- No ports published for Redis
- Protected by Docker network isolation
