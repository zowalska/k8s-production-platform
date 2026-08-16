# 3. Helm as the primary GitOps deployment artifact; Kustomize kept as a secondary/local path

## Status
Accepted

## Context
The platform needs one canonical, environment-parameterized deployment
artifact that Argo CD applies to `dev`/`staging`/`prod`, plus bundles
PostgreSQL/Redis as dependencies for self-contained environments. It should
also remain easy to run a quick `kubectl apply -k` against a scratch/local
cluster without installing Argo CD or Helm dependency management.

## Decision
- `helm/platform` (an umbrella chart with Bitnami `postgresql`/`redis` as
  conditional dependencies) is what Argo CD's `argocd/applications/*.yaml`
  actually deploys, parameterized per environment via
  `values-{dev,staging,prod}.yaml`.
- `kubernetes/` (plain Kustomize base + overlays) is kept as a lighter-weight,
  dependency-free path for local/dev clusters and for readers who want to see
  the "raw" manifests without Helm's templating layer.

## Consequences
- Two manifest trees must be kept conceptually in sync (labels, ports,
  probes) - see `kubernetes/README.md` for the explicit contract between
  them.
- Postgres/Redis are only bundled by the Helm path; the Kustomize path
  assumes they're already reachable (e.g. via `docker-compose.yml` locally).
