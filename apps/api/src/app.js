'use strict';

const express = require('express');
const helmet = require('helmet');
const cors = require('cors');
const pinoHttp = require('pino-http');
const logger = require('./logger');
const { metricsMiddleware, metricsHandler } = require('./metrics');
const healthRoutes = require('./routes/health');
const tasksRoutes = require('./routes/tasks');

function createApp() {
  const app = express();

  app.disable('x-powered-by');
  app.use(helmet());
  app.use(cors());
  app.use(express.json({ limit: '1mb' }));
  app.use(pinoHttp({ logger }));
  app.use(metricsMiddleware);

  app.use(healthRoutes);
  app.get('/metrics', metricsHandler);

  // tasksRoutes already declares its own "/tasks" and "/tasks/:id" paths, so
  // it's mounted at root. It's also exposed under "/api" for consumers that
  // prefix all calls that way - both resolve to the same router instance.
  app.use(tasksRoutes);
  app.use('/api', tasksRoutes);

  app.use((_req, res) => {
    res.status(404).json({ error: 'not found' });
  });

  // eslint-disable-next-line no-unused-vars
  app.use((err, req, res, _next) => {
    req.log?.error({ err }, 'unhandled error');
    res.status(err.status || 500).json({ error: err.message || 'internal server error' });
  });

  return app;
}

module.exports = createApp;
