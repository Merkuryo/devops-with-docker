# Exercise 2.2 - Simple Service with Browser

## Objective

Create a docker-compose.yaml file that starts a web service accessible via browser using Docker Compose.

## Project Details

- **Service:** devopsdockeruh/simple-web-service
- **Port:** 8080
- **Command:** server (to listen on port)
- **Access:** http://localhost:8080

## Success Criteria

- docker-compose.yaml file created correctly
- Service starts with `docker compose up`
- Web service is accessible from browser at localhost:8080
- Port 8080 is properly exposed
- Service responds with JSON data

## Key Concepts

**Docker Compose for Web Services:**
- Port mapping in compose: `ports: - 8080:8080`
- Command override in compose: `command: server`
- Running in foreground with `docker compose up`
- Running in detached mode with `docker compose up -d`

**Port Mapping Syntax:**
- `host_port:container_port`
- 8080:8080 means map port 8080 on host to 8080 in container

**Command Override:**
- The `command` key allows running a different command than the Dockerfile's CMD
- In this case, `server` makes the service listen on port 8080

## Usage

```bash
# Start the service in foreground (see logs)
docker compose up

# Start in detached mode (runs in background)
docker compose up -d

# Test with curl
curl http://localhost:8080

# Stop the service
docker compose down
```

## Docker Compose YAML Syntax

```yaml
services:
  simple-web-service:
    image: devopsdockeruh/simple-web-service
    container_name: simple-web-service
    ports:
      - 8080:8080
    command: server
```

**Explanation:**
- `ports` - Maps container port 8080 to host port 8080
- `command` - Runs the "server" command to start the web service
- This replaces the need for `docker run -p 8080:8080 ... server`

## Expected Output

When accessing http://localhost:8080:
- Response: JSON with message and path information
- Example: `{"message":"You connected to the following path: /","path":"/"}`
