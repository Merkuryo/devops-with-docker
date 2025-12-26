const express = require('express');
const app = express();

const PORT = process.env.PORT || 3000;

app.use(express.json());

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Cloud Deployment Pipeline Demo - Deployed to Render.com',
    version: '1.0.0',
    deployment: 'Automated with GitHub Actions',
    timestamp: new Date().toISOString(),
    environment: process.env.NODE_ENV || 'production'
  });
});

// API endpoints
app.get('/api/status', (req, res) => {
  res.json({
    status: 'healthy',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

app.get('/api/version', (req, res) => {
  res.json({
    version: '1.0.0',
    service: 'Cloud Deployment Demo',
    platform: 'Render.com'
  });
});

app.get('/api/info', (req, res) => {
  res.json({
    app: 'Cloud Deployment Pipeline',
    description: 'Automatically deployed to Render.com via GitHub Actions',
    features: [
      'GitHub Actions CI/CD pipeline',
      'Automatic deployment on push',
      'Zero-downtime updates',
      'Cloud-native deployment'
    ],
    deployment_method: 'GitHub Actions → Docker Hub → Render.com'
  });
});

// Health check endpoint (used by Render for monitoring)
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint not found' });
});

// Error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Internal server error' });
});

app.listen(PORT, () => {
  console.log(`Cloud deployment app listening on port ${PORT}`);
  console.log(`Environment: ${process.env.NODE_ENV || 'production'}`);
});
