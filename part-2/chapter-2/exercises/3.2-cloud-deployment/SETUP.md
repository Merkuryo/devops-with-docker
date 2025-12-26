# SETUP GUIDE: EXERCISE 3.2 - CLOUD DEPLOYMENT PIPELINE

## Overview

This guide walks through setting up an automated deployment pipeline to Render.com. The pipeline automatically deploys your application whenever you push code to GitHub.

## Prerequisites

- GitHub account (already have)
- Docker Hub account (from Exercise 3.1)
- Render.com account (free tier)
- Git command line

## Step 1: Create Render.com Account and Service

### 1.1 Create Account

1. Go to https://render.com
2. Click "Get Started"
3. Sign up with GitHub (easiest option)
4. Authorize GitHub connection

### 1.2 Create Web Service

1. Go to Dashboard
2. Click "New +" → "Web Service"
3. Select "Deploy an existing image"
4. Enter Docker image: `YOUR_DOCKER_USERNAME/cloud-deployment:latest`
5. Configure:
   - Name: `cloud-deployment`
   - Environment: Docker
   - Region: Choose closest to you
   - Plan: Free (for testing)

6. Click "Create Web Service"

### 1.3 Wait for Initial Deployment

- Render will pull the image and start it
- Check the Logs tab to verify it's running
- You'll see: "App listening on port 3000"

## Step 2: Get Render Service Credentials

### 2.1 Get Service ID

1. On your service page, look at the URL
2. It looks like: `https://dashboard.render.com/web/srv-XXXXXXXXXXXXX`
3. Copy the service ID: `srv-XXXXXXXXXXXXX`

### 2.2 Create API Key

