# Runbook: Rotating Vault-managed secrets

Applies to `DATABASE_URL`, `REDIS_URL`, and `JWT_SECRET` for a given
(environment, service) pair - see `security/vault/README.md` for the
underlying model.

## Rotating JWT_SECRET (no coordination with infra needed)
```sh
vault kv patch secret/platform/<env>/api JWT_SECRET="$(openssl rand -hex 32)"
```
Vault Agent's default lease/template refresh will pick this up and
re-render `/vault/secrets/config` on its next renewal cycle; `api` pods must
still be restarted to pick up the new value (the container only sources the
file once, at startup) - trigger a rolling restart:
```sh
kubectl -n platform-<env> rollout restart deployment/platform-api
```

## Rotating DATABASE_URL / REDIS_URL after an infra-level credential rotation
1. Rotate the underlying credential at the source: for `DATABASE_URL`, this
   means rotating the RDS master (or app) user's password - see
   `terraform/modules/rds` (the `random_password` resource + its
   `aws_secretsmanager_secret_version`) - `terraform apply` with a new
   `random_password` (or `terraform taint`/`-replace`) generates a new one.
2. Update the corresponding Vault secret to match:
   ```sh
   vault kv patch secret/platform/<env>/api DATABASE_URL="postgres://..."
   vault kv patch secret/platform/<env>/worker DATABASE_URL="postgres://..."
   ```
3. Roll both `api` and `worker` so they pick up the new connection string:
   ```sh
   kubectl -n platform-<env> rollout restart deployment/platform-api deployment/platform-worker
   ```
4. Confirm `/readyz` on both is healthy post-rollout before considering the
   rotation complete.

## Notes
- Never rotate by editing `helm/platform/values-<env>.yaml` - those values
  are only used for the non-Vault fallback path (`vault.enabled: false`);
  the primary path never has secrets in Git.
- Always rotate `api` and `worker` together for `DATABASE_URL`/`REDIS_URL`
  since they point at the same underlying instances.
