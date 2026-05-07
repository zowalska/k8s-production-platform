# Vault runtime secrets pattern

This directory configures **HashiCorp Vault** for application runtime secrets using the **Vault Agent Injector** sidecar pattern.

- Vault itself runs in the shared `vault` namespace.
- The application workloads remain in `platform-dev`, `platform-staging`, and `platform-prod`.
- Each `(environment, service)` pair gets its own Vault policy + Kubernetes auth role:
  - `platform-dev-api`
  - `platform-dev-worker`
  - `platform-staging-api`
  - `platform-staging-worker`
  - `platform-prod-api`
  - `platform-prod-worker`

The matching Kubernetes `ServiceAccount` names are simply `api` and `worker` in the corresponding namespace, and the Helm chart templates for those workloads can then use annotations such as `vault.hashicorp.com/role: platform-prod-api`.

## Secret layout

Vault stores application secrets in the KV-v2 mount at `secret/`.

- API secrets live at `secret/data/platform/<env>/api`
- Worker secrets live at `secret/data/platform/<env>/worker`

When writing secrets with the CLI, use the KV helper path without `/data/`, for example:

```bash
vault kv put secret/platform/dev/api DATABASE_URL="..." REDIS_URL="..." JWT_SECRET="..."
```

## Kubernetes auth setup

`auth/kubernetes-auth-setup.sh` shows the one-time steps needed against an initialized and unsealed Vault cluster:

1. enable the `secret/` KV-v2 mount,
2. enable the Kubernetes auth method,
3. configure it with the cluster API host, CA, and token reviewer JWT,
4. load the six policies from `policies/*.hcl`,
5. create the six matching Kubernetes auth roles.

## Local / developer smoke testing

After logging into Vault, a developer can write a test secret with `vault kv put` and then redeploy or restart a pod so the injector renders the secret template file.

Example:

```bash
vault kv put secret/platform/dev/api \
  DATABASE_URL="postgresql://..." \
  REDIS_URL="redis://..." \
  JWT_SECRET="dev-only-example"
```

## Vault vs. AWS Secrets Manager in this platform

This repo treats **Vault** and **AWS Secrets Manager** as different layers:

- **AWS Secrets Manager via Terraform**: infrastructure/bootstrap secrets such as RDS or ElastiCache master credentials that cloud resources need during provisioning.
- **Vault via injector**: application runtime secrets that pods read at startup or refresh through the Vault Agent sidecar.

That separation keeps Terraform focused on cloud resource lifecycle while Vault handles namespace/service-scoped runtime secret delivery inside Kubernetes.
