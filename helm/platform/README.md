# platform Helm chart

Umbrella chart deploying the `api` and `worker` services (and, optionally,
bundled PostgreSQL/Redis) for the k8s-production-platform reference
architecture. This is the primary deployment path used by Argo CD - see
[`../../argocd/applications`](../../argocd/applications).

## Installing

```sh
helm dependency update helm/platform

# dev: fully self-contained, in-cluster Postgres/Redis
helm upgrade --install platform-dev helm/platform \
  --namespace platform-dev --create-namespace \
  -f helm/platform/values.yaml -f helm/platform/values-dev.yaml

# staging / prod: external RDS/ElastiCache (see terraform/), Vault-delivered secrets
helm upgrade --install platform-prod helm/platform \
  --namespace platform-prod --create-namespace \
  -f helm/platform/values.yaml -f helm/platform/values-prod.yaml
```

## Key values

| Key                          | Description |
|-------------------------------|-------------|
| `api.image.tag` / `worker.image.tag` | Image tag pushed by `.github/workflows/build-push.yml` |
| `api.vault.enabled` / `worker.vault.enabled` | Use the Vault Agent Injector (production) vs. a plain Secret rendered from `secrets.*` (local/dev fallback) |
| `postgresql.enabled` / `redis.enabled` | Bundle Bitnami subcharts in-cluster (dev) vs. use `externalDatabase`/`externalRedis` (staging/prod, backed by Terraform-provisioned RDS/ElastiCache) |
| `api.autoscaling` / `worker.autoscaling` | HPA bounds; `worker.autoscaling.enabled: false` in prod because KEDA manages worker scaling instead (see `../../autoscaling/keda`) |
| `networkPolicy.enabled` | Toggle default-deny + explicit allow NetworkPolicies |
| `ingress.*` | Ingress-nginx host/TLS for the `api` service |

See [`values.yaml`](values.yaml) for the full, commented list of defaults.
