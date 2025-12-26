# SETUP INSTRUCTIONS FOR EXERCISE 3.1

## Prerequisites

1. Docker Hub account - Create at https://hub.docker.com
2. GitHub account - Already have one
3. Git command line - Already installed
4. Docker and Docker Compose - Already installed

## Step 1: Create Docker Hub Access Token

1. Go to https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Give it a name: `github-actions`
4. Leave description blank (optional)
5. Copy the token - you'll need it next

## Step 2: Add GitHub Secrets

1. Open https://github.com/Merkuryo/devops-with-docker
2. Click "Settings" (top navigation)
3. In left sidebar, click "Secrets and variables" → "Actions"
4. Click "New repository secret"
5. Create two secrets:

**Secret 1: DOCKER_USERNAME**
- Name: `DOCKER_USERNAME`
- Value: Your Docker Hub username (e.g., `merkuryo`)

**Secret 2: DOCKER_PASSWORD**
- Name: `DOCKER_PASSWORD`
- Value: The access token you created in Step 1

## Step 3: Test Build Locally

Build and test the Docker image locally before pushing:

```bash
cd part-2/chapter-2/exercises/3.1-your-pipeline

# Build the image
docker build -t deployment-pipeline:test .

# Run it
docker run -p 3000:3000 deployment-pipeline:test

# Test in another terminal
curl http://localhost:3000/
```

You should see:
```json
{
  "message": "Deployment Pipeline Demo - Version 1.0",
  "status": "Running",
  "timestamp": "2025-12-26T...",
  ...
}
```

## Step 4: Push Code to Trigger GitHub Actions

```bash
cd /home/mercuryo/Docker/devops-with-docker

# Make sure all files are added
git status

# Stage all changes
git add -A

# Commit with meaningful message
git commit -m "Exercise 3.1: Initial deployment pipeline setup"

# Push to GitHub (this triggers the GitHub Actions workflow)
git push origin main
```

## Step 5: Monitor GitHub Actions Build

1. Go to: https://github.com/Merkuryo/devops-with-docker/actions
2. Click on the most recent workflow run
3. Watch the "build" job run:
   - Should see: "Build and push Docker image" step
   - Should complete successfully (green checkmark)
4. Check logs for errors if it fails

## Step 6: Verify Image on Docker Hub

1. Go to: https://hub.docker.com/r/YOUR_USERNAME/deployment-pipeline
   (Replace YOUR_USERNAME with your Docker Hub username)
2. Should see a new repository created
3. Click on "Tags" tab
4. Should see `latest` tag with a recent build date

## Step 7: Test with Docker Compose and Watchtower

```bash
cd part-2/chapter-2/exercises/3.1-your-pipeline

# Pull the latest image from Docker Hub
docker pull YOUR_USERNAME/deployment-pipeline:latest

# Start the app and Watchtower
docker compose up -d

# Check status
docker compose ps

# Test the app
curl http://localhost:3000/api/version

# View logs
docker compose logs app
docker compose logs watchtower
```

## Step 8: Test the Complete Pipeline

This is the key test - making a change and seeing it auto-deploy:

### 8.1: Make a Code Change

Edit `index.js` in the 3.1-your-pipeline directory:

Find this line (around line 11):
```javascript
    message: 'Deployment Pipeline Demo - Version 1.0',
```

Change it to:
```javascript
    message: 'Deployment Pipeline Demo - Version 1.1',
```

### 8.2: Commit and Push

```bash
cd /home/mercuryo/Docker/devops-with-docker

git add part-2/chapter-2/exercises/3.1-your-pipeline/index.js
git commit -m "Exercise 3.1: Update version to 1.1 to test pipeline"
git push origin main
```

### 8.3: Watch GitHub Actions Build

1. Go to https://github.com/Merkuryo/devops-with-docker/actions
2. Click the latest workflow
3. Watch it build and push the new image
4. It should complete in 1-3 minutes

### 8.4: Wait for Watchtower to Update

The Watchtower service (running in docker-compose) will:
1. Poll Docker Hub every 30 seconds
2. Detect the new image
3. Pull the new image
4. Stop the old container
5. Start a new container with the new image

This usually happens within 30 seconds after GitHub Actions completes.

### 8.5: Verify the Update

```bash
# Check the app response
curl http://localhost:3000/api/version

# Check logs to see if container restarted
docker compose logs app

# Should see something like:
# "Deployment Pipeline Demo - Version 1.1"
```

If you don't see the update immediately, wait up to 30 seconds for Watchtower to poll and update.

## Troubleshooting

### GitHub Actions Fails

**Error: Authentication failed**
- Check that DOCKER_USERNAME and DOCKER_PASSWORD secrets are set correctly
- Go to Settings → Secrets and verify both are there
- Test the token by logging in to Docker Hub locally:
  ```bash
  docker login -u YOUR_USERNAME
  # When prompted for password, use the access token
  ```

**Error: Push denied**
- Check that the repository path in build.yml matches your username
- Format should be: `YOUR_USERNAME/deployment-pipeline:latest`

### Docker Compose Issues

**Error: Cannot connect to Docker daemon**
```bash
# Make sure Docker is running
docker ps

# Start Docker Desktop if not running (macOS/Windows)
# Or check service status on Linux:
sudo systemctl status docker
```

**Port 3000 already in use**
```bash
# Kill the process using port 3000
lsof -ti:3000 | xargs kill -9

# Or change the port in docker-compose.yaml to 3001:3000
```

### Watchtower Not Updating

**Check Watchtower logs:**
```bash
docker logs watchtower
```

**Common issues:**
1. Docker socket not accessible: `ls -la /var/run/docker.sock`
2. Watchtower not monitoring the right container: Check docker-compose.yaml service name
3. Image not available on Docker Hub: Check your Docker Hub repository

**Fix: Restart Watchtower**
```bash
docker compose restart watchtower
```

## Summary of the Pipeline

```
Developer writes code
    ↓
git push origin main
    ↓
GitHub Actions workflow triggers
    ↓
Docker builds image
    ↓
Image pushed to Docker Hub as "latest"
    ↓
Watchtower detects new image (polls every 30 sec)
    ↓
Watchtower pulls new image
    ↓
Watchtower stops old container
    ↓
Watchtower starts new container
    ↓
Application is running with latest code
    ↓
No manual intervention needed!
```

## Next Steps After Verification

Once the pipeline is working:

1. Try making multiple changes and pushing them
2. Watch the complete flow work automatically
3. Check Docker Hub to see image history
4. Review GitHub Actions logs to understand timing
5. Consider adding image scanning or tests to the workflow

The key insight: Once setup, developers only need to push code. Everything else is automatic!
