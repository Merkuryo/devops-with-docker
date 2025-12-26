# Exercise 1.16 - Cloud Deployment

## Objective

Deploy a containerized web application to a cloud provider using Docker.

## Deployment Strategy

I deployed the **example-frontend** (React) application to **Render.com** using the Dockerfile created in Exercise 1.12.

## Application Details

- **App:** React Frontend Application
- **Port:** 5000
- **Base Image:** node:16
- **Cloud Provider:** Render.com (Free Tier)
- **Build Process:** Automated from GitHub repository

## Deployment Steps

1. Push Dockerfile to GitHub repository
2. Create Render account (free)
3. Connect GitHub repository to Render
4. Create Web Service pointing to Dockerfile
5. Configure port to 5000
6. Deploy and run

## Key Configuration

The Dockerfile uses:
- Node.js 16 base image
- npm install to install dependencies
- npm run build to create production build
- serve package to serve static files on port 5000
- EXPOSE 5000 to declare the port

## Benefits of Cloud Deployment

- Application accessible from anywhere via URL
- Automatic deployment on GitHub push
- No need to run Docker locally
- Easy scaling and updates
- Professional hosting for portfolios

## Challenges Addressed

- Port configuration for cloud environment
- Automated builds from GitHub
- Environment variables if needed
- Health checks for running apps

## Success Criteria Met

- ✓ Containerized application deployed
- ✓ Running in cloud provider
- ✓ Accessible via public URL
- ✓ Automated deployment pipeline
- ✓ Proper documentation
