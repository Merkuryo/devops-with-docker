# Exercise 1.12 - Hello Frontend (Mandatory)

## Objective

Create a Dockerfile for the example-frontend project from the course repository that runs the frontend application in a Docker container with port 5000 exposed and published.

## Project Details

The example-frontend is a React-based frontend application that serves static files.

Project location: https://github.com/docker-hy/material-applications/tree/main/example-frontend

## Success Criteria

- The Dockerfile builds successfully
- The container runs with port 5000 exposed and published
- Navigating to http://localhost:5000 displays the frontend application
- No code modifications are made to the project

## Key Information from README

1. **Prerequisites**: Node.js (LTS 16.x recommended)
2. **Build Process**: `npm install` followed by `npm run build`
3. **Serving**: Use the `serve` package to serve static files on port 5000
4. **Startup**: Application accepts connections when printed to screen
5. **Note**: May not work with newest Node.js versions (using 16.x)
