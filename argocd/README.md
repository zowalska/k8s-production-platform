# Argo CD GitOps layout

This repo uses an app-of-apps pattern: one bootstrap `Application` creates the `platform` `AppProject` plus one child `Application` per environment or shared platform add-on.

## Bootstrap

1. Install Argo CD itself into the `argocd` namespace.
2. Bootstrap this repo with:

   ```bash
   kubectl apply -f argocd/bootstrap/root-app.yaml
   ```

   The bootstrap app is intentionally multi-source so that a single apply can seed both `argocd/projects` and `argocd/applications`.

## Promotion model

- `platform-dev.yaml` points at `helm/platform` with `values-dev.yaml` and is the fastest-moving environment.
- `platform-staging.yaml` uses the same umbrella chart with `values-staging.yaml` and is a safe place to hold a promotion candidate.
- `platform-prod.yaml` uses `values-prod.yaml` and keeps safer sync defaults.
- All three manifests currently track `main`, but the layout is ready for stricter promotion later by pinning staging/prod `targetRevision` to a Git tag, commit SHA, or release branch.

Because each environment is its own `Application`, promotion is mostly a Git change: either merge the same chart update forward, or re-point a higher environment to the already-tested revision while keeping its own values file.

## Sync policy choices

- **Dev**: automated sync with prune + self-heal for fast feedback.
- **Staging**: automated sync with prune, but no self-heal so short-lived manual checks are less likely to be reverted instantly.
- **Prod**: self-heal stays on for managed objects, but prune is disabled so deletions remain deliberate and reviewable.

## Multi-source applications

Shared platform components such as monitoring, Loki/Promtail, Vault, and KEDA are defined as Argo CD multi-source `Application`s. The chart comes from the upstream Helm repository, while environment-specific values stay in this Git repo.

## Notifications

Argo CD Notifications can alert Slack on sync failures by configuring a Slack service in `argocd-notifications-secret` / `argocd-notifications-cm` and subscribing the applications to triggers such as `on-sync-failed` or `on-health-degraded`.

A common per-application annotation looks like this:

```yaml
notifications.argoproj.io/subscribe.on-sync-failed.slack: platform-alerts
```

In practice, many teams send dev/staging failures to an engineering channel and restrict prod notifications to a smaller on-call channel.
