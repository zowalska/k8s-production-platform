# Runbook: PVCAlmostFull

**Alert**: A PersistentVolumeClaim (typically PostgreSQL's or Prometheus'/
Loki's) is nearing capacity. Source: `monitoring/alerts/platform-rules.yaml`.

## Investigation
```promql
kubelet_volume_stats_used_bytes / kubelet_volume_stats_capacity_bytes
```
Identify which PVC fired: PostgreSQL data volume
(`{{ .Release.Name }}-postgresql`), Prometheus TSDB, or Loki chunks/index
(only relevant for the `filesystem` storage mode in `dev` - `prod` uses S3
via `monitoring/loki-logging/loki-values-prod.yaml`, which isn't
capacity-bound the same way).

## Mitigation
- **PostgreSQL**: most EKS storage classes (`gp3` via the EBS CSI driver)
  support online volume expansion - edit the PVC's
  `spec.resources.requests.storage` (or bump
  `postgresql.primary.persistence.size` in `helm/platform/values-<env>.yaml`
  and let Argo CD sync, if `allowVolumeExpansion: true` on the StorageClass).
  Also investigate *why* it's growing - e.g. unbounded `tasks` table growth
  with no retention/archival policy (a known simplification of this
  reference app - a production system would add a retention job).
- **Prometheus**: lower `retention` in
  `monitoring/kube-prometheus-stack/values-<env>.yaml`, or expand the PVC.
- **Loki (dev, filesystem mode)**: lower `retention_period` in
  `monitoring/loki-logging/loki-values-dev.yaml`, or migrate `dev` to S3
  storage as well.

## Escalation
Treat as urgent if the volume is PostgreSQL's - a full data volume causes
write failures and, ultimately, an outage, not just missing metrics/logs.
