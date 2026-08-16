# Runbook: PodCrashLooping

**Alert**: A pod in a `platform-*` namespace is in `CrashLoopBackOff`.
Source: `monitoring/alerts/platform-rules.yaml`.

## Investigation
```sh
kubectl -n platform-<env> get pods
kubectl -n platform-<env> describe pod <pod>
kubectl -n platform-<env> logs <pod> --previous
```
Common root causes for this platform specifically:
- **Vault Agent Injector failure**: if `vault.hashicorp.com/agent-inject`
  annotations are present but Vault is unreachable/sealed, or the
  Kubernetes-auth role/policy isn't configured for that ServiceAccount, the
  init container never renders `/vault/secrets/config` and the app container
  never starts. Check `kubectl logs <pod> -c vault-agent-init`.
- **Bad config/secret**: a malformed `DATABASE_URL`/`REDIS_URL` causes the
  app to throw during startup (`apps/api/src/index.js` /
  `apps/worker/src/index.js` exit(1) on any startup error) - check the crashed
  container's own logs (not the vault-agent-init logs).
- **Readiness/liveness probe misconfiguration** after a manifest change.
- **OOMKilled** - see `PodMemoryNearLimit` runbook; a hard OOM kill also
  manifests as a crash loop, distinguishable via
  `kubectl describe pod` showing `Last State: Terminated, Reason: OOMKilled`.

## Mitigation
1. Fix the underlying cause identified above.
2. If caused by a bad deploy, roll back via Argo CD:
   `argocd app rollback platform-<env> <previous-revision>`.
3. If Vault-related, check `security/vault/README.md` and confirm the
   relevant Vault role/policy exists for the (env, service) pair.

## Escalation
Page on-call if crash-looping affects more than one replica of a service
(i.e. it's not just a rolling-update transient) or if it's the sole
replica in a namespace with `podDisruptionBudget.minAvailable: 1`.
