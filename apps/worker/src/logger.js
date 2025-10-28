'use strict';

const pino = require('pino');
const config = require('./config');

const logger = pino({
  level: config.logLevel,
  base: { service: config.serviceName, env: config.env },
  timestamp: pino.stdTimeFunctions.isoTime,
});

module.exports = logger;
