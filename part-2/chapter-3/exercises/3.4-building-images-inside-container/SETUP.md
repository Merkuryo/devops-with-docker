# Exercise 3.4 Setup Guide

## Prerequisites

1. **Docker installed** and running
2. **docker.sock accessible** at `/var/run/docker.sock`
3. **Docker Hub account** with credentials or access token
4. **All files from Exercise 3.3** (builder.sh base script)

## Setup Steps

### Step 1: Verify docker.sock Exists

```bash
ls -la /var/run/docker.sock
# Should show: srw-rw---- 1 root docker
```

### Step 2: Build the Image

Navigate to exercise directory:
```bash
cd /path/to/3.4-building-images-inside-container
ls
# Should show: Dockerfile, builder.sh, README.md, SETUP.md
```

Build:
```bash
docker build -t builder .
```

Verify build:
```bash
docker images | grep builder
# Should show: builder  latest
```

### Step 3: Prepare Docker Hub Credentials

**Option A: Use Password**
```bash
DOCKER_USER="your_username"
DOCKER_PWD="your_password"
```

**Option B: Use Access Token (Recommended)**
1. Visit https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Select "Read, Write, Delete"
4. Copy token and use as password:
```bash
DOCKER_USER="your_username"
DOCKER_PWD="dckr_pat_xxxxx"
```

## Testing

### Test 1: Simple Test with Public Repo

```bash
docker run -e DOCKER_USER=your_username \
  -e DOCKER_PWD=your_access_token \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder docker-library/hello-world your_username/test-hello
```

Expected output:
```
...cloning...
...building...
...pushing...
Success: your_username/test-hello:latest pushed to Docker Hub
```

### Test 2: Verify on Docker Hub

Visit https://hub.docker.com/r/your_username/test-hello
Should see new repository with tags.

### Test 3: Error Handling

**Test missing environment variables:**
```bash
docker run -v /var/run/docker.sock:/var/run/docker.sock \
  builder docker-library/hello-world your_username/test
# Should fail or skip login
```

**Test missing docker.sock:**
```bash
docker run -e DOCKER_USER=user -e DOCKER_PWD=pwd \
  builder docker-library/hello-world your_username/test
# Should fail when trying to use docker commands
```

**Test invalid arguments:**
```bash
docker run -e DOCKER_USER=user -e DOCKER_PWD=pwd \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder
# Should show usage error
```

### Test 4: Real Application

```bash
docker run -e DOCKER_USER=your_username \
  -e DOCKER_PWD=your_access_token \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder mluukkai/express_app your_username/express-app
```

## Docker Socket Details

### Understanding the Mount

```bash
-v /var/run/docker.sock:/var/run/docker.sock
```

- **Host side:** `/var/run/docker.sock` = Host's Docker daemon socket
- **Container side:** `/var/run/docker.sock` = Same path inside container
- **Result:** Container can communicate with host's Docker daemon

### Inside Container

Commands like these work inside the container:
```bash
docker ps           # Lists containers on host
docker images       # Lists images on host
docker build        # Builds on host
docker push         # Pushes using host's Docker
```

### Security Implications

- Container has full Docker access (equivalent to `docker` user on host)
- Untrusted code running in container can:
  - Access all images
  - Run other containers
  - Stop running containers
  - Access host Docker daemon

## Environment Variables in Detail

### DOCKER_USER

Docker Hub username:
```bash
-e DOCKER_USER=your_username
```

### DOCKER_PWD

Docker Hub password or access token:
```bash
-e DOCKER_PWD=your_password
# or
-e DOCKER_PWD=dckr_pat_xxxxx
```

### Inside Script

Script uses variables:
```bash
if [ -n "$DOCKER_USER" ] && [ -n "$DOCKER_PWD" ]; then
    echo "$DOCKER_PWD" | docker login -u "$DOCKER_USER" --password-stdin
fi
```

- Checks if both variables are set
- Pipes password to `docker login` securely
- Uses `--password-stdin` to avoid exposing in process list

## File Permissions

Verify script is executable:
```bash
ls -la builder.sh
# Should show: -rwxr-xr-x
```

If not executable:
```bash
chmod +x builder.sh
```

## Production Considerations

### Don't Use Plain Passwords

```bash
# ❌ Bad
-e DOCKER_PWD=my_actual_password

# ✅ Good
-e DOCKER_PWD=dckr_pat_xxxxx  # Use access token
```

### Environment Files

Create `.env` file:
```bash
DOCKER_USER=your_username
DOCKER_PWD=dckr_pat_xxxxx
```

Use with docker run:
```bash
docker run --env-file .env \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder repo docker_repo
```

### Docker Secrets (Swarm Mode)

For production clusters:
```bash
docker secret create docker_user -
docker secret create docker_pwd -
```

Then in Compose:
```yaml
services:
  builder:
    image: builder
    secrets:
      - docker_user
      - docker_pwd
```

## Troubleshooting

### Problem: docker.sock Permission Denied

```
permission denied while trying to connect to Docker daemon socket
```

**Solution 1:** Run with sudo
```bash
sudo docker run -v /var/run/docker.sock:/var/run/docker.sock ...
```

**Solution 2:** Add user to docker group
```bash
sudo usermod -aG docker $USER
# Log out and log back in
```

### Problem: Login Failed

```
Error response from daemon: invalid username/password
```

**Solution:**
- Verify credentials are correct
- Verify Docker Hub account still active
- If using token, verify token still valid
- Try logging in manually: `docker login`

### Problem: Image Build Fails

```
docker: command not found
```

**Solution:**
- Verify docker.sock mounted: `-v /var/run/docker.sock:/var/run/docker.sock`
- Verify path is `/var/run/docker.sock` (not `/var/run/docker`)

### Problem: Repository Clone Fails

```
fatal: unable to access 'https://github.com/user/repo.git/'
```

**Solution:**
- Verify repository URL is correct (user/repo format)
- Verify repository is public
- Check network connectivity in container

### Problem: Dockerfile Not Found

```
Dockerfile not found in repository root
```

**Solution:**
- Verify repository has Dockerfile in root directory
- Repository must match exactly: `/Dockerfile` (not in subdirectory)

## Quick Reference

### Build Image
```bash
cd exercise_directory
docker build -t builder .
```

### Run Script
```bash
docker run \
  -e DOCKER_USER=username \
  -e DOCKER_PWD=token \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder github_repo docker_repo
```

### Examples
```bash
# Hello World
docker run -e DOCKER_USER=user -e DOCKER_PWD=pwd \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder docker-library/hello-world user/hello

# Express App
docker run -e DOCKER_USER=user -e DOCKER_PWD=pwd \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder mluukkai/express_app user/express

# Your Own Repo
docker run -e DOCKER_USER=user -e DOCKER_PWD=pwd \
  -v /var/run/docker.sock:/var/run/docker.sock \
  builder Merkuryo/node-api user/my-api
```

## Next Steps

1. Build and test the image locally
2. Verify Docker Hub credentials work
3. Test with different repositories
4. Understand docker.sock security implications
5. Explore CI/CD integration possibilities

## Support

For issues:
1. Review troubleshooting section
2. Check Docker logs: `docker logs container_id`
3. Test docker.sock mount: `docker run -v /var/run/docker.sock:/var/run/docker.sock ubuntu docker ps`
4. Verify Docker Hub access: `docker login`
