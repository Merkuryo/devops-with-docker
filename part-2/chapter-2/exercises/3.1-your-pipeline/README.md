# Exercise 3.1: Your Deployment Pipeline

## Overview

This exercise implements a complete CI/CD deployment pipeline using **GitHub Actions** for building and pushing Docker images, and **Watchtower** for automatic container updates.

The pipeline demonstrates:
- Automated Docker image building on every push to main
- Automatic image push to Docker Hub
- Automatic container updates without manual intervention
- Zero-downtime deployments

## Architecture

```
Developer Push
    ↓
GitHub Actions
    ↓
Build Docker Image
    ↓
Push to Docker Hub
    ↓
Watchtower (polling)
    ↓
Pull new image & restart container
    ↓
Application updated in production
```

## Components

### 1. GitHub Actions Workflow

**File:** `.github/workflows/build.yml`

The workflow triggers on every push to the `main` branch and:
1. Checks out the repository code
2. Sets up Docker Buildx for building
3. Logs in to Docker Hub using secrets
4. Builds the Docker image and pushes to Docker Hub with tag `latest`

**Workflow Steps:**
- `actions/checkout@v4` - Fetch code from repository
- `docker/setup-buildx-action@v3` - Initialize Docker builder
- `docker/login-action@v3` - Authenticate with Docker Hub
- `docker/build-push-action@v5` - Build and push image

### 2. Watchtower Service

**Configuration in docker-compose.yaml:**

```yaml
watchtower:
  image: containrrr/watchtower
  volumes:
    - /var/run/docker.sock:/var/run/docker.sock
  environment:
    - WATCHTOWER_POLL_INTERVAL=30  # Check for updates every 30 seconds
    - WATCHTOWER_CLEANUP=true      # Remove old images
```

**What Watchtower does:**
- Continuously polls Docker Hub for new image versions
- When a new image is found, pulls it
- Stops and removes the old container
- Starts a new container with the updated image
- All with zero downtime

### 3. Application

**Simple Express.js API with endpoints:**
- `GET /` - Welcome message
- `GET /api/version` - Version information
- `GET /api/info` - Application details
- `GET /health` - Health check

## Setup Instructions

### Prerequisites

1. **GitHub Account** - Already have one
2. **Docker Hub Account** - Create at https://hub.docker.com
3. **GitHub Repository** - The code is already in your devops-with-docker repo

### Configuration Steps

#### 1. Create Docker Hub Access Token

1. Go to https://hub.docker.com/settings/security
2. Click "New Access Token"
3. Name it: `github-actions`
4. Copy the token

#### 2. Add GitHub Secrets

1. Go to your repository on GitHub
2. Click Settings → Secrets and variables → Actions
3. Create two secrets:
   - **DOCKER_USERNAME**: Your Docker Hub username
   - **DOCKER_PASSWORD**: The access token you just created

#### 3. Update the Workflow

The workflow expects `${{ secrets.DOCKER_USERNAME }}` to be set. Make sure the secrets are configured correctly.

## How It Works

### Step 1: Developer Makes Changes

Edit `index.js`:
```javascript
message: 'Deployment Pipeline Demo - Version 1.1'
```

### Step 2: Commit and Push

```bash
git add .
git commit -m "Update version to 1.1"
git push origin main
```

### Step 3: GitHub Actions Builds Image

- The workflow is automatically triggered
- Image is built as `your-username/deployment-pipeline:latest`
- Image is pushed to Docker Hub

**Monitor at:** https://github.com/Merkuryo/devops-with-docker/actions

### Step 4: Watchtower Detects Update

- Watchtower polls Docker Hub every 30 seconds
- Detects new image version
- Pulls new image
- Stops old container
- Starts new container with new image

### Step 5: Verify Changes

```bash
curl http://localhost:3000/
```

The response should show your updated version without any manual restart.

## Running Locally

### Build and Run Manually

```bash
docker build -t deployment-pipeline .
docker run -p 3000:3000 deployment-pipeline
```

### Using Docker Compose

```bash
docker compose up -d
```

This starts both:
- The application on port 3000
- Watchtower for automatic updates

### Test the Application

```bash
# Welcome endpoint
curl http://localhost:3000/

# Version endpoint
curl http://localhost:3000/api/version

# Health check
curl http://localhost:3000/health
```

## Testing the Pipeline

1. Make a change to `index.js` (update the message)
2. Commit and push to GitHub
3. Watch the GitHub Actions run: https://github.com/Merkuryo/devops-with-docker/actions
4. Verify image appears in Docker Hub: https://hub.docker.com/r/your-username/deployment-pipeline
5. Wait for Watchtower to detect the update (up to 30 seconds)
6. Refresh your browser or run curl again to see the changes

## Security Considerations

⚠️ **Important Security Notes:**

1. **Docker Hub Access**: Anyone with Docker Hub credentials can deploy updates
2. **Watchtower Access**: Watchtower has Docker socket access, which is powerful
3. **Image Verification**: Always verify images before deployment in production
4. **Access Control**: Limit Docker Hub token permissions

### Production Recommendations

- Use separate credentials for CI/CD
- Implement image scanning (Trivy, Snyk)
- Use image signing and verification
- Deploy to staging environment first
- Implement rollback mechanisms
- Use specific image tags instead of `latest`
- Restrict Watchtower to specific containers using labels

## Workflow Files

### build.yml - GitHub Actions Workflow

Triggers on push to main:
1. Checks out code
2. Sets up Docker builder
3. Logs in to Docker Hub
4. Builds and pushes image with tag `latest`

### docker-compose.yaml

Runs two services:
1. **app**: The Express.js application
   - Port 3000 exposed
   - NODE_ENV=production

2. **watchtower**: Container update daemon
   - Monitors Docker socket
   - Polls every 30 seconds
   - Auto-restarts containers when images update

## Troubleshooting

### GitHub Actions Fails

1. Check if secrets are configured correctly
2. Verify Docker username and token
3. Check Actions tab for error messages

### Watchtower Not Updating

1. Verify Docker socket is mounted correctly
2. Check Watchtower logs: `docker logs watchtower`
3. Ensure image exists on Docker Hub
4. Verify container name matches in docker-compose

### Port Already in Use

```bash
# Find and kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Or use different port in docker-compose
```

## Technology Stack

- **Node.js 20 Alpine** - Lightweight base image
- **Express.js 4.18** - Web framework
- **GitHub Actions** - CI/CD automation
- **Docker Hub** - Image registry
- **Watchtower** - Automatic updates
- **Docker Compose** - Orchestration

## Course Integration

This exercise demonstrates:
- **CI/CD pipelines**: Automated testing and deployment
- **Container automation**: Zero-downtime updates
- **Image registry**: Docker Hub integration
- **DevOps practices**: Infrastructure as code, automation
- **Security**: Credentials management with GitHub secrets

## Next Steps

To extend this project:

1. Add image scanning (Snyk, Trivy)
2. Implement multi-stage builds
3. Add unit tests before building image
4. Use image tags based on git commits
5. Implement rollback mechanism
6. Deploy to cloud provider
7. Set up health checks
8. Add monitoring and alerting

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Build and Push Action](https://github.com/docker/build-push-action)
- [Watchtower Documentation](https://containrrr.dev/watchtower/)
- [Docker Hub API](https://docs.docker.com/docker-hub/api/latest/)
