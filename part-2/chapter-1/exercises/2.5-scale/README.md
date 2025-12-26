# Exercise 2.5 - Scale

## Objective

Scale a Docker Compose application using a load balancer to handle multiple compute container instances.

## Project Details

- **Source:** https://github.com/docker-hy/material-applications/tree/main/scaling-exercise
- **Application:** Calculator with compute backend
- **Port:** 3000 (calculator frontend)
- **Load Balancer:** nginx-proxy for routing to compute instances
- **Scaling:** Multiple compute containers behind load balancer

## Success Criteria

- Clone the scaling-exercise project
- Run docker compose up
- Scale compute containers to handle the load
- Button in application turns green
- Load balancer routes requests to compute instances

## Key Concepts

**Load Balancing:**
- nginx-proxy acts as load balancer
- Routes requests to available compute instances
- Uses VIRTUAL_HOST environment variable for routing
- Automatically discovers services via docker.sock

**Scaling:**
- `docker compose up --scale compute=X` creates X instances
- Multiple containers share port 3000 internally
- Load balancer distributes traffic
- Service name stays the same for all instances

**Docker Socket Mounting:**
- `/var/run/docker.sock:/tmp/docker.sock:ro` allows load balancer to discover services
- Read-only mode for security
- Load balancer monitors Docker daemon for container changes

## Application Components

1. **Calculator:** Frontend on port 3000
   - User interface for calculations
   - Sends compute jobs to backend

2. **Compute:** Backend compute service
   - Processes heavy calculations
   - Multiple instances behind load balancer
   - Accessed via VIRTUAL_HOST=compute.localtest.me

3. **Load Balancer:** nginx-proxy
   - Routes incoming requests
   - Discovers containers via Docker socket
   - Distributes load across compute instances

## Scaling Strategy

The application doesn't work well because:
- Single compute instance can't handle the load
- Application button stays red (error/timeout)

Solution:
- Scale compute service to multiple instances
- Load balancer automatically routes to available instances
- Each instance can handle some requests
- Combined capacity satisfies the application

## Usage

**Clone the project:**
```bash
git clone https://github.com/docker-hy/material-applications.git
cd material-applications/scaling-exercise
```

**Start with single instance (will fail):**
```bash
docker compose up
```

**Scale compute (in another terminal):**
```bash
docker compose up --scale compute=3
```

Or restart with scaling:
```bash
docker compose up -d --scale compute=3
```

**Test the application:**
```
http://localhost:3000
```

**Find which port compute is on:**
```bash
docker compose port --index 1 compute 8080
docker compose port --index 2 compute 8080
docker compose port --index 3 compute 8080
```

**Stop services:**
```bash
docker compose down
```

## Understanding localtest.me

- `localtest.me` is a domain that points to 127.0.0.1
- `compute.localtest.me` resolves to localhost
- Load balancer uses VIRTUAL_HOST to route requests
- Alternative domains: colasloth.com, lvh.me, vcap.me

## How Scaling Works

1. **Without scaling:** One compute container → may timeout → button red
2. **With scaling:** Multiple compute containers → distributed load → faster responses → button green

The load balancer (nginx-proxy):
- Listens on port 80
- Routes requests based on VIRTUAL_HOST
- Automatically discovers new compute instances
- Distributes requests round-robin style

## Key Files in Scaling Exercise

- `docker-compose.yml` - Services definition
- `load-balancer/` - Custom nginx-proxy configuration
- Expects compute and calculator images to be available

## Example Scaling Commands

Scale to 3 instances:
```bash
docker compose up -d --scale compute=3
```

Scale to 5 instances:
```bash
docker compose up -d --scale compute=5
```

Check running instances:
```bash
docker compose ps
```

View logs from all instances:
```bash
docker compose logs
```
