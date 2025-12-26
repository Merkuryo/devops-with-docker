# Exercise 3.3: Scripting Magic

## Overview

In this exercise, we create an automated shell script (`builder.sh`) that:
1. Clones a GitHub repository
2. Builds a Docker image from the repository's Dockerfile
3. Pushes the image to Docker Hub

This demonstrates automation and scripting skills, automating the manual Docker build-push workflow that would typically be done in CI/CD pipelines or by developers.

## Purpose

The `builder.sh` script automates the entire Docker image building and publishing workflow. Instead of manually:
- `git clone` a repository
- `docker build` the image
- `docker push` to Docker Hub

You can simply run:
```bash
./builder.sh <github-repo> <docker-hub-repo>
```

This is useful for:
- Local development automation
- Batch building multiple Docker images
- Creating reusable CI/CD components
- Learning shell scripting and error handling

## Prerequisites

- Docker installed and running
- Docker Hub account
- Git installed
- Already logged in to Docker Hub: `docker login`

## Usage

### Basic Usage

```bash
./builder.sh <github-repo> <docker-hub-repo>
```

### Arguments

| Argument | Description | Format | Example |
|----------|-------------|--------|---------|
| `github-repo` | GitHub repository | `username/repository` | `mluukkai/express_app` |
| `docker-hub-repo` | Docker Hub repository | `username/repository` | `mluukkai/testing` |

### Examples

```bash
# Build and push the express_app repository
./builder.sh mluukkai/express_app mluukkai/testing

# Build and push another repository
./builder.sh docker-library/hello-world myusername/hello-world

# Using your own repositories
./builder.sh Merkuryo/node-api Merkuryo/node-api-prod
```

## Script Features

### Error Handling

The script uses `set -e` to exit immediately on any error, ensuring:
- Invalid arguments are caught early
- Failed clones are reported
- Failed builds stop the process
- Failed pushes prevent incomplete uploads

### Validation

1. **Argument Validation**: Ensures both arguments are provided in `username/repo` format
2. **Repository Validation**: Verifies the GitHub repository exists before cloning
3. **Dockerfile Check**: Ensures a Dockerfile exists in the repository root
4. **Docker Auth Check**: Verifies Docker Hub authentication before pushing

### Color-Coded Output

The script provides clear feedback with color-coded messages:
- **BLUE**: General information
- **GREEN**: Successful operations
- **YELLOW**: Warnings
- **RED**: Errors

### Automatic Cleanup

- Creates a temporary directory for cloning
- Automatically cleans up after completion
- Uses PID in temp directory name to avoid conflicts with parallel runs

### Timestamped Images

The script automatically creates both:
- `latest` tag for current version
- Timestamped tag (e.g., `20240101_143022`) for version history

## Script Walkthrough

```bash
#!/bin/bash
```
- Shebang line for bash execution

```bash
set -e
```
- Exit immediately if any command fails (strict error handling)

```bash
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}
```
- Helper functions for formatted output with colors

```bash
if [ $# -ne 2 ]; then
    # Error handling
fi
```
- Validates exactly 2 arguments provided

```bash
if [[ ! "$GITHUB_REPO" =~ "/" ]]; then
    # Error handling
fi
```
- Validates format includes `/` (username/repo)

```bash
TEMP_DIR="/tmp/docker_builder_$$"
```
- Creates unique temp directory using PID (`$$`)

```bash
git clone "https://github.com/$GITHUB_REPO.git" .
```
- Clones repository to current directory
- Constructs GitHub URL from argument

```bash
docker build -t "$DOCKER_HUB_REPO:latest" .
```
- Builds image with Docker Hub repo as tag
- Targets current directory (`.`) as build context

```bash
docker push "$DOCKER_HUB_REPO:latest"
```
- Pushes to Docker Hub

```bash
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
```
- Creates timestamp in format: YYYYMMDD_HHMMSS

```bash
rm -rf "$TEMP_DIR"
```
- Cleans up temporary files

## Step-by-Step Execution Flow

1. **Argument Validation**
   - Check if 2 arguments provided
   - Validate format contains `/`

2. **Setup Phase**
   - Create temporary directory with unique name
   - Extract repository name from argument
   - Print operation details

3. **Clone Phase**
   - Clone GitHub repository to temp directory
   - Verify clone success
   - Check Dockerfile exists

4. **Build Phase**
   - Build Docker image using cloned Dockerfile
   - Tag with Docker Hub repository name
   - Verify build success

5. **Authentication Phase**
   - Check Docker Hub login status
   - Guide user to login if needed

6. **Push Phase**
   - Push `latest` tag to Docker Hub
   - Create and push timestamped tag
   - Verify push success

7. **Cleanup Phase**
   - Remove temporary directory
   - Print completion message
   - Display Docker Hub repository URL

## Error Handling Examples

### Missing Arguments
```bash
$ ./builder.sh
[ERROR] Invalid number of arguments
Usage: ./builder.sh <github_repo> <docker_hub_repo>
Example: ./builder.sh mluukkai/express_app mluukkai/testing
```

