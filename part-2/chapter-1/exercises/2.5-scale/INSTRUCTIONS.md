# Exercise 2.5 - Scale (Instructions)

## Project Source

This exercise uses the scaling-exercise project from:
https://github.com/docker-hy/material-applications/tree/main/scaling-exercise

## How to Run

### Step 1: Clone the project
```bash
git clone https://github.com/docker-hy/material-applications.git
cd material-applications/scaling-exercise
```

### Step 2: Build the load-balancer image
```bash
docker compose build load-balancer
```

### Step 3: Start services with scaling
```bash
docker compose up -d --scale compute=3
```

- `--scale compute=3` creates 3 instances of the compute service
- Load balancer automatically routes to all instances
- Calculator frontend accessible at http://localhost:3000

### Step 4: Access and test
Open browser to `http://localhost:3000` and click the button. It should turn green.

The button turns green when:
- Frontend successfully reaches backend through load balancer
- Load is distributed across 3 compute instances
- All instances respond within timeout

### Step 5: Verify scaling
```bash
docker compose ps
```

Shows:
- 1 calculator container
- 1 load-balancer container  
- 3 compute containers (scaling-exercise-compute-1, -2, -3)

### Step 6: Cleanup
```bash
docker compose down
```

## How Scaling Works

**Single compute instance (without scaling):**
- Creates only 1 compute container
- Cannot handle the load
- Requests timeout
- Button stays red (error state)

**Multiple compute instances (with scaling):**
- Creates 3 compute containers
- Load balancer distributes requests
- Each instance handles ~1/3 of requests
- All requests complete quickly
- Button turns green (success)

## Load Balancer Details

The load-balancer service:
- Listens on port 80
- Mounts Docker socket: `/var/run/docker.sock:/tmp/docker.sock:ro`
- Reads VIRTUAL_HOST environment variable from compute containers
- Uses DNS name `compute.localtest.me` to route requests
- Automatically discovers new compute instances

## What's Happening Internally

1. **Calculator** sends request to `compute.localtest.me`
2. **Load balancer** receives request on port 80
3. Load balancer sees VIRTUAL_HOST=compute.localtest.me
4. Load balancer forwards to available **compute** instance
5. **Compute** processes heavy calculation
6. Response sent back through load balancer
7. **Calculator** displays result

## Testing Load Balancing

Check which compute instance handles requests:
```bash
docker compose logs
```

You'll see logs from different compute instances handling requests.

## Key Learning Points

This exercise demonstrates:

1. **Horizontal Scaling** - Adding more instances instead of vertical scaling (more CPU)
2. **Load Balancing** - Distributing traffic across multiple instances
3. **Service Discovery** - Dynamic discovery via docker.sock
4. **Docker Compose Scaling** - Using `--scale` flag to create multiple instances
5. **Virtual Hosting** - Using VIRTUAL_HOST for DNS-based routing

## Why This Approach?

- **Scalability** - Easy to handle more requests by adding instances
- **Reliability** - If one instance fails, others handle requests
- **Flexibility** - Change number of instances without code changes
- **Simplicity** - Docker Compose handles container orchestration

## Equivalent kubectl Command (Kubernetes)

If this were Kubernetes:
```bash
kubectl scale deployment compute --replicas=3
```

Docker Compose equivalent:
```bash
docker compose up --scale compute=3
```

Same concept, different orchestration platform.