1. Click your profile icon (top right)
2. Go to "Account Settings"
3. Find "API Keys" section
4. Click "Create API Key"
5. Name it: `github-deployment`
6. Copy the key (save it, you won't see it again)

## Step 3: Add GitHub Secrets

### 3.1 Configure DOCKER_USERNAME and DOCKER_PASSWORD

(From Exercise 3.1, if not already done)

1. Go to https://github.com/Merkuryo/devops-with-docker
2. Click Settings → Secrets and variables → Actions
3. Create/verify these secrets:
   - **DOCKER_USERNAME**: Your Docker Hub username
   - **DOCKER_PASSWORD**: Your Docker Hub access token

### 3.2 Add Render Secrets

In the same GitHub Secrets page, create:

1. **RENDER_SERVICE_ID**
   - Value: `srv-XXXXXXXXXXXXX` (from Step 2.1)

2. **RENDER_API_KEY**
   - Value: Your API key (from Step 2.2)

All four secrets should now be configured.

## Step 4: Test Local Build

Before pushing to GitHub, verify the Docker image builds:

```bash
cd part-2/chapter-2/exercises/3.2-cloud-deployment

# Build image
docker build -t cloud-deployment:test .

# Run locally
docker run -p 3000:3000 cloud-deployment:test

# Test in another terminal
curl http://localhost:3000/api/status

# Should return:
# {"status":"healthy","uptime":...}
```

## Step 5: Verify Render Service

Before deploying, check your Render service is accessible:

```bash
# Replace with your actual Render URL
curl https://your-app-name.onrender.com/api/status

# Should return:
# {"status":"ok"}
```

If you don't know the URL:
1. Go to Render Dashboard
2. Click on your web service
3. URL is displayed at the top

## Step 6: First Deployment via GitHub Actions

### 6.1 Commit and Push

```bash
cd /home/mercuryo/Docker/devops-with-docker

# Make sure 3.2 is ready
git status

# Stage all files
git add part-2/chapter-2/exercises/3.2-cloud-deployment/

# Commit
git commit -m "Add exercise 3.2: Cloud deployment pipeline to Render.com"

# Push to GitHub
git push origin main
```

### 6.2 Monitor GitHub Actions

1. Go to https://github.com/Merkuryo/devops-with-docker/actions
2. Click the latest workflow
3. Watch steps:
   - ✓ Checkout repository
   - ✓ Set up Docker Buildx
   - ✓ Log in to Docker Hub
   - ✓ Build and push Docker image
   - ✓ Deploy to Render.com

Wait for all steps to complete (should be green).

### 6.3 Monitor Render Deployment

1. Go to your Render service dashboard
2. Click "Logs" tab
3. Watch for messages:
   - Image pull starts
   - Container stops
   - Container starts
   - "App listening on port 3000"
   - Service status becomes "Live"

## Step 7: Verify Deployment

### 7.1 Test Live Application

```bash
# Replace with your Render URL
curl https://your-app-name.onrender.com/

# Should return updated version with "Deployed to Render.com"
```

### 7.2 Test API Endpoints

```bash
# Status
curl https://your-app-name.onrender.com/api/status

# Version
curl https://your-app-name.onrender.com/api/version

# Info
curl https://your-app-name.onrender.com/api/info

# Health check
curl https://your-app-name.onrender.com/health
```

All should return 200 OK with JSON responses.

## Step 8: Test Complete Pipeline

Now test the full automated deployment:

### 8.1 Make a Code Change

Edit `index.js`:

Change:
```javascript
message: 'Cloud Deployment Pipeline Demo - Deployed to Render.com'
```

To:
```javascript
message: 'Cloud Deployment Pipeline Demo - Updated v1.1'
```

### 8.2 Commit and Push

```bash
cd /home/mercuryo/Docker/devops-with-docker

git add part-2/chapter-2/exercises/3.2-cloud-deployment/index.js
git commit -m "Test cloud deployment: Update version to 1.1"
git push origin main
```

### 8.3 Monitor Full Pipeline

1. **GitHub Actions**: Watch deployment workflow (1-2 minutes)
2. **Docker Hub**: Verify new image pushed with tag "latest"
3. **Render.com**: Monitor deployment logs
4. **Live App**: Test the updated endpoint

### 8.4 Verify Changes

```bash
# You should see the new message
curl https://your-app-name.onrender.com/

# Check version reflects update
curl https://your-app-name.onrender.com/api/version
```

## Complete Automated Pipeline

Timeline:
1. You push code to GitHub
2. GitHub Actions automatically builds Docker image (1-2 min)
3. Image is pushed to Docker Hub (30 sec)
4. Render.com API is called (1 sec)
5. Render.com pulls new image (30-60 sec)
6. Container restarts (5-10 sec)
7. Health checks pass (5-10 sec)
8. **Total: 2-3 minutes from push to live**

## Troubleshooting

### GitHub Actions Fails

**Check error in Actions tab**

Common issues:
- Docker Hub credentials wrong
- Missing secrets
- Render API key invalid

Fix:
1. Verify all 4 secrets are set correctly
2. Test Docker Hub login locally
3. Verify Render API key is valid

### Render Won't Deploy

**Check Render Logs**

1. Go to service dashboard
2. Click "Logs" tab
3. Look for error messages

Common issues:
- Image not found on Docker Hub
- Port mismatch
- Image architecture incompatible

Fix:
1. Verify image exists on Docker Hub
2. Check Docker Hub credentials
3. Verify correct image tag

### Application Not Responding

**Check service status**

1. Service should be "Live"
2. Check health endpoint: `/health`
3. Check application logs

### Can't Connect to Render App

Make sure:
- Service is deployed and "Live"
- Your public URL is correct
- No firewall blocking access
- App has started (check logs)

## Get Your Public URL

Your application is now accessible at:

```
https://YOUR_SERVICE_NAME.onrender.com
```

To find exact URL:
1. Go to Render dashboard
2. Click your web service
3. URL shown at top of page
4. Format: `https://SERVICENAME.onrender.com`

## Update README with Deployed Link

Edit your repository README to include your deployed app link:

```markdown
## Deployed Application

The application is deployed to Render.com at:
[https://YOUR_SERVICE_NAME.onrender.com](https://YOUR_SERVICE_NAME.onrender.com)

The deployment pipeline automatically updates the application whenever code is pushed to GitHub.
```

## Next Steps

Once working:

1. **Make Multiple Changes**: Push several updates to test repeatability
2. **Monitor Deployments**: Check GitHub Actions and Render logs
3. **Test Scalability**: Check if Render handles multiple requests
4. **Add Monitoring**: Enable Render metrics
5. **Custom Domain**: Add your own domain (requires paid plan)
6. **Upgrade Plan**: Move to paid tier for more resources

## Security Reminders

- Keep API keys secret (use GitHub secrets)
- Don't commit secrets to repository
- Rotate API keys periodically
- Limit API key permissions to minimum needed
- Use environment variables for sensitive data

## Success Indicators

Pipeline is working when:
1. ✓ GitHub Actions workflow completes successfully
2. ✓ Image appears on Docker Hub with "latest" tag
3. ✓ Render.com service shows "Live" status
4. ✓ Public URL responds with updated code
5. ✓ Code changes appear live within 2-3 minutes of push

Congratulations! You have a fully automated cloud deployment pipeline!
