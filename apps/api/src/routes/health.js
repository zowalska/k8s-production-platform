'use strict';

const express = require('express');
const db = require('../db');
const queue = require('../queue');

const router = express.Router();

// Liveness: process is up and the event loop is responsive. Must never
// depend on downstream services, or a Postgres/Redis blip would cause
// Kubernetes to kill and restart otherwise-healthy pods.
router.get('/healthz', (_req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Readiness: safe to receive traffic only when dependencies are reachable.
router.get('/readyz', async (_req, res) => {
  try {
    await Promise.all([db.ping(), queue.ping()]);
    res.status(200).json({ status: 'ready' });
  } catch (err) {
    res.status(503).json({ status: 'not-ready', error: err.message });
  }
});

module.exports = router;
