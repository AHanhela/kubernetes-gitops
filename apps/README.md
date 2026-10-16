# Applications

Flux reads `apps/monitoring` through `clusters/k3s-gitops/apps.yaml`.

`apps/monitoring/kustomization.yaml` currently includes only the `monitoring` namespace. Helm releases will be added later.

Podinfo remains managed separately under `clusters/k3s-gitops`.
