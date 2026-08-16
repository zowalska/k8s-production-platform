# Runbook: PostgresDown

**Alert**: The PostgreSQL exporter target is unreachable / `pg_up == 0`.
Source: `monitoring/alerts/platform-rules.yaml`.

## Impact
Both `api` (`/readyz` will start failing, removing pods from the Service
endpoints) and `worker` (jobs will fail and retry with backoff) are affected
platform-wide in the given environment. This is a **critical** dependency
outage.

## Investigation
- **dev** (in-cluster Bitnami subchart):
  ```sh
  kubectl -n platform-dev get pods -l app.kubernetes.io/name=postgresql
  kubectl -n platform-dev describe pod <postgresql-pod>
  kubectl -n platform-dev logs <postgresql-pod>
  ```
  Common causes: PVC full (see `PVCAlmostFull`), node pressure/eviction,
  or a bad Helm values change to the `postgresql.*` block.
- **staging/prod** (Terraform-managed RDS): check the RDS instance status in
  the AWS console/CLI (`aws rds describe-db-instances`), CloudWatch alarms,
  and whether a maintenance window or failover (Multi-AZ) is in progress.
  Check `terraform/modules/rds` for the instance configuration.

## Mitigation
- **dev**: restart/reschedule the pod if it's a transient node issue;
  resize the PVC if full.
- **staging/prod**: RDS Multi-AZ should fail over automatically (prod has
  `multi_az = true` - see `terraform/environments/prod`); confirm the
  application reconnects post-failover (the `pg` pool in
  `apps/api/src/db.js` / `apps/worker/src/db.js` will retry new queries
  automatically, but in-flight queries at the moment of failover will
  error - this is expected and transient).

## Escalation
This is a page-immediately, all-hands situation for `prod` - both request
serving and job processing degrade platform-wide.
