# Architecture

This document expands on the high-level diagram in the root
[`README.md`](../README.md) with more detail on how each layer actually
fits together.

## Request/data flow

1. A client calls the `api` Service (Express), which persists a `tasks` row
   in PostgreSQL and enqueues a `process-task` job onto the `platform-jobs`
   BullMQ queue (backed by Redis).
2. `worker` picks the job up (concurrency configurable via
   `WORKER_CONCURRENCY`), does the work, and writes the result back to the
   same `tasks` row.
3. Both services expose `/healthz` (liveness), `/readyz` (readiness - checks
   Postgres + Redis connectivity) and `/metrics` (Prometheus).

## Delivery pipeline

```
git push → GitHub Actions (test, security scan, build, push to GHCR)
         → Argo CD detects the new Helm chart / values / image tag
         → Argo CD syncs the rendered manifests to the target namespace
         → Kubernetes rolls out the change (readiness-gated)
```

Argo CD, not GitHub Actions, is the only thing that ever talks to the
cluster's API server for application deployments - GitHub Actions only
builds and pushes images (and, optionally, opens a PR bumping the image tag
in `helm/platform/values-<env>.yaml`, see the `open-gitops-pr` placeholder
job in `.github/workflows/build-push.yml`). This is what makes it "GitOps":
the cluster state is a function of what's committed to `main`, not of what a
CI job happened to `kubectl apply`.

## Environments

| Environment | Namespace | Postgres/Redis | Secrets | Replicas (api/worker) |
|---|---|---|---|---|
| dev | `platform-dev` | In-cluster (Bitnami subcharts) | Vault (`platform-dev-*` roles) | 1/1, HPA 1-3 |
| staging | `platform-staging` | Terraform-managed RDS/ElastiCache | Vault (`platform-staging-*` roles) | 2/2, HPA 2-6 |
| prod | `platform-prod` | Terraform-managed RDS/ElastiCache (Multi-AZ) | Vault (`platform-prod-*` roles) | 3/3, HPA 3-20 (api), KEDA (worker) |

## Why these specific choices

See [ADRs](adr/) for the reasoning behind the less obvious decisions (Helm
as the GitOps artifact, Vault Agent Injector vs. External Secrets Operator,
Kyverno vs. OPA/Gatekeeper, KEDA for worker autoscaling, etc).

## Layer-by-layer map

| Concern | Implementation | Path |
|---|---|---|
| Application | Node.js `api` (Express) + `worker` (BullMQ) | `apps/` |
| Containers | Multi-stage, non-root, healthchecked Dockerfiles | `apps/*/Dockerfile` |
| Local dev | docker-compose (api+worker+postgres+redis) | `docker-compose.yml` |
| Manifests (local/dev) | Kustomize base + overlays | `kubernetes/` |
| Manifests (GitOps) | Umbrella Helm chart | `helm/platform/` |
| Infrastructure | Terraform (VPC, EKS, RDS, ElastiCache, IRSA) | `terraform/` |
| Delivery | GitHub Actions (test/scan/build/push) + Argo CD (deploy) | `.github/workflows/`, `argocd/` |
| Autoscaling | HPA, KEDA, Cluster Autoscaler, VPA (recommend-only) | `helm/platform`, `autoscaling/` |
| Secrets | HashiCorp Vault (Agent Injector, Kubernetes auth) | `security/vault/` |
| Policy | Kyverno ClusterPolicies, Pod Security Admission | `security/kyverno/`, `security/namespaces/` |
| Observability | Prometheus, Grafana, Loki/Promtail, Alertmanager | `monitoring/` |
