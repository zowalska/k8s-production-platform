# Platform observability stack

This directory contains the declarative monitoring and logging configuration for the portfolio Kubernetes platform. Everything here is intended for GitOps/Helm consumption only; no manifests in this folder apply themselves.

## Architecture

- **Prometheus** is deployed with `prometheus-community/kube-prometheus-stack` into the `monitoring` namespace.
- **Application metrics** are scraped through `ServiceMonitor` resources. This folder only defines ServiceMonitors for the platform `api` and `worker` services.
- **Dependency metrics** for Bitnami PostgreSQL and Redis are assumed to already be enabled elsewhere via `metrics.enabled=true`, which creates their exporter ServiceMonitors.
- **Grafana** is bundled with `kube-prometheus-stack` and loads dashboards from ConfigMaps labeled `grafana_dashboard=1` through the chart's sidecar.
- **Loki** stores logs, and **Promtail** runs as a DaemonSet to tail pod logs from `platform-<env>` namespaces.
- **Alertmanager** routes alerts to Slack and a webhook endpoint.

## Metric assumptions used by the dashboards and alerts

The dashboards and custom alert rules assume the platform apps expose these metric families:

- `api`
  - `http_requests_total`
  - `http_request_duration_seconds_bucket`
- `worker`
  - `bullmq_jobs_waiting`
  - `bullmq_jobs_active`
  - `bullmq_jobs_delayed`
  - `bullmq_jobs_completed_total`
  - `bullmq_jobs_failed_total`
  - `bullmq_job_duration_seconds_bucket`

Kubernetes target labels added by Prometheus (for example `namespace`, `service`, and `pod`) are used heavily so the same dashboards work across `platform-dev`, `platform-staging`, and `platform-prod`.

## How Prometheus scrapes the platform

1. `kube-prometheus-stack` deploys the Prometheus Operator and Prometheus servers.
2. The Prometheus values files in `kube-prometheus-stack/` relax the default selectors so Prometheus discovers externally managed `ServiceMonitor` and `PrometheusRule` objects from this repo.
3. `kube-prometheus-stack/servicemonitors/api-servicemonitor.yaml` and `worker-servicemonitor.yaml` select Services by:
   - `app.kubernetes.io/name`
   - `app.kubernetes.io/part-of=platform`
4. Each app Service exposes a port named `metrics`, and Prometheus scrapes `/metrics` every 30 seconds.

## Grafana dashboards

- `grafana/dashboards/api-overview.json`: API throughput, 5xx rate, latency percentiles, pod CPU, pod memory
- `grafana/dashboards/worker-overview.json`: queue depth, throughput, worker latency, pod CPU, pod memory
- `grafana/dashboards/platform-cluster-overview.json`: node CPU/memory/disk, pod counts by namespace, firing alerts

The example `grafana/dashboard-provisioning-configmap.yaml` shows the sidecar pattern with an inline dashboard. In a real GitOps flow, the JSON dashboards in `grafana/dashboards/` are usually wrapped into one or more ConfigMaps carrying the `grafana_dashboard=1` label.

## Logging flow

- Promtail runs on every node and discovers pods via `kubernetes_sd_configs`.
- Relabeling adds `namespace`, `pod`, `container`, `node`, `app`, and `part_of` labels.
- A Promtail `match` stage parses structured JSON logs emitted by `api` and `worker`.
- Loki stores logs locally in dev and in S3-backed object storage in prod.
- Grafana receives a Loki datasource through the `grafana.additionalDataSources` block in the kube-prometheus-stack values files.

## Alerting

`alerts/platform-rules.yaml` defines realistic platform alerts for:

- API 5xx error ratio
- API p99 latency
- BullMQ worker queue backlog
- CrashLoopBackOff pods
- Pod memory pressure near limits
- PVC capacity pressure
- PostgreSQL exporter down
- Redis exporter down
- Node disk pressure

Alertmanager is configured in each environment values file to send alerts to:

- a Slack webhook stored in a Kubernetes Secret
- a platform webhook endpoint

## Helm / GitOps installation reference

Add the chart repositories:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

Example direct Helm installs for a dev environment:

```bash
helm upgrade --install kube-prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  -f monitoring/kube-prometheus-stack/values-dev.yaml

helm upgrade --install loki grafana/loki \
  --namespace monitoring \
  -f monitoring/loki-logging/loki-values-dev.yaml

helm upgrade --install promtail grafana/promtail \
  --namespace monitoring \
  -f monitoring/loki-logging/promtail-values.yaml
```

In Argo CD, the Applications defined elsewhere in the repo should reference:

- `prometheus-community/kube-prometheus-stack` + `monitoring/kube-prometheus-stack/values-<env>.yaml`
- `grafana/loki` + `monitoring/loki-logging/loki-values-<env>.yaml`
- `grafana/promtail` + `monitoring/loki-logging/promtail-values.yaml`
- raw manifests from:
  - `monitoring/kube-prometheus-stack/servicemonitors/`
  - `monitoring/alerts/platform-rules.yaml`
  - `monitoring/grafana/dashboard-provisioning-configmap.yaml`

## Environment placeholders

Several files intentionally contain placeholders and comments for GitOps overrides:

- Grafana hostnames like `grafana.<env>.platform.example.com`
- Alertmanager webhook URLs
- Loki S3 bucket names such as `platform-<env>-loki-chunks`
- IRSA role annotations for the Loki service account
- production storage class names
