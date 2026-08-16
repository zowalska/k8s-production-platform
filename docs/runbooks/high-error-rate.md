# Runbook: HighErrorRate

**Alert**: `api` 5xx response ratio exceeds threshold over a 5-minute window.
Source: `monitoring/alerts/platform-rules.yaml`.

## Likely causes
- A recent deploy introduced a regression (check `argocd app history platform-<env>` / the Argo CD UI for the most recent sync).
- A downstream dependency (Postgres, Redis, Vault) is degraded - check `PostgresDown` / `RedisDown` alerts and `/readyz`.
- Unhandled exception in a specific route - check Loki logs for `level:error` from `service=api`.

## Investigation
```logql
{namespace="platform-<env>", app="api"} | json | level="error"
```
```promql
sum(rate(api_http_requests_total{status_code=~"5..", namespace="platform-<env>"}[5m]))
/ sum(rate(api_http_requests_total{namespace="platform-<env>"}[5m]))
```
Check the Grafana `api-overview` dashboard for the error-rate and latency
panels around the same time window, and correlate with the
`platform-cluster-overview` dashboard for node-level issues.

## Mitigation
1. If caused by a bad deploy: `argocd app rollback platform-<env> <previous-revision>` (or revert the commit that bumped the image tag in `helm/platform/values-<env>.yaml` and let Argo CD auto-sync).
2. If caused by a dependency outage: follow the `PostgresDown` / `RedisDown` runbook for that dependency first.
3. If the error is isolated to one route: consider a temporary feature-flag/route-level circuit breaker (not currently implemented - would be a good follow-up).

## Escalation
Page the on-call engineer if the error rate stays above threshold for more
than 15 minutes after step 1/2, or if it correlates with a customer-visible
incident.
