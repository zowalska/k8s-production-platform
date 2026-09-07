.PHONY: help install test lint compose-up compose-down helm-lint helm-template kustomize-dev kustomize-staging kustomize-prod

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies for both services
	cd apps/api && npm install
	cd apps/worker && npm install

test: ## Run unit tests for both services
	cd apps/api && npm test
	cd apps/worker && npm test

lint: ## Lint both services
	cd apps/api && npm run lint
	cd apps/worker && npm run lint

compose-up: ## Start the local dev stack (api+worker+postgres+redis)
	docker compose up --build -d

compose-down: ## Stop the local dev stack
	docker compose down -v

helm-lint: ## Lint the Helm chart against every environment's values
	helm dependency update helm/platform
	helm lint helm/platform -f helm/platform/values.yaml -f helm/platform/values-dev.yaml
	helm lint helm/platform -f helm/platform/values.yaml -f helm/platform/values-staging.yaml
	helm lint helm/platform -f helm/platform/values.yaml -f helm/platform/values-prod.yaml

helm-template: ## Render the Helm chart for the dev environment
	helm template platform-dev helm/platform -f helm/platform/values.yaml -f helm/platform/values-dev.yaml -n platform-dev

kustomize-dev: ## Render the dev Kustomize overlay
	kubectl kustomize kubernetes/overlays/dev

kustomize-staging: ## Render the staging Kustomize overlay
	kubectl kustomize kubernetes/overlays/staging

kustomize-prod: ## Render the prod Kustomize overlay
	kubectl kustomize kubernetes/overlays/prod
