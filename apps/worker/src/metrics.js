'use strict';

const client = require('prom-client');

const register = new client.Registry();
client.collectDefaultMetrics({ register, prefix: 'worker_' });

const jobsProcessedTotal = new client.Counter({
  name: 'worker_jobs_processed_total',
  help: 'Total number of jobs processed, labeled by outcome',
  labelNames: ['queue', 'outcome'],
  registers: [register],
});

const jobDuration = new client.Histogram({
  name: 'worker_job_duration_seconds',
  help: 'Duration of job processing in seconds',
  labelNames: ['queue'],
  buckets: [0.05, 0.1, 0.5, 1, 2, 5, 10, 30],
  registers: [register],
});

// Gauges mirroring BullMQ's own queue counts so Grafana/KEDA can reason about
// backlog without querying Redis directly from a dashboard.
const queueDepthGauge = new client.Gauge({
  name: 'worker_queue_jobs',
  help: 'Current number of jobs in the queue by state',
  labelNames: ['queue', 'state'],
  registers: [register],
});

async function metricsHandler(_req, res) {
  res.setHeader('Content-Type', register.contentType);
  res.end(await register.metrics());
}

module.exports = { register, jobsProcessedTotal, jobDuration, queueDepthGauge, metricsHandler };
