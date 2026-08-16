# Runbook: HighRequestLatencyP99

**Alert**: `api` p99 request latency exceeds threshold. Source:
`monitoring/alerts/platform-rules.yaml`.

## Likely causes
- Postgres query slowness (missing index, lock contention, connection pool
  exhaustion) - `tasks` table growth over time is the most likely culprit in
  this reference app.
- Redis/BullMQ backpressure if `api` synchronously waits on queue operations.
- CPU throttling - check the pod's `container_cpu_cfs_throttled_periods_total`
  against its `resources.limits.cpu` (see `helm/platform/values-<env>.yaml`).
- Too few replicas for current load - check whether the HPA
  (`api-overview` dashboard) is already at `maxReplicas`.

## Investigation
```promql
histogram_quantile(0.99, sum(rate(api_http_request_duration_seconds_bucket{namespace="platform-<env>"}[5m])) by (le, route))
```
Cross-reference with the Postgres/Redis exporter dashboards (Bitnami
subcharts expose their own metrics when `metrics.enabled=true`).

## Mitigation
1. If HPA is maxed out: temporarily raise `api.autoscaling.maxReplicas` in
   `helm/platform/values-<env>.yaml` and let Argo CD sync, then investigate
   the root cause of increased load.
2. If CPU-throttled: raise `api.resources.limits.cpu`.
3. If Postgres-bound: check `pg_stat_activity` for long-running queries;
   consider adding an index on `tasks(status, created_at)` if scans are the
   bottleneck.

## Escalation
Page on-call if p99 stays above threshold for 30+ minutes or if
`HighErrorRate` fires concurrently (compounding issue, treat as a single
incident).
