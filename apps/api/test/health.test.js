'use strict';

jest.mock('../src/db', () => ({
  query: jest.fn(),
  ping: jest.fn(),
  pool: { end: jest.fn() },
  initSchema: jest.fn().mockResolvedValue(),
}));

jest.mock('../src/queue', () => ({
  tasksQueue: { add: jest.fn() },
  connection: { ping: jest.fn(), quit: jest.fn() },
  ping: jest.fn(),
}));

const request = require('supertest');
const createApp = require('../src/app');
const db = require('../src/db');
const queue = require('../src/queue');

describe('health routes', () => {
  let app;

  beforeEach(() => {
    jest.clearAllMocks();
    app = createApp();
  });

  test('GET /healthz always returns 200', async () => {
    const res = await request(app).get('/healthz');
    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ok');
  });

  test('GET /readyz returns 200 when dependencies are reachable', async () => {
    db.ping.mockResolvedValueOnce();
    queue.ping.mockResolvedValueOnce('PONG');

    const res = await request(app).get('/readyz');

    expect(res.status).toBe(200);
    expect(res.body.status).toBe('ready');
  });

  test('GET /readyz returns 503 when a dependency is unreachable', async () => {
    db.ping.mockRejectedValueOnce(new Error('connection refused'));
    queue.ping.mockResolvedValueOnce('PONG');

    const res = await request(app).get('/readyz');

    expect(res.status).toBe(503);
    expect(res.body.status).toBe('not-ready');
  });

  test('GET /metrics exposes prometheus metrics', async () => {
    const res = await request(app).get('/metrics');
    expect(res.status).toBe(200);
    expect(res.text).toContain('api_http_requests_total');
  });
});
