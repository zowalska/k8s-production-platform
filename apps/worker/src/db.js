'use strict';

const { Pool } = require('pg');
const config = require('./config');
const logger = require('./logger');

const pool = new Pool({ connectionString: config.databaseUrl });

pool.on('error', (err) => {
  logger.error({ err }, 'unexpected postgres pool error');
});

async function markTaskStatus(taskId, status, result) {
  await pool.query(
    'UPDATE tasks SET status = $1, result = $2, updated_at = now() WHERE id = $3',
    [status, result || null, taskId],
  );
}

async function ping() {
  await pool.query('SELECT 1');
}

module.exports = { pool, markTaskStatus, ping };
