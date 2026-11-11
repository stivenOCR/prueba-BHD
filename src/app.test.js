const request = require('supertest');
const app = require('./app');

describe('DevOps Sample App - API Endpoints', () => {
  test('GET / should return 200 and success message', async () => {
    const res = await request(app).get('/');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('success');
    expect(res.body.message).toContain('DevOps Assessment API');
  });

  test('GET /health should return 200 with UP status for Kubernetes probes', async () => {
    const res = await request(app).get('/health');
    expect(res.statusCode).toBe(200);
    expect(res.body.status).toBe('UP');
    expect(res.body).toHaveProperty('uptime');
  });

  test('GET /api/info should return application metadata', async () => {
    const res = await request(app).get('/api/info');
    expect(res.statusCode).toBe(200);
    expect(res.body.app).toBe('devops-sample-app');
    expect(res.body.version).toBe('1.0.0');
  });
});

