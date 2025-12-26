# Key Docker Concepts and Terminology

## Core Concepts

### DevOps
A development methodology that emphasizes:
- Communication and collaboration between development and operations teams
- Continuous integration and continuous delivery
- Automated deployment practices
- Shared responsibility for software throughout its lifecycle

### Container
A lightweight, isolated package containing:
- Application code
- Runtime environment
- System dependencies
- Libraries and tools needed to run the application

Containers are ephemeral—they can be created and destroyed quickly with minimal overhead.

### Image
A read-only template used to create containers. Images:
- Are immutable (cannot be changed once created)
- Contain all information needed to run an application
- Are built in layers
- Can be shared and reused
- Are stored in registries like Docker Hub

### Dockerfile
A text file containing instructions to build a Docker image:
- `FROM` - specifies the base image
- `RUN` - executes commands during image build
- `CMD` - specifies the default command when container starts
- `COPY` - adds files from host to image
- `EXPOSE` - documents which ports the container listens on

## Docker Architecture

### Docker Client
The command-line interface you interact with. When you type `docker run`, you're communicating with the Docker daemon through the client.

### Docker Daemon
The background service that manages:
- Images
- Containers
- Networks
- Storage volumes

### Docker Registry
A repository where images are stored and shared:
- Docker Hub is the default public registry
- Can be self-hosted for private images
- Images are pulled from registries as needed

## Container Lifecycle

### States
1. **Created** - Container is created but not running
2. **Running** - Container is actively executing
3. **Paused** - Container is paused temporarily
4. **Stopped/Exited** - Container has finished or been stopped
5. **Deleted/Removed** - Container no longer exists

### Common Operations
- `docker run` - Create and start a container
- `docker start` - Start a stopped container
- `docker stop` - Gracefully stop a running container
- `docker restart` - Stop and start a container
- `docker rm` - Delete a stopped container
- `docker exec` - Run a command inside a running container

## Isolation and Security

### Process Isolation
Containers provide process-level isolation, preventing:
- One container from accessing another's memory
- Interference with the host system
- Cross-contamination of dependencies

### Network Isolation
By default, containers cannot communicate with each other unless explicitly configured. You can:
- Expose specific ports
- Create custom networks
- Link containers together

## Image Layers

Docker images are built using a layering system:
- Each instruction in a Dockerfile creates a new layer
- Layers are cached and reused
- Only changed layers are rebuilt
- This makes image building efficient and fast

## Working with Images and Containers

### Pulling an Image
```bash
docker image pull nginx
```
Downloads an image without running it.

### Listing Resources
```bash
docker image ls      # List all images
docker container ls  # List running containers
docker container ls -a  # List all containers (including stopped)
```

### Removing Resources
Always remove containers before removing their images:
```bash
docker container rm <container>  # Remove container
docker image rm <image>          # Remove image
```

### Cleanup Commands
```bash
docker container prune  # Remove all stopped containers
docker image prune      # Remove dangling images
docker system prune     # Remove containers, images, and networks
```

## Detached Mode

The `-d` flag runs containers in detached mode:
```bash
docker run -d nginx
```

This starts the container in the background, returning the container ID without blocking your terminal. Without `-d`, the container runs in the foreground, and you must press Ctrl+C to regain terminal control.
