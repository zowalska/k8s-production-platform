# Runbook: WorkerQueueBacklogHigh

**Alert**: The number of waiting jobs in the `platform-jobs` BullMQ queue
(Redis) has stayed above threshold for a sustained period. Source:
`monitoring/alerts/platform-rules.yaml`.

## Likely causes
- `worker` is under-provisioned for current job arrival rate.
- KEDA (prod) or the CPU-based HPA (dev/staging) isn't scaling `worker` up -
  check `kubectl get scaledobject,hpa -n platform-<env>`.
- A downstream dependency `worker` depends on (Postgres) is slow, so each
  job takes longer than expected, reducing effective throughput.
- A poison-pill job is stuck retrying repeatedly (check `worker_jobs_processed_total{outcome="failed"}` trend and Loki for repeated `job failed` log lines with the same `jobId`).

## Investigation
```promql
sum(worker_queue_jobs{queue="platform-jobs", state="waiting", namespace="platform-<env>"})
rate(worker_jobs_processed_total{outcome="failed", namespace="platform-<env>"}[10m])
```
Check the `worker-overview` Grafana dashboard for queue depth over time vs.
replica count - if replica count isn't rising with backlog, the
autoscaler isn't reacting (see `autoscaling/README.md`).

## Mitigation
1. If autoscaling isn't reacting: check
   `kubectl describe scaledobject worker -n platform-<env>` for KEDA errors
   (commonly a `TriggerAuthentication` secret/credential issue - see
   `autoscaling/keda/triggerauthentication-redis.yaml`).
2. If genuinely under capacity: temporarily raise
   `worker.autoscaling.maxReplicas` (or the KEDA ScaledObject's `maxReplicaCount`).
3. If a poison-pill job: use `vault kv get` / direct Redis inspection to
   identify and manually remove the offending job from the queue (BullMQ
   CLI or `redis-cli` against the `bull:platform-jobs:*` keys).

## Escalation
Page on-call if backlog keeps growing after step 2 (indicates a genuine
capacity or downstream-dependency problem, not just an autoscaling lag).
