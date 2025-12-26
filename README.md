# DevOps with Docker - Completed Exercises

Repository containing solutions to exercises from the University of Helsinki's DevOps with Docker course.

## Completed Exercises

### Part 1: Docker Basics

#### Chapter 2: Docker Basics

- **1.1 Getting Started** ✓ - Starting and managing containers in detached mode
- **1.2 Cleanup** ✓ - Removing all containers and images
- **1.3 Secret Message** ✓ - Accessing running containers with docker exec
- **1.4 Missing Dependencies** ✓ - Installing packages inside a running container
- **1.5 Sizes of Images** ✓ - Comparing Ubuntu and Alpine image sizes
- **1.6 Hello Docker Hub** ✓ - Finding documentation on Docker Hub
- **1.7 Image for Script** ✓ - Building a custom Docker image with Dockerfile
- **1.8 Two Line Dockerfile** ✓ - Using ENTRYPOINT with default CMD arguments
- **1.9 Volumes** ✓ - Using bind mounts to access container files from host
- **1.10 Ports Open** ✓ - Exposing web services using port mapping
- **1.11 Spring** ✓ - Containerizing a Java Spring application
- **1.12 Hello Frontend** ✓ (Mandatory) - Containerizing a React frontend application
- **1.13 Hello Backend** ✓ (Mandatory) - Containerizing a Go backend application
- **1.14 Environment** ✓ (Mandatory) - Configuring frontend-backend communication with environment variables
- **1.15 Homework** ✓ (Mandatory) - Publishing a custom application to Docker Hub
- **1.16 Cloud Deployment** ✓ - Deploying a containerized application to cloud provider (Render.com)

### Part 2: Docker Compose

#### Chapter 1: Docker Compose Basics

- **2.1 Simple Service Writing to Log** ✓ - Docker Compose with volume binding for logs
- **2.2 Simple Service with Browser** ✓ - Docker Compose with port mapping for web service
- **2.3 Project with Compose** ✓ (Mandatory) - Docker Compose with frontend and backend
- **2.4 Redis** ✓ (Mandatory) - Docker Compose with Redis caching layer
- **2.5 Scale** ✓ - Docker Compose service scaling with multiple replicas
- **2.6 PostgreSQL** ✓ - Docker Compose with PostgreSQL database integration
- **2.7 Bind Mount** ✓ - Using bind mounts for persistent data storage
- **2.8 Reverse Proxy** ✓ - Nginx reverse proxy configuration for multi-service routing
- **2.9 Fixup** ✓ - CORS header fixes and proxy configuration refinement
- **2.10 Close Ports** ✓ - Port closure and security (only expose entry point)
- **2.11 Your Dev Env** ✓ (Mandatory) - Containerized Node.js development environment with hot-reload

#### Chapter 2: Security and Optimization

- **3.1 Your Pipeline** ✓ (Mandatory) - GitHub Actions and Watchtower CI/CD deployment pipeline
- **3.2 Cloud Deployment** ✓ (Mandatory) - Automated deployment pipeline to Render.com cloud service

## Statistics

- **Total Exercises Completed:** 29/29
  - Part 1: 16/16 exercises ✓
  - Part 2, Chapter 1: 11/11 exercises ✓
  - Part 2, Chapter 2: 2/2 exercises ✓

- **Technologies Mastered:**
  - Docker containers and images
  - Docker Compose orchestration
  - Volume management (managed volumes, bind mounts, named volumes)
  - Port mapping and network configuration
  - Environment variables and service communication
  - Reverse proxy (Nginx)
  - Database integration (PostgreSQL)
  - Caching layers (Redis)
  - Containerized development environments with hot-reload
  - Cloud deployment (Render.com)
  - CI/CD pipelines with GitHub Actions
  - Automated image building and pushing
  - Automatic container updates with Watchtower

## Repository Structure

```
.
├── README.md
├── part-1/
│   └── chapter-2/
│       └── exercises/
│           ├── 1.1-getting-started/
│           ├── 1.2-cleanup/
│           ├── 1.3-secret-message/
│           ├── 1.4-missing-dependencies/
│           ├── 1.5-sizes-of-images/
│           ├── 1.6-hello-docker-hub/
│           ├── 1.7-image-for-script/
│           ├── 1.8-two-line-dockerfile/
│           ├── 1.9-volumes/
│           ├── 1.10-ports-open/
│           ├── 1.11-spring/
│           ├── 1.12-hello-frontend/
│           ├── 1.13-hello-backend/
│           ├── 1.14-environment/
│           ├── 1.15-homework/
│           └── 1.16-cloud-deployment/
└── part-2/
    ├── chapter-1/
    │   └── exercises/
    │       ├── 2.1-simple-service/
    │       ├── 2.2-service-with-browser/
    │       ├── 2.3-project-with-compose/
    │       ├── 2.4-redis/
    │       ├── 2.5-scale/
    │       ├── 2.6-postgres/
    │       ├── 2.7-bind-mount/
    │       ├── 2.8-reverse-proxy/
    │       ├── 2.9-fixup/
    │       ├── 2.10-close-ports/
    │       └── 2.11-your-dev-env/
    └── chapter-2/
        └── exercises/
            ├── 3.1-your-pipeline/
            └── 3.2-cloud-deployment/
```

## About This Course

The DevOps with Docker course from the University of Helsinki covers containerization using Docker, orchestration, and modern DevOps practices. This repository documents the complete journey through the course with working implementations of all exercises.

**Key Learning Outcomes:**
- Understanding container architecture and lifecycle
- Building and optimizing Docker images
- Multi-container orchestration with Docker Compose
- Volume management strategies for data persistence
- Network configuration and service communication
- Development environment containerization
- Infrastructure as code principles
- CI/CD automation and deployment pipelines
- Container security and optimization best practices

- **Official Course:** https://docker-esa.dev/
- **Docker Documentation:** https://docs.docker.com/
- **GitHub Repository:** https://github.com/Merkuryo/devops-with-docker
