const express = require('express');
const app = express();

const PORT = 3000;

app.use(express.json());

// Health check endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Deployment Pipeline Demo - Version 1.0',
    status: 'Running',
    timestamp: new Date().toISOString(),
    endpoints: {
      '/': 'This endpoint',
      '/api/version': 'Application version',
      '/api/info': 'Application information',
      '/health': 'Health check'
    }
  });
});

// Version endpoint
app.get('/api/version', (req, res) => {
  res.json({
    version: '1.0.0',
    name: 'Deployment Pipeline Demo',
    environment: process.env.NODE_ENV || 'production'
  });
});

// Info endpoint
app.get('/api/info', (req, res) => {
  res.json({
    app: 'Deployment Pipeline Example',
    description: 'This app demonstrates GitHub Actions + Watchtower CI/CD pipeline',
    features: [
      'Automated builds with GitHub Actions',
      'Automatic image push to Docker Hub',
      'Automatic deployment with Watchtower',
      'Zero-downtime updates'
    ]
  });
});

// Health check
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`App listening on port ${PORT}`);
  console.log('Press Ctrl+C to stop');
});
