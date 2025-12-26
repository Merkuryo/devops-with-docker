# Exercise 2.3 - Project with Compose (Mandatory)

## Objective

Create a docker-compose.yaml file that starts both frontend and backend services with proper configuration, similar to Exercise 1.14.

## Project Details

- **Frontend:** React application on port 5000
- **Backend:** Go application on port 8080
- **Tool:** Docker Compose
- **Configuration:** Environment variables for cross-service communication

## Success Criteria

- docker-compose.yaml file created correctly
- Both frontend and backend services start with `docker compose up`
- Frontend and backend can communicate
- Exercise 1.14 button in frontend turns green when clicked
- Services start with proper dependencies

## Key Concepts

**Multi-container Setup with Docker Compose:**
- Multiple services defined in one file
- Port mapping for both services
- Environment variables for configuration
- Service dependencies with `depends_on`
- Simplified orchestration compared to manual docker commands

**Environment Variables:**
- `REACT_APP_BACKEND_URL` - Tells frontend where backend is
- `REQUEST_ORIGIN` - Tells backend to accept requests from frontend

**Service Dependencies:**
- `depends_on: - backend` ensures backend starts first
- Frontend can connect to backend once it's running

## Usage

```bash
# Start both services
docker compose up

# In another terminal, test the services
curl http://localhost:8080/ping
curl http://localhost:5000

# Stop both services
docker compose down
```

## Docker Compose YAML Syntax

```yaml
services:
  backend:
    image: backend-app
    build: ...
    ports: - 8080:8080
    environment:
      - REQUEST_ORIGIN=http://localhost:5000

  frontend:
    image: frontend-app
    build: ...
    ports: - 5000:5000
    environment:
      - REACT_APP_BACKEND_URL=http://localhost:8080
    depends_on: - backend
```

## Comparison to Traditional Commands

Instead of:
```bash
# Backend
docker run -p 8080:8080 -e REQUEST_ORIGIN=http://localhost:5000 backend-app

# Frontend
docker run -p 5000:5000 -e REACT_APP_BACKEND_URL=http://localhost:8080 frontend-app
```

Docker Compose:
```bash
docker compose up
```

Much simpler and more maintainable!
