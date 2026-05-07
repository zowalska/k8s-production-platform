#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
POLICY_DIR="${SCRIPT_DIR}/../policies"

: "${VAULT_ADDR:?Set VAULT_ADDR to the unsealed Vault address, for example https://vault.example.com}"
: "${VAULT_TOKEN:?Set VAULT_TOKEN to an admin/bootstrap token with auth and policy privileges}"
: "${KUBERNETES_HOST:?Set KUBERNETES_HOST to the Kubernetes API server URL, for example https://kubernetes.default.svc:443}"
: "${KUBERNETES_CA_CERT_PATH:?Set KUBERNETES_CA_CERT_PATH to a PEM file containing the cluster CA certificate}"
: "${TOKEN_REVIEWER_JWT_PATH:?Set TOKEN_REVIEWER_JWT_PATH to a file containing the token reviewer JWT}"

ROLE_TTL="${ROLE_TTL:-24h}"

# This mount path matches the injector annotations used by the platform workloads.
if ! vault secrets list | grep -q '^secret/'; then
  vault secrets enable -path=secret kv-v2
fi

if ! vault auth list | grep -q '^kubernetes/'; then
  vault auth enable kubernetes
fi

# If your cluster uses a custom issuer or reviewer audience, extend this command with the matching auth settings.
vault write auth/kubernetes/config \
  kubernetes_host="${KUBERNETES_HOST}" \
  kubernetes_ca_cert=@"${KUBERNETES_CA_CERT_PATH}" \
  token_reviewer_jwt="$(<"${TOKEN_REVIEWER_JWT_PATH}")"

for env in dev staging prod; do
  namespace="platform-${env}"

  for service in api worker; do
    policy_name="platform-${env}-${service}"
    policy_file="${POLICY_DIR}/${policy_name}-policy.hcl"

    vault policy write "${policy_name}" "${policy_file}"

    vault write "auth/kubernetes/role/${policy_name}" \
      bound_service_account_names="${service}" \
      bound_service_account_namespaces="${namespace}" \
      policies="${policy_name}" \
      ttl="${ROLE_TTL}"
  done
done

echo "Vault Kubernetes auth, policies, and roles configured successfully."
