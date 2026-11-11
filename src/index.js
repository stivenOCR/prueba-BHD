const app = require('./app');

const PORT = process.env.PORT || 3000;

const server = app.listen(PORT, () => {
  console.log(`[SERVER] DevOps Sample App running on port ${PORT}`);
  console.log(`[HEALTH] Healthcheck available at http://localhost:${PORT}/health`);
});

// Manejo elegante de apagado para contenedores Docker / K8s
process.on('SIGTERM', () => {
  console.log('[SHUTDOWN] SIGTERM received. Closing HTTP server gracefully...');
  server.close(() => {
    console.log('[SHUTDOWN] HTTP server closed.');
    process.exit(0);
  });
});

