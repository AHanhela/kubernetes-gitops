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

`apps/monitoring/kustomization.yaml` currently applies only the `monitoring` namespace. Monitoring Helm releases will be added separately.

Podinfo remains managed by its own Flux Kustomization under `clusters/k3s-gitops`.

## Podinfo test

Podinfo is used only to verify the GitOps reconciliation path.

`podinfo-source.yaml` defines the upstream Podinfo repository as a Flux `GitRepository`. `podinfo-kustomization.yaml` tells Flux to apply the upstream `kustomize` directory.

The test added both resources to the `main` branch. Flux detected the new revision, fetched the Podinfo source and created the workload in the cluster. No `kubectl apply` command was used for the Podinfo workload.

The `flux-system` and `podinfo` GitRepository and Kustomization resources reached the Ready state. Flux also created two Podinfo pods, and both reached the Running state.

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
