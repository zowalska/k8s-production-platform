'use strict';

// See apps/api/src/config.js for the equivalent on the API side - both
// services read the same DATABASE_URL / REDIS_URL / QUEUE_NAME so they agree
// on which Postgres database and Redis-backed queue to use.
const config = {
  env: process.env.NODE_ENV || 'development',
  serviceName: 'worker',
  metricsPort: parseInt(process.env.METRICS_PORT || '3001', 10),
  databaseUrl:
    process.env.DATABASE_URL ||
    'postgres://platform:platform@localhost:5432/platform',
  redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
  queueName: process.env.QUEUE_NAME || 'platform-jobs',
  concurrency: parseInt(process.env.WORKER_CONCURRENCY || '5', 10),
  logLevel: process.env.LOG_LEVEL || 'info',
};

module.exports = config;
