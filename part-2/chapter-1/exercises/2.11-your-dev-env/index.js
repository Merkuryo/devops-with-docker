const express = require('express');
const app = express();

const PORT = 3000;

// Middleware
app.use(express.json());

// Routes
app.get('/', (req, res) => {
  res.json({
    message: 'Welcome to Containerized Node.js Development! Hot-reload enabled!',
    version: '1.0.1',
    endpoints: {
      '/': 'This endpoint',
      '/api/hello': 'Hello message with name parameter',
      '/api/calculate': 'Simple calculator with a + b parameters',
      '/api/status': 'Get application status'
    }
  });
});

app.get('/api/hello', (req, res) => {
  const name = req.query.name || 'World';
  res.json({
    message: `Hello, ${name}!`,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/calculate', (req, res) => {
  const a = parseFloat(req.query.a) || 0;
  const b = parseFloat(req.query.b) || 0;
  
  res.json({
    operation: 'addition',
    a: a,
    b: b,
    result: a + b,
    timestamp: new Date().toISOString()
  });
});

app.get('/api/status', (req, res) => {
  res.json({
    status: 'running',
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
    timestamp: new Date().toISOString()
  });
});

app.post('/api/echo', (req, res) => {
  res.json({
    echo: req.body.message || 'No message provided',
    received_at: new Date().toISOString()
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: 'Not Found',
    path: req.path,
    message: 'Endpoint not found. Use GET / to see available endpoints.'
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({
    error: 'Internal Server Error',
    message: err.message
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'development'}`);
  console.log('Try accessing http://localhost:3000');
});
