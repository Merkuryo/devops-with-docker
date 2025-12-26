# Exercise 3.3 Setup Guide

## Prerequisites

Before running the `builder.sh` script, ensure you have the following installed and configured:

### 1. Docker

**Installation:**
- On macOS: Install Docker Desktop from https://www.docker.com/products/docker-desktop
- On Linux: `sudo apt-get install docker.io` (Ubuntu/Debian)
- On Windows: Docker Desktop from https://www.docker.com/products/docker-desktop

**Verify Installation:**
```bash
docker --version
# Docker version 24.0.0 or later

docker run hello-world
# Should print "Hello from Docker!"
```

### 2. Git

**Installation:**
```bash
# macOS
brew install git

# Linux
sudo apt-get install git

# Windows
https://git-scm.com/download/win
```

**Verify Installation:**
```bash
git --version
# git version 2.40.0 or later
```

### 3. Docker Hub Account

**Setup:**
1. Create account at https://hub.docker.com/
2. Note your username (we'll use this as `docker-hub-repo` argument)
3. Create an access token (optional but recommended for automation):
   - Go to Account Settings → Security
   - Click "New Access Token"
   - Copy the token

### 4. Docker Hub Authentication

**Using Docker Login:**

```bash
docker login
```

Then enter:
- Username: your Docker Hub username
- Password: your Docker Hub password or access token

**Using Access Token (Recommended):**

```bash
docker login --username your_username --password-stdin
# Paste your access token when prompted
```

**Verify Authentication:**
```bash
docker info
# Look for "Username: your_username" in output
```

## Setup Steps

### Step 1: Make Script Executable

```bash
cd /path/to/3.3-scripting-magic
chmod +x builder.sh
```

Verify:
```bash
ls -la builder.sh
# Should show: -rwxr-xr-x (executable)
```

### Step 2: Verify Docker is Running

```bash
docker ps
# Should work without error
```

### Step 3: Verify Git Access

```bash
git clone https://github.com/docker-library/hello-world.git /tmp/test-clone
# Should clone successfully
rm -rf /tmp/test-clone
```

### Step 4: Verify Docker Hub Login

```bash
docker info | grep Username
# Should show: Username: your_username
```

## Testing the Script

### Test 1: Basic Functionality with Public Repository

```bash
# Build and push the hello-world example
./builder.sh docker-library/hello-world your-username/test-hello

# Expected output:
# [INFO] Starting Docker Builder Script
# [INFO] GitHub Repository: docker-library/hello-world
# [INFO] Docker Hub Repository: your-username/test-hello
# ...
# [SUCCESS] Docker Builder Script completed successfully!
# [INFO] Pull with: docker pull your-username/test-hello:latest
```

**Verify on Docker Hub:**
```bash
# Visit https://hub.docker.com/r/your-username/test-hello
# Should see new repository with latest and timestamped tags
```

### Test 2: Test with Real Application

```bash
# Clone and build a Node.js application
./builder.sh mluukkai/express_app your-username/express-test

# This will:
# 1. Clone the express_app from GitHub
# 2. Build the Docker image
# 3. Push to your Docker Hub
```

### Test 3: Verify Timestamped Tag

```bash
# After running the script, check Docker Hub for tags
# You should see:
# - latest
# - YYYYMMDD_HHMMSS (e.g., 20240115_143022)

docker pull your-username/express-test:latest
docker run your-username/express-test:latest
```

### Test 4: Error Handling Tests

**Test missing arguments:**
```bash
./builder.sh
# Expected: [ERROR] Invalid number of arguments
```

**Test invalid format:**
```bash
./builder.sh only-one-part your-username/repo
# Expected: [ERROR] Repository format must be 'username/repo'
```

**Test non-existent repository:**
```bash
./builder.sh totally/nonexistent your-username/test
# Expected: [ERROR] Failed to clone repository
```

**Test non-existent Docker Hub repository permission:**
```bash
./builder.sh some/repo someone-else/private-repo
# Expected: [ERROR] Failed to push image to Docker Hub
# (if you don't have permission)
```

### Test 5: Cleanup Verification

```bash
# The script should clean up temp directory
ls /tmp | grep docker_builder
# Should return nothing (all temp directories cleaned)
```

## Running Tests

### Automated Test Suite

```bash
#!/bin/bash
# test_builder.sh - Run all tests

echo "=== Test 1: Help and Usage ==="
./builder.sh
echo

echo "=== Test 2: Invalid Format ==="
./builder.sh invalid your-username/test
echo

echo "=== Test 3: Non-existent Repo ==="
./builder.sh totally/fake your-username/test
echo

echo "=== Test 4: Build Hello World ==="
./builder.sh docker-library/hello-world your-username/test-hello
echo

echo "=== Test 5: Check Docker Hub ==="
echo "Visit: https://hub.docker.com/r/your-username"
```

## Troubleshooting

### Problem: Permission Denied

```
./builder.sh: Permission denied
```

**Solution:**
```bash
chmod +x builder.sh
```

### Problem: Docker Daemon Not Running

```
Cannot connect to Docker daemon at unix:///var/run/docker.sock
```

**Solution:**

On Linux:
```bash
sudo systemctl start docker
sudo usermod -aG docker $USER
# Log out and back in for group changes to take effect
```

On macOS:
```bash
# Start Docker Desktop application
open -a Docker
```

### Problem: Not Logged Into Docker Hub

```
[WARNING] Not logged in to Docker Hub
```

**Solution:**
```bash
docker login
# Enter your Docker Hub credentials
```

### Problem: Build Fails Due to Dockerfile Issues

```
[ERROR] Failed to build Docker image
```

**Solution:**
```bash
# Check if Dockerfile exists in repository root
./builder.sh <repo> <docker-hub-repo> 2>&1 | tee build.log
# Review build.log for specific error

# Or clone manually to inspect
git clone https://github.com/<repo>.git
cd <repo>
docker build .
```

### Problem: Push Fails with Permission Denied

```
[ERROR] Failed to push image to Docker Hub
denied: requested access to the resource is denied
```

**Solution:**
- Verify you own the Docker Hub repository
- Verify you're logged in with the correct account
- Check if repository exists: `curl https://hub.docker.com/v2/repositories/your-username/repo-name`

### Problem: Git Clone Fails

```
[ERROR] Failed to clone repository
```

**Solution:**
```bash
# Test git clone manually
git clone https://github.com/<user>/<repo>.git /tmp/test
# If this fails, check:
# 1. Network connectivity
# 2. Repository URL is correct
# 3. Repository is public (private repos need SSH key)
```

### Problem: Disk Space Issues

```
no space left on device
```

**Solution:**
```bash
# Clean Docker images
docker image prune -a

# Clean Docker system
docker system prune

# Check disk space
df -h

# Remove large files if needed
du -sh /var/lib/docker
```

## Advanced Setup

### Running in Container

```bash
# Create a Dockerfile that includes builder.sh
docker run -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v ~/.docker/config.json:/.docker/config.json:ro \
  your-image:latest \
  ./builder.sh <repo> <docker-hub-repo>
```

### Running with CI/CD

```yaml
# GitHub Actions example
- name: Run builder script
  env:
    DOCKER_USERNAME: ${{ secrets.DOCKER_USERNAME }}
    DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
  run: |
    echo $DOCKER_TOKEN | docker login -u $DOCKER_USERNAME --password-stdin
    ./builder.sh $GITHUB_REPOSITORY_OWNER/repo-name ${{ secrets.DOCKER_USERNAME }}/repo-name
```

### Batch Processing

```bash
#!/bin/bash
# Process multiple repositories

REPOS=(
    "docker-library/hello-world:your-username/hello"
    "docker-library/nginx:your-username/nginx"
    "docker-library/node:your-username/node"
)

for repo_pair in "${REPOS[@]}"; do
    github_repo=$(echo "$repo_pair" | cut -d: -f1)
    docker_repo=$(echo "$repo_pair" | cut -d: -f2)
    
    echo "Building: $github_repo → $docker_repo"
    ./builder.sh "$github_repo" "$docker_repo"
    
    if [ $? -eq 0 ]; then
        echo "✓ $docker_repo pushed successfully"
    else
        echo "✗ Failed to build $docker_repo"
    fi
done
```

## Performance Notes

### Build Time Varies By:
- Repository size
- Dockerfile complexity
- Network speed
- Docker image layer caching

### Typical Execution Times:
- hello-world: 20-30 seconds
- Small app: 1-2 minutes
- Large app: 5-10 minutes

### Storage Space:
- Ensure 5+ GB free disk space
- Docker images can be large
- Clean up old images: `docker image prune -a`

## Next Steps

After successfully running the script:

1. **Verify on Docker Hub:**
   - Visit https://hub.docker.com/r/your-username
   - Confirm images are published

2. **Pull and Run the Image:**
   ```bash
   docker pull your-username/image-name:latest
   docker run your-username/image-name:latest
   ```

3. **Try Different Repositories:**
   ```bash
   # Try other public GitHub repositories
   ./builder.sh docker-library/nginx your-username/my-nginx
   ./builder.sh docker-library/postgres your-username/my-postgres
   ```

4. **Integrate with Your Projects:**
   - Use in CI/CD pipelines
   - Automate image builds for multiple repositories
   - Create custom build workflows

## Quick Reference

```bash
# Make executable
chmod +x builder.sh

# Login to Docker Hub
docker login

# Run the script
./builder.sh <github-repo> <docker-hub-repo>

# Examples
./builder.sh docker-library/hello-world your-username/hello
./builder.sh mluukkai/express_app your-username/express
./builder.sh docker-library/nginx your-username/nginx

# View built images
docker images | grep your-username

# View pushed images on Docker Hub
https://hub.docker.com/r/your-username

# Pull and run
docker pull your-username/image-name:latest
docker run your-username/image-name:latest
```

## Support

If you encounter issues:
1. Review the troubleshooting section above
2. Check the README.md for detailed documentation
3. Run with error redirection: `./builder.sh <repo> <docker-hub-repo> 2>&1 | tee output.log`
4. Review the ANSWER.txt for implementation details

Happy building! 🐳
