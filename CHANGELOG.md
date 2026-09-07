# Changelog

This project was built incrementally; each entry below corresponds to one
milestone in the commit history (see `git log --oneline` for exact commits).

## [Unreleased]

### Added
- Initial project scaffolding and architecture overview
- `api` service: Express REST API with Postgres, BullMQ producer, Prometheus metrics
- `worker` service: BullMQ job processor with Postgres updates and Prometheus metrics
- Multi-stage Dockerfiles (non-root runtime) and docker-compose for local dev
- Kubernetes base manifests and per-environment Kustomize overlays (dev/staging/prod)
- Umbrella Helm chart with Vault-injected secrets and Bitnami postgresql/redis dependencies
- Terraform: remote state bootstrap, VPC, EKS, RDS, ElastiCache, observability IRSA, per-environment stacks
- GitHub Actions: CI (test/lint/manifest validation), security scanning (CodeQL/Trivy/tfsec/Checkov/gitleaks), build & push (GHCR, SBOM, cosign), Terraform plan/apply, Helm chart releases
- Argo CD app-of-apps: AppProject, bootstrap root Application, per-environment platform Applications
- Advanced autoscaling: KEDA event-driven worker scaling, Cluster Autoscaler, VPA (recommend-only)
- HashiCorp Vault secrets management: Agent Injector, Kubernetes auth, per-environment least-privilege policies
- Observability stack: kube-prometheus-stack (Prometheus/Alertmanager), Grafana dashboards, Loki/Promtail logging
- Security hardening: Kyverno policy-as-code, Pod Security Admission baselines
- Documentation: architecture guide, ADRs, per-alert operational runbooks
