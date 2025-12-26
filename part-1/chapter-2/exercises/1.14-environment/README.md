# Exercise 1.14 - Environment (Mandatory)

## Objective

Configure the frontend and backend applications to communicate with each other using environment variables. The frontend should be able to make requests to the backend, and when the button for Exercise 1.14 is pressed, it should turn green indicating successful communication.

## Project Details

- Frontend: React application served on port 5000
- Backend: Go application served on port 8080
- Communication: Frontend makes requests to backend via API calls

## Success Criteria

- Both frontend and backend containers run with correct ports
- Frontend has `REACT_APP_BACKEND_URL` configured to point to backend
- Backend has `REQUEST_ORIGIN` configured to allow requests from frontend
- The Exercise 1.14 button in the frontend turns green when clicked
- No code modifications are made to either project

## Key Concepts

### How It Works

1. Browser receives HTML/JavaScript from frontend container
2. Browser executes JavaScript code
3. When button for 1.14 is pressed, frontend sends request to backend
4. Backend responds with appropriate CORS headers
5. Button turns green on successful response

### Environment Variables

**Frontend (`example-frontend`):**
- `REACT_APP_BACKEND_URL` - URL where the backend is accessible from the browser
- Built at image build time with `npm run build`
- Must be set before build, not at runtime

**Backend (`example-backend`):**
- `REQUEST_ORIGIN` - URL to allow through CORS check
- Set at container runtime
- Allows the backend to accept requests from the specified origin

## Port Mapping

- Frontend: port 5000 (container) → port 5000 (host)
- Backend: port 8080 (container) → port 8080 (host)
- Frontend JavaScript accesses backend at: `http://localhost:8080`
