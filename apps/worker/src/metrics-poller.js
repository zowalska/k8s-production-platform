'use strict';

const config = require('./config');
const logger = require('./logger');
const { queue } = require('./queue');
const { queueDepthGauge } = require('./metrics');

// The states BullMQ tracks per job and that the `worker_queue_jobs` gauge
// exposes - matches what monitoring/grafana/dashboards/worker-overview.json
// and the WorkerQueueBacklogHigh alert (monitoring/alerts/platform-rules.yaml)
// query.
const STATES = ['waiting', 'active', 'delayed', 'completed', 'failed'];

// prom-client can't observe BullMQ's Redis-backed queue depth on its own -
// it has to be polled and pushed into a Gauge periodically.
async function pollOnce() {
  const counts = await queue.getJobCounts(...STATES);
  STATES.forEach((state) => {
    queueDepthGauge.set({ queue: config.queueName, state }, counts[state] || 0);
  });
  return counts;
}

function startPolling(intervalMs = 10_000) {
  pollOnce().catch((err) => logger.warn({ err }, 'initial queue metrics poll failed'));
  const timer = setInterval(() => {
    pollOnce().catch((err) => logger.warn({ err }, 'queue metrics poll failed'));
  }, intervalMs);
  timer.unref();
  return timer;
}

module.exports = { pollOnce, startPolling, STATES };
