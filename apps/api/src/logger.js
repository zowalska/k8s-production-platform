'use strict';

const pino = require('pino');
const config = require('./config');

// Structured JSON logging so Promtail (see monitoring/loki-logging) can parse
// and label logs by level/msg/time without a custom regex pipeline.
const logger = pino({
  level: config.logLevel,
  base: { service: config.serviceName, env: config.env },
  timestamp: pino.stdTimeFunctions.isoTime,
});

module.exports = logger;
