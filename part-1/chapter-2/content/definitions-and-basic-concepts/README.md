# Definitions and Basic Concepts

## What is DevOps?

DevOps combines two concepts: **Dev** (Development) and **Ops** (Operations). At its core, it means that the people who develop software are also responsible for releasing, configuring, and monitoring it.

### Formal Definition

"DevOps is a development methodology aimed at bridging the gap between Development and Operations, emphasizing communication and collaboration, continuous integration, quality assurance and delivery with automated deployment utilizing a set of development practices" - Jabbari et al.

In this course, we focus on the packaging, releasing, and configuring of applications. We won't be creating new software, but rather learning how to containerize and deploy existing applications using Docker and related technologies like Redis and PostgreSQL.

## What is Docker?

According to Wikipedia: "Docker is a set of platform as a service (PaaS) products that use OS-level virtualization to deliver software in packages called containers."

Simply put:
- **Docker** is a set of tools to deliver software in containers
- **Containers** are packages of software that include the application and its dependencies

These containers are isolated so they don't interfere with each other or other software running outside them.

## Benefits from Containers

### Scenario 1: Works on My Machine

The classic problem: code works perfectly on your computer but fails on the server. Containers solve this by packaging the application with all its dependencies, ensuring it runs the same way everywhere.

### Scenario 2: Isolated Environments

Running multiple applications with different dependency versions on the same server is problematic. Containers allow each application to have its own isolated environment with its required versions (Python 2.7, 3.8, etc.) without conflicts.

### Scenario 3: Development

Instead of manually installing and managing databases (PostgreSQL, MongoDB, Redis) on your development machine, you can spin up containerized versions with a single command.

### Scenario 4: Scaling

Containers start and stop with minimal overhead. With container orchestration, you can instantly scale up to handle increased demand and automatically replace failed containers.

## Virtual Machines vs Containers

### Virtual Machines (VMs)
- Run on a hypervisor
- Include full operating system, binaries, and libraries
- Heavier and more resource-intensive
- Longer startup times
- Provide strong isolation
- Better for complete OS environments

### Containers
- Share the host OS kernel
- Package only the application and its dependencies
- Lightweight and efficient
- Fast startup
- Process-level isolation
- Better for consistent application deployment

**Important note:** Docker relies on Linux kernels. macOS and Windows cannot run Docker natively—they use additional solutions (Docker Desktop for Mac uses a Linux VM under the hood).

## Running Containers

### Image vs Container

**Cooking Metaphor:**
- An **image** is like a recipe and ingredients for a meal
- A **container** is like a ready-to-eat meal you can heat and consume

More formally:
- **Image**: A blueprint or template (immutable file)
- **Container**: An instance of that blueprint at runtime (mutable state)

### Docker Image

A Docker image is a file that never changes after creation. Images are immutable—you cannot edit an existing image. To modify an image, you start from a base image and add new layers.

Images are built from a `Dockerfile`, which contains instructions like:
```dockerfile
FROM <image>:<tag>
RUN <install some dependencies>
CMD <command that is executed on docker container run>
```

### Docker Container

Containers contain the application and what's required to run it (dependencies). They are isolated environments that can:
- Start and stop
- Interact with each other
- Interact with the host machine via TCP/UDP

## Docker CLI Basics

Docker Engine consists of three parts:
1. **Command Line Interface (CLI) client** - what you type
2. **REST API** - communication layer
3. **Docker daemon** - manages images, containers, and resources

When you run a command like `docker container run`, the CLI sends a request to the Docker daemon through the REST API.

### Most Used Commands

| Command | Explanation | Shorthand |
|---------|-------------|-----------|
| `docker image ls` | Lists all images | `docker images` |
| `docker image rm <image>` | Removes an image | `docker rmi` |
| `docker image pull <image>` | Pulls image from registry | `docker pull` |
| `docker container ls -a` | Lists all containers | `docker ps -a` |
| `docker container run <image>` | Runs a container from an image | `docker run` |
| `docker container rm <container>` | Removes a container | `docker rm` |
| `docker container stop <container>` | Stops a container | `docker stop` |
| `docker container exec <container>` | Executes command in container | `docker exec` |

All commands accept either container ID or container name. Many people prefer the shorthands as they require less typing.

### Key Takeaways

- Images are immutable templates
- Containers are instances of images
- The `-d` flag runs containers in detached mode (background)
- Use `docker ps -a` to see all containers including stopped ones
- Always stop a container before removing it (unless using `--force`)
- Use `docker container prune` to clean up stopped containers
- Use `docker image prune` to clean up dangling images
