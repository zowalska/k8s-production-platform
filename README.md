# k8s-production-platform

[![CI](https://github.com/zowalska/k8s-production-platform/actions/workflows/ci.yml/badge.svg)](https://github.com/zowalska/k8s-production-platform/actions/workflows/ci.yml)
[![Security Scan](https://github.com/zowalska/k8s-production-platform/actions/workflows/security.yml/badge.svg)](https://github.com/zowalska/k8s-production-platform/actions/workflows/security.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A production-grade, cloud-native platform blueprint demonstrating a complete
GitOps delivery pipeline: from a developer's commit to a fully observable,
auto-scaling application running on Kubernetes.

This repository is a **portfolio / reference implementation** — every layer
(infrastructure, application, delivery, security, observability) is wired
together the way it would be in a real production environment.

## Architecture

```
Developer
   │
   ▼
GitHub  ── source of truth (this repo)
   │
   ▼
GitHub Actions
   │
   ├── Test               (unit tests, lint)
   ├── Security Scan       (CodeQL, Trivy, tfsec/checkov, gitleaks)
   ├── Build                (multi-stage Docker builds)
   └── Push Image           (signed with cosign, SBOM attached)
          │
          ▼
   Container Registry (GHCR)
          │
          ▼
       Argo CD  ── GitOps continuous delivery (app-of-apps pattern)
          │
          ▼
    Kubernetes Cluster (Amazon EKS, provisioned via Terraform)
       ┌──┴───┐
       ▼      ▼
     App    Worker        ── HPA + KEDA event-driven autoscaling
       │
       ▼
  PostgreSQL / Redis        ── Bitnami Helm subcharts

Observability
     │
     ├── Prometheus   ── metrics + alerting (kube-prometheus-stack)
     ├── Grafana      ── dashboards
     └── Loki         ── log aggregation (Promtail agents)

Secrets Management
     └── HashiCorp Vault (Agent Injector, Kubernetes auth)
```

## Tech stack

| Layer                  | Technology |
|------------------------|------------|
| Application            | Node.js (Express API + BullMQ worker) |
| Data stores            | PostgreSQL, Redis |
| Containers             | Docker (multi-stage, non-root, distroless-style runtime) |
| CI/CD                  | GitHub Actions |
| Container Registry     | GitHub Container Registry (ghcr.io) |
| GitOps / CD            | Argo CD (app-of-apps pattern) |
| Orchestration           | Kubernetes (Amazon EKS) |
| Packaging               | Helm (umbrella chart) + Kustomize (local/dev overlays) |
| Infrastructure as Code  | Terraform (VPC, EKS, RDS, ElastiCache, IAM/IRSA) |
| Autoscaling             | HPA, KEDA (event-driven), Cluster Autoscaler, VPA (recommend-only) |
| Secrets management      | HashiCorp Vault (Agent Injector + Kubernetes auth) |
| Observability            | Prometheus, Grafana, Loki, Alertmanager |
| Security                 | CodeQL, Trivy, tfsec, Checkov, gitleaks, Dependabot |

## Repository structure

```
apps/                Application source code (api, worker)
kubernetes/           Kustomize base + per-environment overlays
helm/                 Umbrella Helm chart (api, worker, postgresql, redis)
terraform/            AWS infrastructure modules + per-environment stacks
argocd/               Argo CD AppProject + Application manifests (app-of-apps)
autoscaling/          KEDA, Cluster Autoscaler, VPA configuration
security/vault/       HashiCorp Vault policies, roles, Helm values
security/kyverno/     Kyverno policy-as-code (admission-time guardrails)
security/namespaces/  Namespace manifests with Pod Security Admission labels
monitoring/           Prometheus, Grafana dashboards, Loki/Promtail config
.github/workflows/    CI, security scanning, build & push, Terraform, releases
docs/                 Architecture notes, ADRs, runbooks
```

## Getting started

```sh
make install        # npm install for both services
make test            # run api + worker unit tests
make compose-up       # full local stack: api + worker + postgres + redis
make helm-lint        # lint the Helm chart against every environment
```

See [`docs/architecture.md`](docs/architecture.md) for a deeper walkthrough
and [`docs/adr/`](docs/adr/) for the reasoning behind the less obvious
choices (Helm as the GitOps artifact, Vault vs. External Secrets, Kyverno
vs. OPA/Gatekeeper, KEDA for worker autoscaling, EKS on AWS).

## Environments

The platform is designed to run three independent environments — `dev`,
`staging`, and `prod` — each with its own Terraform state, Kubernetes
namespace (`platform-dev` / `platform-staging` / `platform-prod`), and Helm
values overlay, promoted through Argo CD Applications.

## Status

✅ Feature-complete reference build: application services, containerization,
Kubernetes manifests (Kustomize + Helm), Terraform infrastructure, full
CI/CD pipeline, GitOps delivery via Argo CD, layered autoscaling, Vault
secrets management, Kyverno policy-as-code, and a complete observability
stack. See the commit history for the incremental build-out story, and
[`CONTRIBUTING.md`](CONTRIBUTING.md) if you'd like to extend it further.

## License

[MIT](LICENSE)
