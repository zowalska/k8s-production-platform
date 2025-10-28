'use strict';

const { Queue } = require('bullmq');
const IORedis = require('ioredis');
const config = require('./config');

const connection = new IORedis(config.redisUrl, {
  maxRetriesPerRequest: null,
});

// Only used to poll aggregate job counts for Prometheus metrics (see
// metrics-poller.js) - actual job consumption happens via the BullMQ
// `Worker` in worker.js, which manages its own connection lifecycle.
const queue = new Queue(config.queueName, { connection });

async function ping() {
  await connection.ping();
}

module.exports = { connection, queue, ping };
