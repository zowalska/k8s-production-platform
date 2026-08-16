# Runbook: RedisDown

**Alert**: The Redis exporter target is unreachable. Source:
`monitoring/alerts/platform-rules.yaml`.

## Impact
`api`'s `/readyz` fails (it checks Redis connectivity via `queue.ping()`).
`worker` cannot pick up new jobs, and any in-flight BullMQ state (delayed
jobs, retry backoff timers) is at risk if Redis data isn't durable/persisted.
KEDA (prod) also loses its scaling signal for `worker` since its trigger
reads the same Redis list.

## Investigation
- **dev/staging** (in-cluster Bitnami subchart or, staging, ElastiCache):
  ```sh
  kubectl -n platform-<env> get pods -l app.kubernetes.io/name=redis
  kubectl -n platform-<env> logs <redis-pod>
  ```
- **prod** (ElastiCache): check the replication group status in the AWS
  console/CLI, and whether a failover to the replica is in progress -
  `terraform/modules/elasticache` provisions Redis with
  encryption in transit/at rest and an auth token stored in Secrets Manager;
  confirm the auth token Vault has cached (`secret/data/platform/prod/*`)
  still matches if it was ever rotated (see
  `docs/runbooks/rotating-vault-secrets.md`).

## Mitigation
- Restart/reschedule the pod (dev) or let ElastiCache's automatic failover
  complete (staging/prod).
- If KEDA stops scaling `worker` as a side effect, it will resume once
  Redis is reachable again - no manual KEDA intervention needed.
- Confirm BullMQ jobs weren't silently dropped: compare
  `worker_queue_jobs{state="waiting"}` before/after the outage against the
  `tasks` table's `status='pending'` count in Postgres.

## Escalation
Page immediately for `prod` - this affects both request readiness and all
asynchronous processing.
