# Exercise 3.2: Cloud Deployment Pipeline

## Overview

This exercise extends the deployment pipeline from Exercise 3.1 to automatically deploy to a cloud service (**Render.com**). Every push to GitHub triggers:

1. **Build** - Docker image is built
2. **Push** - Image is pushed to Docker Hub
3. **Deploy** - Application is automatically deployed to Render.com

## Deployed Application

**Live Application URL**: Will be provided after Render.com deployment setup

## Architecture

```
Developer Push to GitHub
    ↓
GitHub Actions Workflow Triggers
    ↓
Docker Build & Push to Docker Hub
    ↓
Render.com Deployment API Called
    ↓
Render.com Pulls New Image
    ↓
Zero-Downtime Deployment
    ↓
Live Application Updated
```

## Components

### 1. GitHub Actions Workflow

**File**: `.github/workflows/deploy.yml`

The workflow:
1. Checks out code from repository
2. Sets up Docker Buildx
3. Logs in to Docker Hub
4. Builds and pushes Docker image
5. Triggers Render.com deployment API

**Environment Variables Required**:
- `DOCKER_USERNAME` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub access token
- `RENDER_SERVICE_ID` - Render.com service ID
- `RENDER_API_KEY` - Render.com API key

### 2. Docker Configuration

**Dockerfile**: Minimal, production-ready Node.js image
- Base: `node:20-alpine`
- Multi-stage ready
- Optimized for cloud deployment

**docker-compose.yaml**: Local development
- Maps port 3000
- Production environment
- Auto-restart on failure

### 3. Express Application

Simple API with monitoring endpoints:
- `GET /` - Welcome message
- `GET /api/status` - Health status
- `GET /api/version` - Version info
- `GET /api/info` - Application details
- `GET /health` - Health check for Render

## Setup Instructions

### Step 1: Render.com Setup

1. **Create Render Account**: https://render.com
2. **Create Web Service**:
   - Connect GitHub repository
   - Select this project directory
   - Docker runtime
   - Set PORT to 3000

3. **Get Service ID**:
   - Go to service settings
   - Dashboard URL looks like: `https://dashboard.render.com/web/srv-xxxxx`
   - Note the service ID: `srv-xxxxx`

4. **Create API Key**:
   - Go to Account Settings → API Keys
   - Create new API key with deployment permissions
   - Save the key securely

### Step 2: GitHub Secrets Configuration

Add these secrets to GitHub repository:

1. `DOCKER_USERNAME` - Docker Hub username
2. `DOCKER_PASSWORD` - Docker Hub access token
3. `RENDER_SERVICE_ID` - Your Render service ID (srv-xxxxx)
4. `RENDER_API_KEY` - Your Render API key

**How to add secrets**:
1. Go to repository Settings
2. Navigate to Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret

### Step 3: Test the Pipeline

1. Make a code change (e.g., update welcome message in index.js)
2. Commit and push to GitHub:
   ```bash
   git add .
   git commit -m "Update version to test cloud deployment"
   git push origin main
   ```

3. Watch GitHub Actions:
   - Go to https://github.com/YOUR_USERNAME/devops-with-docker/actions
   - Watch the deployment workflow run

4. Verify on Render.com:
   - Check your service dashboard
   - Verify deployment completed
   - Test the live URL

5. Confirm Changes:
   - Visit your Render.com application URL
   - Verify the updated message appears

## How It Works

### Automatic Deployment Process

1. **Developer Push**: Code is pushed to GitHub main branch
2. **Workflow Trigger**: GitHub Actions workflow automatically starts
3. **Docker Build**: Image is built with updated code
4. **Push to Registry**: Image is pushed to Docker Hub
5. **API Call**: Render.com deployment API is called with service ID
6. **Container Restart**: Render.com pulls new image and restarts service
7. **Live Update**: Changes are live within seconds

### Complete Timeline

