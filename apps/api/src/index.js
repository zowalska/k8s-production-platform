'use strict';

const createApp = require('./app');
const config = require('./config');
const logger = require('./logger');
const db = require('./db');
const queue = require('./queue');

async function main() {
  await db.initSchema();

  const app = createApp();
  const server = app.listen(config.port, () => {
    logger.info({ port: config.port, env: config.env }, 'api service listening');
  });

  // Graceful shutdown: stop accepting new connections, then close the
  // database pool and redis connection so Kubernetes' SIGTERM during a
  // rolling update doesn't drop in-flight requests or leak connections.
  const shutdown = async (signal) => {
    logger.info({ signal }, 'shutting down');
    server.close(async () => {
      await queue.connection.quit().catch(() => {});
      await db.pool.end().catch(() => {});
      process.exit(0);
    });
    setTimeout(() => process.exit(1), 10_000).unref();
  };

  process.on('SIGTERM', () => shutdown('SIGTERM'));
  process.on('SIGINT', () => shutdown('SIGINT'));
}

main().catch((err) => {
  // eslint-disable-next-line no-console
  console.error('fatal startup error', err);
  process.exit(1);
});