### Invalid Repository Format
```bash
$ ./builder.sh mluukkai docker-hub-repo
[ERROR] Repository format must be 'username/repo'
```

### Non-existent GitHub Repository
```bash
$ ./builder.sh invalid/nonexistent myrepo/test
[ERROR] Failed to clone repository
[ERROR] Make sure the repository exists: https://github.com/invalid/nonexistent
```

### Missing Dockerfile
```bash
$ ./builder.sh mluukkai/nodejs myrepo/nodejs
[ERROR] Dockerfile not found in repository root
```

### Not Logged in to Docker Hub
```bash
$ ./builder.sh mluukkai/express_app myrepo/express
[WARNING] Not logged in to Docker Hub
[INFO] Please log in to Docker Hub:
[INFO]   docker login
[INFO] Then run the script again
```

## Docker Hub Authentication

Before running the script, ensure you're logged in to Docker Hub:

```bash
docker login
```

You'll be prompted for:
- Docker ID (username)
- Password or access token

Verify login status:
```bash
docker info
# Look for "Username: your_username" in the output
```

## Testing the Script

### Test with Public Repository

```bash
# Clone this repo for testing
./builder.sh Merkuryo/devops-with-docker your-username/test-image
```

### Test with Docker Official Image

```bash
# Build docker/hello-world example
./builder.sh docker-library/hello-world your-username/hello-world
```

### Test Error Handling

```bash
# Test missing arguments
./builder.sh

# Test invalid format
./builder.sh username-only myrepo

# Test non-existent repo
./builder.sh totally/fake myrepo
```

## Advanced Usage

### Batch Building Multiple Images

```bash
#!/bin/bash
# build_multiple.sh - Build multiple images at once

REPOS=(
    "mluukkai/express_app:mluukkai/testing"
    "docker-library/hello-world:myusername/hello"
    "Merkuryo/node-api:myusername/node-api"
)

for repo in "${REPOS[@]}"; do
    github_repo=$(echo "$repo" | cut -d: -f1)
    docker_repo=$(echo "$repo" | cut -d: -f2)
    ./builder.sh "$github_repo" "$docker_repo"
done
```

### Logging Output to File

```bash
./builder.sh mluukkai/express_app mluukkai/testing 2>&1 | tee build.log
```

### Timing Builds

```bash
time ./builder.sh mluukkai/express_app mluukkai/testing
```

## Output Example

```
[INFO] Starting Docker Builder Script
[INFO] GitHub Repository: mluukkai/express_app
[INFO] Docker Hub Repository: mluukkai/testing
[INFO] Creating temporary directory: /tmp/docker_builder_12345
[INFO] Cloning GitHub repository...
[SUCCESS] Repository cloned successfully
[SUCCESS] Dockerfile found
[INFO] Building Docker image: mluukkai/testing
[SUCCESS] Docker image built successfully
[INFO] Checking Docker Hub authentication...
[SUCCESS] Docker Hub authentication verified
[INFO] Pushing image to Docker Hub: mluukkai/testing:latest
[SUCCESS] Image pushed to Docker Hub successfully
[INFO] Creating timestamped tag: mluukkai/testing:20240115_143022
[SUCCESS] Timestamped image pushed: mluukkai/testing:20240115_143022
[INFO] Cleaning up temporary directory
[SUCCESS] Docker Builder Script completed successfully!
[INFO] Image available at: https://hub.docker.com/r/mluukkai/testing
[INFO] Pull with: docker pull mluukkai/testing:latest
```

## Troubleshooting

### Permission Denied Error

```
Permission denied: /path/to/builder.sh
```

**Solution**: Make script executable
```bash
chmod +x builder.sh
```

### Docker Daemon Not Running

```
Cannot connect to Docker daemon
```

**Solution**: Start Docker
```bash
# On Linux
sudo systemctl start docker

# On macOS/Windows
open -a Docker  # or start Docker Desktop
```

### Failed Push to Docker Hub

```
denied: requested access to the resource is denied
```

**Solution**: 
- Verify you're logged in: `docker login`
- Verify you own the Docker Hub repository
- Use correct username

### Disk Space Issues

```
no space left on device
```

**Solution**: Free up disk space or clean old Docker images
```bash
docker image prune -a
docker system prune
```

## Key Learnings

1. **Shell Scripting**: Function definitions, argument handling, error checking
2. **Automation**: Combining multiple commands into a reusable script
3. **Error Handling**: Using `set -e` and checking command success
4. **User Experience**: Color output, clear messages, help text
5. **Resource Management**: Creating and cleaning temporary files
6. **Version Control**: Timestamping builds for tracking

## Related Exercises

- **Exercise 2.11**: Containerized development environment (Docker setup)
- **Exercise 3.1**: GitHub Actions CI/CD (automated building)
- **Exercise 3.2**: Cloud deployment (using built images)

## Conclusion

The `builder.sh` script demonstrates how to automate Docker workflows using shell scripting. This is a foundational skill for:
- Building local development automation
- Creating CI/CD pipeline components
- Writing infrastructure-as-code tools
- Automating repetitive Docker tasks

This type of automation is commonly used in production environments to standardize image building processes and reduce manual errors.
