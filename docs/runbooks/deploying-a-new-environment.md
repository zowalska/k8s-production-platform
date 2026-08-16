# Runbook: Deploying a new environment

Steps to stand up a brand-new environment (e.g. a temporary `preview`
environment), using `staging` as a template.

1. **Terraform**: copy `terraform/environments/staging` to
   `terraform/environments/<env>`, update `backend.tf`'s state `key`,
   adjust `terraform.tfvars` sizing, then:
   ```sh
   cd terraform/environments/<env>
   terraform init
   terraform apply
   ```
   Note the outputs: EKS cluster name/endpoint, RDS endpoint + Secrets
   Manager ARN, ElastiCache endpoint + Secrets Manager ARN.
2. **Namespace + Pod Security Admission**: copy
   `security/namespaces/platform-staging.yaml` to
   `security/namespaces/platform-<env>.yaml`, update the name/labels, apply:
   ```sh
   kubectl apply -f security/namespaces/platform-<env>.yaml
   ```
3. **Vault**: add a new `platform-<env>-api` / `platform-<env>-worker`
   policy + role pair - see `security/vault/auth/kubernetes-auth-setup.sh`
   and duplicate the staging block. Seed the secrets (using the real
   Terraform RDS/ElastiCache outputs from step 1, not the example values in
   `security/vault/example-secrets/seed-example-secrets.sh`).
4. **Helm values**: copy `helm/platform/values-staging.yaml` to
   `helm/platform/values-<env>.yaml`, update `global.environment`,
   `externalDatabase.host` / `externalRedis.host`, and the Vault
   `role`/`secretPath` fields.
5. **Argo CD Application**: copy
   `argocd/applications/platform-staging.yaml` to
   `argocd/applications/platform-<env>.yaml`, update `destination.namespace`
   and the `valueFiles` entry to point at `values-<env>.yaml`.
6. **Monitoring**: optionally add a `values-<env>.yaml` under
   `monitoring/kube-prometheus-stack/` if sizing should differ from an
   existing environment; otherwise reuse `values-staging.yaml`.
7. Commit and push - Argo CD's `root-app` (app-of-apps,
   `argocd/bootstrap/root-app.yaml`) picks up the new Application manifest
   automatically since it watches `argocd/applications/` recursively.
