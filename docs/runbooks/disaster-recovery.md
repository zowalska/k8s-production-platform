# Runbook: Disaster recovery

## Scope
What to do if an entire environment's cluster or a critical data store is
lost or badly corrupted.

## PostgreSQL (RDS) restore
RDS automated backups + point-in-time recovery are enabled by
`terraform/modules/rds` (`backup_retention_period`). To restore:
1. Restore a new RDS instance from a snapshot or PITR timestamp (via
   `aws rds restore-db-instance-to-point-in-time` or the console) - do this
   *alongside* the existing instance, not in place, so you can verify data
   before cutting over.
2. Update the restored instance's endpoint in Vault
   (`vault kv patch secret/platform/<env>/api DATABASE_URL=...`, same for
   `worker`) rather than in Terraform state directly, to avoid a
   destructive `terraform apply` mid-incident.
3. Roll `api`/`worker` to pick up the new connection string (see
   `rotating-vault-secrets.md`).
4. Once verified, reconcile Terraform state to match the new instance
   (`terraform import` or a follow-up `apply`) so future `plan`s are clean.

## Redis (ElastiCache) data loss
Redis here is used as a job queue (BullMQ) and cache, not a system of
record - `terraform/modules/elasticache` does not need to guarantee
durability. Recovery is simply: provision a fresh replication group (or let
Terraform recreate it), point Vault at the new endpoint, and accept that any
in-flight/queued jobs are lost (the source-of-truth `tasks.status` in
Postgres will show `pending` rows that never got processed - a reconciler
job that re-enqueues stale `pending` tasks would be a reasonable follow-up
enhancement, not currently implemented).

## Full cluster loss (EKS)
Because deployment is fully GitOps-driven, cluster recovery is:
1. `cd terraform/environments/<env> && terraform apply` to recreate the EKS
   cluster (and, if also lost, RDS/ElastiCache - see above).
2. Re-bootstrap Argo CD itself (not managed by Argo CD - it's what makes
   Argo CD exist in the first place) and Vault (its unseal keys/root token
   must have been backed up out-of-band - Vault's Raft storage does not
   survive a full cluster loss unless its data directory was on a
   separately-backed-up volume or auto-unseal via a cloud KMS key was
   configured, see `security/vault/vault-values.yaml`).
3. Apply the bootstrap Argo CD Application
   (`argocd/bootstrap/root-app.yaml`) - everything else (monitoring, Vault
   config, the platform Applications themselves) reconciles automatically
   from Git from that point on.

## What is NOT automatically recovered
- Vault's unseal keys / root token and any auto-unseal KMS configuration -
  must be stored securely out-of-band (e.g. a separate secrets vault or
  hardware security module), not in this repository.
- Grafana dashboard edits made ad-hoc in the UI instead of via
  `monitoring/grafana/dashboards/*.json` - a reminder to always commit
  dashboard changes back to Git (GitOps applies to dashboards too).
