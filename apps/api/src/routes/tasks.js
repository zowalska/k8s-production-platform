'use strict';

const express = require('express');
const db = require('../db');
const { tasksQueue } = require('../queue');
const logger = require('../logger');

const router = express.Router();

// POST /tasks - persist a task record and enqueue it for asynchronous
// processing by the `worker` service via BullMQ (Redis-backed queue).
router.post('/tasks', async (req, res, next) => {
  try {
    const payload = req.body || {};
    const { rows } = await db.query(
      `INSERT INTO tasks (payload, status) VALUES ($1, 'pending')
       RETURNING id, payload, status, created_at`,
      [payload],
    );
    const task = rows[0];

    await tasksQueue.add('process-task', { taskId: task.id, payload });

    logger.info({ taskId: task.id }, 'task created and enqueued');
    res.status(201).json(task);
  } catch (err) {
    next(err);
  }
});

// GET /tasks - list the most recent tasks (bounded by `limit`, default 50).
router.get('/tasks', async (req, res, next) => {
  try {
    const limit = Math.min(parseInt(req.query.limit, 10) || 50, 200);
    const { rows } = await db.query(
      'SELECT id, payload, status, result, created_at, updated_at FROM tasks ORDER BY id DESC LIMIT $1',
      [limit],
    );
    res.status(200).json(rows);
  } catch (err) {
    next(err);
  }
});

// GET /tasks/:id - fetch a single task by id.
router.get('/tasks/:id', async (req, res, next) => {
  try {
    const { rows } = await db.query(
      'SELECT id, payload, status, result, created_at, updated_at FROM tasks WHERE id = $1',
      [req.params.id],
    );
    if (rows.length === 0) {
      return res.status(404).json({ error: 'task not found' });
    }
    return res.status(200).json(rows[0]);
  } catch (err) {
    return next(err);
  }
});

module.exports = router;
