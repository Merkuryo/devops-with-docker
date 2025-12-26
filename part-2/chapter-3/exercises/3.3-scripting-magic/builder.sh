#!/bin/bash

# Docker Builder Script
# Purpose: Clone a GitHub repository, build Docker image, and push to Docker Hub
# Usage: ./builder.sh <github_repo> <docker_hub_repo>
# Example: ./builder.sh mluukkai/express_app mluukkai/testing

set -e  # Exit on any error

# Color output for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Check if arguments are provided
if [ $# -ne 2 ]; then
    print_error "Invalid number of arguments"
    echo "Usage: $0 <github_repo> <docker_hub_repo>"
    echo "Example: $0 mluukkai/express_app mluukkai/testing"
    exit 1
fi

GITHUB_REPO=$1
DOCKER_HUB_REPO=$2

# Validate argument format (must contain /)
if [[ ! "$GITHUB_REPO" =~ "/" ]] || [[ ! "$DOCKER_HUB_REPO" =~ "/" ]]; then
    print_error "Repository format must be 'username/repo'"
    exit 1
fi

# Extract repository name for directory
REPO_NAME=$(echo "$GITHUB_REPO" | cut -d'/' -f2)
TEMP_DIR="/tmp/docker_builder_$$"

print_info "Starting Docker Builder Script"
print_info "GitHub Repository: $GITHUB_REPO"
print_info "Docker Hub Repository: $DOCKER_HUB_REPO"

# Create temporary directory
print_info "Creating temporary directory: $TEMP_DIR"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Clone GitHub repository
print_info "Cloning GitHub repository..."
if git clone "https://github.com/$GITHUB_REPO.git" . 2>/dev/null; then
    print_success "Repository cloned successfully"
else
    print_error "Failed to clone repository"
    print_error "Make sure the repository exists: https://github.com/$GITHUB_REPO"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Check if Dockerfile exists
if [ ! -f Dockerfile ]; then
    print_error "Dockerfile not found in repository root"
    rm -rf "$TEMP_DIR"
    exit 1
fi

print_success "Dockerfile found"

# Build Docker image
print_info "Building Docker image: $DOCKER_HUB_REPO"
if docker build -t "$DOCKER_HUB_REPO:latest" .; then
    print_success "Docker image built successfully"
else
    print_error "Failed to build Docker image"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Check Docker Hub authentication
print_info "Checking Docker Hub authentication..."
if ! docker info | grep -q "Username"; then
    print_warning "Not logged in to Docker Hub"
    print_info "Please log in to Docker Hub:"
    print_info "  docker login"
    print_info "Then run the script again"
    rm -rf "$TEMP_DIR"
    exit 1
fi

print_success "Docker Hub authentication verified"

# Push image to Docker Hub
print_info "Pushing image to Docker Hub: $DOCKER_HUB_REPO:latest"
if docker push "$DOCKER_HUB_REPO:latest"; then
    print_success "Image pushed to Docker Hub successfully"
else
    print_error "Failed to push image to Docker Hub"
    print_warning "Make sure you have permission to push to $DOCKER_HUB_REPO"
    rm -rf "$TEMP_DIR"
    exit 1
fi

# Tag with additional timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
print_info "Creating timestamped tag: $DOCKER_HUB_REPO:$TIMESTAMP"
docker tag "$DOCKER_HUB_REPO:latest" "$DOCKER_HUB_REPO:$TIMESTAMP"
docker push "$DOCKER_HUB_REPO:$TIMESTAMP"

print_success "Timestamped image pushed: $DOCKER_HUB_REPO:$TIMESTAMP"

# Cleanup temporary directory
print_info "Cleaning up temporary directory"
cd /
rm -rf "$TEMP_DIR"

print_success "Docker Builder Script completed successfully!"
print_info "Image available at: https://hub.docker.com/r/$DOCKER_HUB_REPO"
print_info "Pull with: docker pull $DOCKER_HUB_REPO:latest"

exit 0
