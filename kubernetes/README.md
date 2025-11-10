# Kubernetes manifests (Kustomize)

This directory is the **local/dev-friendly** deployment path for the `api`
and `worker` services, built with plain [Kustomize](https://kustomize.io/).

For GitOps-managed cluster deployments (dev/staging/prod on EKS), Argo CD
instead points at the **Helm chart** in [`../helm/platform`](../helm/platform)
- see [`../argocd/README.md`](../argocd/README.md). The two paths intentionally
share the same manifest shape (labels, container ports, probes) so they stay
easy to compare, but Postgres/Redis are only bundled by the Helm chart
(as Bitnami subchart dependencies) - this Kustomize path assumes a Postgres
and Redis are already reachable in-cluster or externally.

## Layout

```
base/                 Environment-agnostic Deployment/Service/HPA/NetworkPolicy/PDB for api + worker
overlays/dev/         Single replica, small resources, namespace platform-dev
overlays/staging/     2 replicas, medium resources, namespace platform-staging
overlays/prod/        3+ replicas, pod anti-affinity, namespace platform-prod
```

## Usage

```sh
# Render manifests without applying
kubectl kustomize kubernetes/overlays/dev

# Apply directly to whatever cluster your kubeconfig points at
kubectl apply -k kubernetes/overlays/dev

# Diff against a live cluster
kubectl diff -k kubernetes/overlays/staging
```

## Secrets

`api-secrets` / `worker-secrets` are referenced via `envFrom.secretRef` but are
**not** created by this Kustomize base (see the `secret.example.yaml` files
under `base/api` and `base/worker` for the expected keys). In a full
deployment via Helm, these are populated by the Vault Agent Injector - see
[`../security/vault/README.md`](../security/vault/README.md). For a bare
Kustomize apply against a scratch/dev cluster, create the Secret manually
first (see the comment at the top of `secret.example.yaml`).
