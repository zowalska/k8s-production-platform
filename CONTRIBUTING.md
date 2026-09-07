# Contributing

Thanks for considering a contribution to this reference platform! It's
primarily a portfolio/learning project, but issues and PRs that improve
correctness, clarity, or fill in a gap are welcome.

## Development setup

```sh
# api
cd apps/api && npm install && npm test

# worker
cd apps/worker && npm install && npm test

# full local stack (api + worker + postgres + redis)
docker compose up --build
```

## Before opening a PR

- [ ] `npm run lint && npm test` passes for any changed service under `apps/`
- [ ] `helm lint helm/platform -f helm/platform/values-dev.yaml` passes if you touched the Helm chart
- [ ] `kubectl kustomize kubernetes/overlays/<env>` renders cleanly if you touched Kustomize manifests
- [ ] `terraform fmt -recursive && terraform validate` if you touched `terraform/`
- [ ] Documentation updated if the change affects architecture, runbooks, or ADR-worthy decisions (see `docs/`)

## Commit style

Commits in this repo's history are grouped by milestone (one logical
capability per commit - see `git log --oneline` for the build-out story).
For new contributions, prefer focused commits over one giant diff, and
write an imperative-mood summary line (`Add X`, `Fix Y`, not `Added X`).

## Code of conduct

Be respectful and constructive. Disagreements about technical approach are
fine and expected; keep the discussion focused on the work.
