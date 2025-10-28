'use strict';

const express = require('express');
const config = require('./config');
const logger = require('./logger');
const db = require('./db');
const queue = require('./queue');
const createWorker = require('./worker');
const { metricsHandler } = require('./metrics');
const { startPolling } = require('./metrics-poller');

async function main() {
  const app = express();
  app.get('/healthz', (_req, res) => res.status(200).json({ status: 'ok' }));
  app.get('/readyz', async (_req, res) => {
    try {
      await Promise.all([db.ping(), queue.ping()]);
      res.status(200).json({ status: 'ready' });
    } catch (err) {
      res.status(503).json({ status: 'not-ready', error: err.message });
    }
  });
  app.get('/metrics', metricsHandler);

  const server = app.listen(config.metricsPort, () => {
    logger.info({ port: config.metricsPort }, 'worker metrics/health server listening');
  });

  const { worker, queueEvents } = createWorker();
  logger.info({ queue: config.queueName, concurrency: config.concurrency }, 'worker started');

  const metricsPollTimer = startPolling();

  const shutdown = async (signal) => {
    logger.info({ signal }, 'shutting down worker');
    clearInterval(metricsPollTimer);
    await worker.close();
    await queueEvents.close();
    await queue.connection.quit().catch(() => {});
    await queue.queue.close().catch(() => {});
    await db.pool.end().catch(() => {});
    server.close(() => process.exit(0));
    setTimeout(() => process.exit(1), 10_000).unref();
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('fatal worker startup error', err);
  process.exit(1);
});
