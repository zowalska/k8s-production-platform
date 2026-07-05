# Loki and Promtail notes

## Expected application log format

The Promtail pipeline assumes `api` and `worker` emit one JSON object per line, for example:

```json
{"level":"info","msg":"request completed","time":"2026-09-08T10:32:11.512Z","requestId":"a1b2c3d4"}
```

Parsed fields:

- `level` -> promoted to a Loki label
- `requestId` -> promoted to a Loki label as `request_id`
- `time` -> used as the log timestamp
- `msg` -> becomes the rendered log line in Grafana

## Querying with LogQL

Useful starter queries:

```logql
{namespace="platform-prod", app="api"} |= "error"
```

```logql
{namespace="platform-prod", app="worker", level="error"}
```

```logql
{namespace="platform-prod", app="api"} | json | request_id="a1b2c3d4"
```

```logql
sum by (app, level) (count_over_time({namespace=~"platform-.*", app=~"api|worker"}[5m]))
```

## Grafana datasource provisioning

Grafana is expected to get its Loki datasource from the `grafana.additionalDataSources` block in the kube-prometheus-stack values files. That keeps the datasource declarative and environment-specific without hard-coding it inside dashboards.

## Chart split

- `loki-values-dev.yaml` and `loki-values-prod.yaml` target the `grafana/loki` chart
- `promtail-values.yaml` targets the `grafana/promtail` chart
