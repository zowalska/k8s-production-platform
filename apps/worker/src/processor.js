'use strict';

const db = require('./db');
const logger = require('./logger');

// The actual "business logic" for a task. Kept intentionally simple for a
// reference architecture: it simulates variable-length work and always
// succeeds unless the payload explicitly requests a failure (useful for
// exercising retry/backoff and the WorkerQueueBacklogHigh / job-failure
// alerting rules defined in monitoring/alerts/platform-rules.yaml).
async function processTask(job) {
  const { taskId, payload } = job.data;

  if (payload && payload.simulateFailure) {
    throw new Error('simulated task failure');
  }

  const workMs = (payload && payload.workMs) || Math.floor(Math.random() * 500) + 50;
  await new Promise((resolve) => setTimeout(resolve, workMs));

  const result = { processedAt: new Date().toISOString(), workMs };
  await db.markTaskStatus(taskId, 'completed', result);

  logger.info({ taskId, jobId: job.id }, 'task processed successfully');
  return result;
}

module.exports = processTask;
