# 4. HashiCorp Vault (Agent Injector) over External Secrets Operator

## Status
Accepted

## Context
Application-level runtime secrets (`DATABASE_URL`, `REDIS_URL`, `JWT_SECRET`)
must never be committed to Git or stored as static Kubernetes Secrets pulled
from an unencrypted source. Two common patterns solve this on Kubernetes:
(a) the External Secrets Operator (ESO) syncing from a backend into native
`Secret` objects, or (b) HashiCorp Vault's Agent Injector rendering secrets
directly into a pod's filesystem via a sidecar, with nothing ever landing in
etcd as a `Secret` object at all.

## Decision
We use Vault with the Agent Injector pattern and Kubernetes auth
(`security/vault/`). Each (environment, service) pair gets its own Vault
Kubernetes-auth role bound to a specific ServiceAccount + namespace, scoped
by a dedicated read-only policy.

## Consequences
- Secrets are never persisted as Kubernetes `Secret` objects in the primary
  path, only as short-lived files inside the pod's ephemeral volume,
  refreshed via Vault Agent's lease renewal.
- This requires running Vault itself in-cluster (or reachable) with its own
  operational burden (unsealing, HA/Raft storage) - see
  `security/vault/vault-values.yaml` and its warning against Vault's
  insecure "dev mode".
- Environments/services without Vault available (e.g. a bare local cluster)
  fall back to a plain Helm-rendered Secret - see `api.vault.enabled` /
  `worker.vault.enabled` in `helm/platform/values.yaml`.
- AWS-level infrastructure secrets (the RDS master password, the
  ElastiCache auth token) are a separate concern, generated and stored by
  Terraform directly in AWS Secrets Manager - see `terraform/README.md`.
  Vault holds *application* secrets, not infrastructure bootstrap secrets.
