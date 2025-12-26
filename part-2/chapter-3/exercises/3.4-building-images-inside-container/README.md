# Exercise 3.4: Building Images from Inside a Container

## Overview

Containerize the builder script from Exercise 3.3 to run Docker commands inside a Docker container using the docker.sock socket. This demonstrates Docker-in-Docker (DinD) patterns and environment variable-based authentication.

## Key Concepts

**Docker Socket Mounting:**
- Mount `/var/run/docker.sock` to allow container to control host Docker daemon
- Enables running docker commands inside containers
- Used by tools like Watchtower, Docker Compose, and build automation

**Environment Variables for Secrets:**
- `DOCKER_USER`: Docker Hub username (passed at runtime)
- `DOCKER_PWD`: Docker Hub password/token (passed at runtime)
- Never hardcode credentials in Dockerfile

**ENTRYPOINT:**
- Executes script with command-line arguments
- Container becomes executable accepting arguments directly

## Usage

### Build the Image

```bash
docker build -t builder .
```

### Run the Script

```bash
docker run -e DOCKER_USER=your_username \
  -e DOCKER_PWD=your_password \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder mluukkai/express_app your_username/testing
```

### With Access Token (Recommended)

```bash
docker run -e DOCKER_USER=your_username \
  -e DOCKER_PWD=your_access_token \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder mluukkai/express_app your_username/testing
```

## Files

- **Dockerfile**: Base image with Docker CLI, Git, and script
- **builder.sh**: Enhanced script with Docker Hub authentication

## How It Works

1. Image uses `docker:20-dind` (Docker in Docker)
2. Git and bash installed for script execution
3. builder.sh copied and set as ENTRYPOINT
4. At runtime:
   - Environment variables passed
   - docker.sock mounted for host Docker access
   - Script receives GitHub and Docker Hub repos as arguments
   - Script logs in with provided credentials
   - Script clones, builds, and pushes as before

## Architecture

```
Host System
├── Docker Daemon (listening on /var/run/docker.sock)
└── Container (builder)
    ├── Docker CLI (no daemon)
    ├── Git
    └── builder.sh script
```

The container doesn't run its own Docker daemon; it connects to the host's daemon via the socket.

## Security Notes

- Never commit credentials to Docker repository
- Use environment variables (not hardcoded in image)
- Prefer access tokens over passwords
- Use docker run with `-e` flag to pass secrets at runtime
- Consider using Docker secrets or environment files in production

## Testing

```bash
# Test with a public repository
docker build -t builder .
docker run -e DOCKER_USER=test \
  -e DOCKER_PWD=test \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder docker-library/hello-world your_username/hello
```

## Key Learning Outcomes

- Docker-in-Docker (DinD) patterns
- Socket mounting for inter-process communication
- Environment variables for runtime configuration
- ENTRYPOINT vs CMD usage
- Container security best practices

## Related Exercises

- **3.3**: Local builder script
- **3.1**: CI/CD with GitHub Actions
- **2.11**: Containerized development environment
