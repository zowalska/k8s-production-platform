# 7. Kyverno for policy-as-code

## Status
Accepted

## Context
Container-level hardening (non-root, read-only root filesystem, dropped
capabilities) and namespace-level Pod Security Admission labels are a good
baseline, but neither can express cross-cutting rules like "no `:latest`
image tags" or "api/worker images must come from our own GHCR namespace" -
that needs an admission-time policy engine. The two mainstream choices are
Kyverno and OPA/Gatekeeper.

## Decision
Kyverno (`security/kyverno/`). Its policies are plain Kubernetes-native YAML
(`ClusterPolicy` CRDs using pattern matching), with no separate policy
language to learn, which keeps this reference repo approachable to readers
who don't already know Rego. Kyverno's `background: true` mode was also a
factor: it can retroactively report on resources that predate a policy,
useful for a phased rollout across `dev` → `staging` → `prod`.

## Consequences
- OPA/Gatekeeper's Rego is more expressive for complex cross-resource
  policies; if this platform later needs that, it's a plausible follow-up
  ADR superseding this one for specific policies (they can coexist).
- Kyverno itself becomes a dependency with its own availability
  requirements - `admissionController.failurePolicy: Fail` in
  `security/kyverno/kyverno-values.yaml` means a Kyverno outage blocks new
  Pod admissions cluster-wide, a deliberate fail-closed tradeoff.
