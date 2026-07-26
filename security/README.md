# Security hardening

This directory collects the security controls that apply *across* the
platform, on top of what's already baked into each Deployment (non-root,
read-only root filesystem, dropped capabilities - see
`kubernetes/base/*/deployment.yaml` and `helm/platform/templates/*/deployment.yaml`)
and each service's own NetworkPolicy.

```
security/
├── namespaces/     Namespace manifests with Pod Security Standard labels (enforce=restricted)
├── kyverno/        ClusterPolicies: admission-time guardrails (Kyverno)
└── vault/          HashiCorp Vault: secrets management (see vault/README.md)
```

## Defense in depth

| Layer | Mechanism | Where |
|-------|-----------|-------|
| 1. Container hardening | `runAsNonRoot`, `readOnlyRootFilesystem`, dropped capabilities, `seccompProfile: RuntimeDefault` | `kubernetes/base/`, `helm/platform/templates/` |
| 2. Namespace admission | Pod Security Admission, labels `pod-security.kubernetes.io/enforce: restricted` | `security/namespaces/`, and mirrored on the Kustomize `kubernetes/overlays/*/namespace.yaml` |
| 3. Policy-as-code | Kyverno ClusterPolicies: non-root, no privileged/host-namespaces, no `:latest`, resource requests/limits required, restricted image registries for `api`/`worker` | `security/kyverno/` |
| 4. Network segmentation | Default-deny + explicit allow NetworkPolicies | `kubernetes/base/`, `helm/platform/templates/networkpolicy-data.yaml` |
| 5. Secrets management | Vault Agent Injector, Kubernetes auth, least-privilege policies per (env, service) | `security/vault/` |
| 6. Supply chain | CodeQL, Trivy (fs + image), tfsec/Checkov, gitleaks, Dependabot, cosign keyless signing + SBOM | `.github/workflows/` |

## Applying

```sh
# 1. Namespaces with PSA labels (idempotent - safe to run before Argo CD's
#    CreateNamespace=true syncOption, which becomes a no-op once these exist)
kubectl apply -f security/namespaces/

# 2. Kyverno itself + this repo's policies
helm install kyverno kyverno/kyverno -n kyverno --create-namespace -f security/kyverno/kyverno-values.yaml
kubectl apply -f security/kyverno/ --prune -l policies.kyverno.io/category

# 3. Vault - see security/vault/README.md
```

## Why Kyverno over OPA/Gatekeeper

Both are valid choices. Kyverno was chosen here because its policies are
plain Kubernetes-native YAML (no separate Rego language to learn), which
keeps this reference repo approachable, and because it ships a
`background` mode that can retroactively report on (and optionally remediate)
resources that predate a policy - useful during incremental rollout across
`dev` → `staging` → `prod`.
