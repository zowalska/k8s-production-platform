{{/*
Base chart name
*/}}
{{- define "platform.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Fully qualified app name, prefixed with the release name unless the release
name already contains the chart name.
*/}}
{{- define "platform.fullname" -}}
{{- if contains .Chart.Name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Common labels applied to every resource.
*/}}
{{- define "platform.labels" -}}
app.kubernetes.io/part-of: platform
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/instance: {{ .Release.Name }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" }}
environment: {{ .Values.global.environment }}
{{- end -}}

{{/*
Selector labels for a given component. Call as:
  {{- include "platform.selectorLabels" (dict "root" $ "component" "api") }}
*/}}
{{- define "platform.selectorLabels" -}}
app.kubernetes.io/name: {{ .component }}
app.kubernetes.io/instance: {{ .root.Release.Name }}
{{- end -}}

{{/*
Postgres connection host, depending on whether the bundled Bitnami subchart
or an external (e.g. RDS) database is in use.
*/}}
{{- define "platform.postgresHost" -}}
{{- if .Values.postgresql.enabled -}}
{{ .Release.Name }}-postgresql
{{- else -}}
{{ .Values.externalDatabase.host }}
{{- end -}}
{{- end -}}

{{/*
Redis connection host, depending on whether the bundled Bitnami subchart or
an external (e.g. ElastiCache) Redis is in use.
*/}}
{{- define "platform.redisHost" -}}
{{- if .Values.redis.enabled -}}
{{ .Release.Name }}-redis-master
{{- else -}}
{{ .Values.externalRedis.host }}
{{- end -}}
{{- end -}}
