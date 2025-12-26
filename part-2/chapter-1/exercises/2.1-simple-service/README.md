# Exercise 2.1 - Simple Service Writing to Log

## Objective

Create a docker-compose.yaml file that starts a simple web service and saves its logs to the filesystem.

## Project Details

- **Service:** devopsdockeruh/simple-web-service
- **Log Location:** /usr/src/app/text.log
- **Tool:** Docker Compose
- **Volume:** Bind mount to host filesystem

## Success Criteria

- docker-compose.yaml file created correctly
- Service starts with `docker compose up`
- Logs are written to text.log in the host directory
- File can be viewed without entering the container

## Key Concepts

**Docker Compose Benefits:**
- Simplified container management
- No need for long docker run commands
- Easy to version control and share
- Multiple services can be defined in one file

**Volumes in Docker Compose:**
- Syntax: `host-path:container-path`
- Can use relative paths (.:/usr/src/app)
- Logs persist after container stops
- Real-time file access from host

## Usage

```bash
# Start the service
docker compose up

# In another terminal, check the logs
tail -f text.log

# Stop the service
docker compose down
```

## Docker Compose YAML Syntax

```yaml
services:
  simple-web-service:
    image: devopsdockeruh/simple-web-service
    container_name: simple-web-service
    volumes:
      - .:/usr/src/app
```

**Explanation:**
- `services` - Defines all containers
- `simple-web-service` - Service name
- `image` - Docker image to use
- `container_name` - Name for the running container
- `volumes` - Maps current directory to /usr/src/app in container
