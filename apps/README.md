# Applications

Flux reconciles `apps/k3s-gitops` through `clusters/k3s-gitops/apps.yaml`.

The cluster entry point includes `apps/monitoring`, which creates the `monitoring` namespace. No Helm releases are defined yet.

The Podinfo smoke test remains under `clusters/k3s-gitops`.
