# 6. KEDA for event-driven worker autoscaling

## Status
Accepted

## Context
`worker`'s natural scaling signal is queue backlog (how many jobs are
waiting in `platform-jobs`), not CPU/memory - a worker can be CPU-idle while
a large backlog builds up if job processing is I/O-bound, and CPU-based HPA
would react far too slowly (or not at all) to that.

## Decision
KEDA is installed alongside the standard HPA, with a `ScaledObject`
(`autoscaling/keda/scaledobject-worker.yaml`) that scales `worker` based on
the Redis list length backing the BullMQ queue. In `prod`,
`worker.autoscaling.enabled` is set to `false` in the Helm chart so KEDA's
own generated HPA is the only one managing that Deployment's replica count
(two HPAs targeting the same Deployment fight each other).

## Consequences
- `dev`/`staging` still run the simpler CPU-based HPA (KEDA not assumed to
  be installed there), while `prod` requires KEDA to be healthy for worker
  autoscaling to function at all - a KEDA outage in prod means worker scaling
  freezes at its last replica count (still serviceable, just not elastic).
- See `autoscaling/README.md` for the full decision matrix across HPA / KEDA
  / Cluster Autoscaler / VPA.
