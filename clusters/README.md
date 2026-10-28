# Flux and GitOps

Flux reads Kubernetes configuration from the `main` branch of this repository and applies it to the K3s cluster.

## Bootstrap and reconciliation

Flux `v2.9.5` was installed with `flux bootstrap github`. It generated the files under [`clusters/k3s-gitops/flux-system/`](k3s-gitops/flux-system/), including manifests for the source-controller, kustomize-controller, helm-controller and notification-controller. These generated files should not be edited by hand.

To bootstrap a separate copy of this repository under a personal GitHub account, first configure cluster-admin access to the intended K3s cluster and a GitHub token with permission to manage that repository. Then run:

```bash
flux check --pre
flux bootstrap github \
  --owner=<your-github-username> \
  --repository=<your-repository-name> \
  --branch=main \
  --path=./clusters/k3s-gitops \
  --personal \
  --private=false
```

This runs against your copy, updates its generated Flux manifests and configures repository access. Do not bootstrap a test cluster against the original thesis repository. See the [official GitHub bootstrap instructions](https://fluxcd.io/flux/installation/bootstrap/github/) for token permissions and organization repositories.

The GitOps configuration uses one Git source and two Flux Kustomizations:

- `GitRepository/flux-system` fetches the repository's `main` branch.
- `Kustomization/flux-system` applies the configuration at `./clusters/k3s-gitops`, including the definition of the applications Kustomization.
- `Kustomization/apps`, defined in [`apps.yaml`](k3s-gitops/apps.yaml), reads `./apps/monitoring` from the same Git source. It applies the monitoring resources and decrypts their SOPS-encrypted Secret using the separately installed `sops-age` key.

The `apps` Kustomization checks its desired state every two minutes. This setting is a reconciliation interval, not a guaranteed recovery time.

The [monitoring configuration](../apps/README.md) uses Flux `HelmRepository` and `HelmRelease` resources to install Prometheus and Grafana. Its dashboard is stored in Git as a Kubernetes ConfigMap.

## GitOps tests

The monitoring dashboard was used for two controlled tests on 16 October 2026. Its Ready-node panel normally displayed five nodes.

**Unattended configuration correction.** A direct `kubectl patch` changed the dashboard ConfigMap's query from counting Ready nodes to counting non-Ready nodes. Git was left unchanged, and Grafana displayed an incorrect zero in the Ready-node panel. Flux restored the query from Git without a manual `flux reconcile` command. A check running at five-second intervals detected restoration of the ConfigMap **105 seconds** after the patch. This was not a measurement of Grafana's browser refresh time or a guaranteed maximum recovery time.

**Git-based configuration rollback.** The incorrect query was then committed to Git, applied by Flux and observed in Grafana. A `git revert` restored the previous query in the repository. Flux applied that restored configuration, and Grafana displayed five Ready nodes again. This tested rollback of one dashboard query, not a Helm chart or application version.

An earlier smoke test used the temporary Podinfo workload. Git-driven deployment worked, and a manually invoked `flux reconcile` restored a changed annotation. Removing the workload from Git also removed its managed Kubernetes resources. That test did not demonstrate unattended drift correction; Podinfo was removed after testing.

## Checks

Check the Flux installation and resources:

```bash
flux check
flux get all -A
```

Check the Kustomizations and monitoring namespace:

```bash
flux get kustomizations -A
kubectl get namespace monitoring
kubectl get pods -A
```

Official references: [Flux documentation](https://fluxcd.io/flux/) and [GitHub bootstrap documentation](https://fluxcd.io/flux/installation/bootstrap/github/).
