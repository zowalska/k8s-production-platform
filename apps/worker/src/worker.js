'use strict';

const { Worker, QueueEvents } = require('bullmq');
const config = require('./config');
const logger = require('./logger');
const db = require('./db');
const { connection } = require('./queue');
const { jobsProcessedTotal, jobDuration } = require('./metrics');
const processTask = require('./processor');

function createWorker() {
  const worker = new Worker(
    config.queueName,
    async (job) => {
      const stopTimer = jobDuration.startTimer({ queue: config.queueName });
      try {
        const result = await processTask(job);
        stopTimer();
        return result;
      } catch (err) {
        stopTimer();
        throw err;
      }
    },
    { connection, concurrency: config.concurrency },
  );

  worker.on('completed', (job) => {
    jobsProcessedTotal.inc({ queue: config.queueName, outcome: 'completed' });
    logger.info({ jobId: job.id }, 'job completed');
  });

  worker.on('failed', async (job, err) => {
    jobsProcessedTotal.inc({ queue: config.queueName, outcome: 'failed' });
    logger.error({ jobId: job?.id, err }, 'job failed');
    if (job?.data?.taskId) {
      await db.markTaskStatus(job.data.taskId, 'failed', { error: err.message }).catch(() => {});
    }
  });

  worker.on('error', (err) => {
    logger.error({ err }, 'worker connection error');
  });

  // QueueEvents lets us log lifecycle events independent of which process
  // (there may be several worker replicas) actually picked up the job.
  const queueEvents = new QueueEvents(config.queueName, { connection });
  queueEvents.on('stalled', ({ jobId }) => {
    logger.warn({ jobId }, 'job stalled and will be retried');
  });

  return { worker, queueEvents };
}

module.exports = createWorker;