- Code push: 0 seconds
- GitHub Actions build: 1-2 minutes
- Render.com deployment: 30 seconds - 1 minute
- **Total: 2-3 minutes from push to live**

## Render.com Features

**Advantages**:
- ✅ Free tier available
- ✅ Automatic HTTPS
- ✅ Built-in health checks
- ✅ Simple GitHub integration
- ✅ No credit card required for free tier

**Deployment API**:
- Uses curl to trigger deployment
- No polling needed (unlike Watchtower)
- Immediate response from API
- Render.com handles container restart

## Monitoring Deployments

### GitHub Actions
Monitor build progress at:
```
https://github.com/YOUR_USERNAME/devops-with-docker/actions
```

### Render.com
Monitor deployment at:
```
https://dashboard.render.com/web/srv-YOUR_SERVICE_ID
```

### Application Health
Test deployed application:
```bash
curl https://your-app-name.onrender.com/api/status
```

## Troubleshooting

### GitHub Actions Fails

**Error: Authentication failed**
- Verify Docker Hub secrets are correct
- Test credentials locally: `docker login`

**Error: Can't find Render API**
- Verify RENDER_SERVICE_ID format (should be srv-xxxxx)
- Check RENDER_API_KEY is valid
- Confirm API key has deployment permissions

### Render.com Won't Deploy

**Check Render logs**:
1. Go to service dashboard
2. Click "Logs" tab
3. Look for error messages

**Common issues**:
- Docker image not found on Docker Hub
- Port mismatch (should use 3000)
- Environment variables not set
- Memory/CPU limits exceeded

### Application Not Responding

1. Check Render service status (should be "Live")
2. Check health endpoint: `/health`
3. Check application logs in Render dashboard
4. Verify Docker image builds locally

## Differences from Exercise 3.1

| Feature | 3.1 (Local) | 3.2 (Cloud) |
|---------|------------|-----------|
| Deployment Target | Local machine | Cloud (Render.com) |
| Auto-Update Mechanism | Watchtower polling | Render API call |
| Zero Downtime | Yes (Watchtower) | Yes (Render blue-green) |
| Manual Intervention | None | Initial setup only |
| Public URL | localhost:3000 | https://app.onrender.com |
| Cost | Free | Free (with Render free tier) |
| Scalability | Single machine | Auto-scale ready |

## Production Considerations

For production deployment:

1. **Image Scanning** - Add security scanning before deployment
2. **Environment Variables** - Use Render.com environment variables for secrets
3. **Database** - Add Render Postgres if needed
4. **Monitoring** - Integrate monitoring service
5. **Logging** - Centralize logs (Loggly, Papertrail, etc.)
6. **Custom Domain** - Use custom domain on Render.com
7. **SSL/TLS** - Render provides automatic HTTPS
8. **Backups** - Configure backup strategy for databases

## Technology Stack

- **Node.js 20** - Runtime
- **Express.js** - Web framework
- **Docker** - Containerization
- **GitHub Actions** - CI/CD automation
- **Docker Hub** - Image registry
- **Render.com** - Cloud platform

## Course Integration

This exercise completes the DevOps cycle:

- **Part 1**: Understand containers
- **Part 2.1**: Orchestrate with Compose
- **Part 2.2.1**: Automate deployment locally (Exercise 3.1)
- **Part 2.2.2**: Deploy to production (Exercise 3.2) ← **This exercise**

## Next Steps

To enhance this pipeline:

1. Add integration tests before deployment
2. Implement staging environment
3. Add automatic rollback on health check failure
4. Implement database migrations
5. Add monitoring and alerting
6. Use semantic versioning for images
7. Implement approval workflows for production

## References

- [Render.com Documentation](https://render.com/docs)
- [Render Deployment API](https://render.com/docs/deploy-hook)
- [GitHub Actions Docs](https://docs.github.com/en/actions)
- [Docker Hub Integration](https://docs.docker.com/docker-hub/)
