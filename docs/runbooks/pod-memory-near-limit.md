# Runbook: PodMemoryNearLimit

**Alert**: A pod's memory usage is approaching its configured
`resources.limits.memory`, at risk of imminent OOMKill. Source:
`monitoring/alerts/platform-rules.yaml`.

## Investigation
```promql
container_memory_working_set_bytes{namespace="platform-<env>"}
/ on(pod) kube_pod_container_resource_limits{resource="memory", namespace="platform-<env>"}
```
Check whether this is a sudden spike (likely a specific request/job causing
excessive memory use, e.g. an unusually large `payload` on `POST /tasks`) or
a slow climb (likely a memory leak - check the Node.js process's heap growth
over multiple days on the `platform-cluster-overview` dashboard).

## Mitigation
- **Short-term**: bump `resources.limits.memory` (and `requests.memory`
  proportionally) in `helm/platform/values-<env>.yaml` for the affected
  component, and let Argo CD sync.
- **If a leak is suspected**: capture a heap snapshot
  (`kubectl exec` + `node --inspect` or a scheduled restart as a stopgap)
  and file a bug against `apps/api` or `apps/worker`.
- **If caused by oversized payloads**: `apps/api/src/app.js` already caps
  request bodies at `1mb` (`express.json({ limit: '1mb' })`) - verify this
  limit is actually being hit as expected, or lower it further.

## Escalation
Escalate to the service owner if the trend is a genuine leak (slow,
monotonic climb) rather than load-driven - a leak will eventually OOMKill
regardless of how many times replicas are bumped.
