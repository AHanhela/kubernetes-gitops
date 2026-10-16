# Flux and GitOps

Flux reconciles the Kubernetes configuration under `clusters/k3s-gitops` from the `main` branch.

## Bootstrap and reconciliation

Flux `v2.9.5` was installed with `flux bootstrap github`. The command generated the files under `clusters/k3s-gitops/flux-system`.

Those manifests install the default Flux controllers:

- source-controller
- kustomize-controller
- helm-controller
- notification-controller

The bootstrap also created the `GitRepository` and `Kustomization` resources that connect the cluster to this repository. Flux generated the files under `flux-system/`, so they should not be edited by hand.

Changes to Flux-managed Kubernetes resources are committed to Git. Flux reads the new revision and reconciles the desired state to the cluster.

## Applications

`clusters/k3s-gitops/apps.yaml` defines the Flux `Kustomization/apps` resource. It reads `apps/monitoring` from the existing `GitRepository/flux-system`.

`apps/monitoring` installs Prometheus and Grafana with Flux `HelmRepository` and `HelmRelease` resources.

## GitOps tests

Podinfo was used as a temporary test workload. On 16 October 2026:

- A Git change added `gitops-test: desired` through the Podinfo Flux Kustomization's `commonMetadata.annotations`. The `flux-system` reconciliation applied revision `bf670014`, and the Deployment annotation returned `desired`.
- The Deployment annotation was changed directly in the cluster to `modified`, which was confirmed by reading it back.
- `flux reconcile kustomization podinfo -n flux-system` restored the annotation to `desired`.

The drift correction was triggered manually. This test does not measure the interval for unattended correction.

Podinfo was removed from the repository after these checks. Deletion of its cluster resources through Flux pruning is checked separately after reconciliation.

## Checks

Check the Flux installation:

```bash
flux check
```

Check Flux sources and Kustomizations:

```bash
flux get all -A
```

Check Kubernetes workloads:

```bash
kubectl get pods -A
```

After the application path has reconciled:

```bash
flux get kustomizations -A
kubectl get namespace monitoring
```

Official references: [Flux documentation](https://fluxcd.io/flux/) and [GitHub bootstrap documentation](https://fluxcd.io/flux/installation/bootstrap/github/).
