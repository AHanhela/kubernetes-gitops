# Applications

Flux reconciles `apps/k3s-gitops` through `clusters/k3s-gitops/apps.yaml`.

`apps/k3s-gitops/kustomization.yaml` lists the applications for this cluster. `apps/monitoring` currently creates only the `monitoring` namespace. Monitoring Helm releases will be added separately.

The Podinfo smoke test remains under `clusters/k3s-gitops`.
