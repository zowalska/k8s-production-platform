'use strict';

// Central place to read/validate runtime configuration from environment
// variables. In cluster, these are populated via the Helm chart's Deployment
// env section, sourced either from a ConfigMap (non-sensitive) or from the
// files injected by the Vault Agent sidecar (sensitive: DATABASE_URL,
// REDIS_URL, JWT_SECRET) - see security/vault/README.md.

const config = {
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000', 10),
  serviceName: 'api',
  databaseUrl:
    process.env.DATABASE_URL ||
    'postgres://platform:platform@localhost:5432/platform',
  redisUrl: process.env.REDIS_URL || 'redis://localhost:6379',
  queueName: process.env.QUEUE_NAME || 'platform-jobs',
  jwtSecret: process.env.JWT_SECRET || 'insecure-development-secret',
  logLevel: process.env.LOG_LEVEL || 'info',
};

module.exports = config;
