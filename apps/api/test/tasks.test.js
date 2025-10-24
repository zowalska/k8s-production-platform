'use strict';

jest.mock('../src/db', () => ({
  query: jest.fn(),
  ping: jest.fn().mockResolvedValue(),
  pool: { end: jest.fn() },
  initSchema: jest.fn().mockResolvedValue(),
}));

jest.mock('../src/queue', () => ({
  tasksQueue: { add: jest.fn().mockResolvedValue({}) },
  connection: { ping: jest.fn().mockResolvedValue('PONG'), quit: jest.fn() },
  ping: jest.fn().mockResolvedValue('PONG'),
}));

const request = require('supertest');
const createApp = require('../src/app');
const db = require('../src/db');
const { tasksQueue } = require('../src/queue');

describe('tasks routes', () => {
  let app;

  beforeEach(() => {
    jest.clearAllMocks();
    app = createApp();
  });

  test('POST /tasks creates a task and enqueues a job', async () => {
    db.query.mockResolvedValueOnce({
      rows: [{ id: 1, payload: { foo: 'bar' }, status: 'pending', created_at: new Date().toISOString() }],
    });

    const res = await request(app).post('/tasks').send({ foo: 'bar' });

    expect(res.status).toBe(201);
    expect(res.body.id).toBe(1);
    expect(res.body.status).toBe('pending');
    expect(tasksQueue.add).toHaveBeenCalledWith('process-task', { taskId: 1, payload: { foo: 'bar' } });
  });

  test('GET /tasks returns a list of tasks', async () => {
    db.query.mockResolvedValueOnce({
      rows: [{ id: 2, payload: {}, status: 'completed', result: { ok: true } }],
    });

    const res = await request(app).get('/tasks');

    expect(res.status).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    expect(res.body).toHaveLength(1);
  });

  test('GET /tasks/:id returns 404 when task is missing', async () => {
    db.query.mockResolvedValueOnce({ rows: [] });

    const res = await request(app).get('/tasks/999');

    expect(res.status).toBe(404);
  });

  test('GET /tasks/:id returns the task when found', async () => {
    db.query.mockResolvedValueOnce({ rows: [{ id: 3, payload: {}, status: 'pending' }] });

    const res = await request(app).get('/tasks/3');

    expect(res.status).toBe(200);
    expect(res.body.id).toBe(3);
  });
});
