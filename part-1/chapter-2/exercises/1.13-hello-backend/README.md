# Exercise 1.13 - Hello Backend (Mandatory)

## Objective

Create a Dockerfile for the example-backend project from the course repository that runs the backend application in a Docker container with port 8080 published.

## Project Details

The example-backend is a Go-based backend application that provides REST API endpoints.

Project location: https://github.com/docker-hy/material-applications/tree/main/example-backend

## Success Criteria

- The Dockerfile builds successfully
- The container runs with port 8080 exposed and published
- The `/ping` endpoint responds with "pong" when accessed at http://localhost:8080/ping
- No code modifications are made to the project

## Key Information from README

1. **Language**: Go 1.16
2. **Build Process**: `go build` generates a binary named "server"
3. **Execution**: Run the binary `./server`
4. **Default Port**: 8080 (can be customized with PORT environment variable)
5. **Endpoints**: `/ping` returns "pong" as a health check
