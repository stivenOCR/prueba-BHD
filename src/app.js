const express = require('express');

const app = express();
// Buena práctica de seguridad: ocultar cabecera que delata Express
app.disable('x-powered-by');

app.use(express.json());

// Endpoint principal
app.get('/', (req, res) => {
  res.status(200).json({
    status: 'success',
    message: 'DevOps Assessment API - Running Successfully',
    timestamp: new Date().toISOString()
  });
});

// Endpoint de salud requerido por Kubernetes (liveness & readiness probes)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    uptime: process.uptime(),
    timestamp: new Date().toISOString()
  });
});

// Endpoint informativo del sistema
app.get('/api/info', (req, res) => {
  res.status(200).json({
    app: 'devops-sample-app',
    version: '1.0.0',
    environment: process.env.NODE_ENV || 'development',
    nodeVersion: process.version
  });
});

module.exports = app;

