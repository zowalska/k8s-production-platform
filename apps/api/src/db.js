'use strict';

const { Pool } = require('pg');
const config = require('./config');
const logger = require('./logger');

const pool = new Pool({ connectionString: config.databaseUrl });

pool.on('error', (err) => {
  logger.error({ err }, 'unexpected postgres pool error');
});

async function initSchema() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS tasks (
      id SERIAL PRIMARY KEY,
      payload JSONB NOT NULL,
      status TEXT NOT NULL DEFAULT 'pending',
      result JSONB,
      created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
      updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
    );
  `);
  logger.info('database schema ensured');
}

async function ping() {
  await pool.query('SELECT 1');
}

module.exports = {
  pool,
  query: (text, params) => pool.query(text, params),
  initSchema,
  ping,
};
