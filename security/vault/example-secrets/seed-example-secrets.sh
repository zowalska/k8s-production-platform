#!/usr/bin/env bash
set -euo pipefail

: "${VAULT_ADDR:?Set VAULT_ADDR to the Vault address before running this script}"
: "${VAULT_TOKEN:?Set VAULT_TOKEN to a token allowed to write example secrets}"

# These are placeholder values for smoke tests only.
# In real environments, source them from Terraform outputs, a password generator, or another secure pipeline.
vault kv put secret/platform/dev/api \
  DATABASE_URL="postgresql://platform:dev-example-db-password@platform-postgresql.platform-dev.svc.cluster.local:5432/platform" \
  REDIS_URL="redis://:dev-example-redis-password@platform-redis-master.platform-dev.svc.cluster.local:6379/0" \
  JWT_SECRET="dev-example-jwt-secret"

vault kv put secret/platform/dev/worker \
  DATABASE_URL="postgresql://platform:dev-example-db-password@platform-postgresql.platform-dev.svc.cluster.local:5432/platform" \
  REDIS_URL="redis://:dev-example-redis-password@platform-redis-master.platform-dev.svc.cluster.local:6379/0" \
  JWT_SECRET="dev-example-worker-jwt-secret"

vault kv put secret/platform/staging/api \
  DATABASE_URL="postgresql://platform:staging-example-db-password@platform-postgresql.platform-staging.svc.cluster.local:5432/platform" \
  REDIS_URL="redis://:staging-example-redis-password@platform-redis-master.platform-staging.svc.cluster.local:6379/0" \
  JWT_SECRET="staging-example-jwt-secret"

vault kv put secret/platform/staging/worker \
  DATABASE_URL="postgresql://platform:staging-example-db-password@platform-postgresql.platform-staging.svc.cluster.local:5432/platform" \
  REDIS_URL="redis://:staging-example-redis-password@platform-redis-master.platform-staging.svc.cluster.local:6379/0" \
  JWT_SECRET="staging-example-worker-jwt-secret"

vault kv put secret/platform/prod/api \
  DATABASE_URL="postgresql://platform:prod-example-db-password@platform-postgresql.platform-prod.svc.cluster.local:5432/platform" \
  REDIS_URL="redis://:prod-example-redis-password@platform-redis-master.platform-prod.svc.cluster.local:6379/0" \
  JWT_SECRET="prod-example-jwt-secret"

vault kv put secret/platform/prod/worker \
  DATABASE_URL="postgresql://platform:prod-example-db-password@platform-postgresql.platform-prod.svc.cluster.local:5432/platform" \
  REDIS_URL="redis://:prod-example-redis-password@platform-redis-master.platform-prod.svc.cluster.local:6379/0" \
  JWT_SECRET="prod-example-worker-jwt-secret"

echo "Example KV-v2 secrets written to secret/platform/<env>/<service>."
