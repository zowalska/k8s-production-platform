'use strict';

const { Queue } = require('bullmq');
const IORedis = require('ioredis');
const config = require('./config');

// A single shared ioredis connection reused by the BullMQ queue. BullMQ
// requires `maxRetriesPerRequest: null` on connections it manages.
const connection = new IORedis(config.redisUrl, {
  maxRetriesPerRequest: null,
});

const tasksQueue = new Queue(config.queueName, { connection });

async function ping() {
  await connection.ping();
}

module.exports = { tasksQueue, connection, ping };
