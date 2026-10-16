# Applications

Flux reconciles `apps/monitoring` through `clusters/k3s-gitops/apps.yaml`.

`apps/monitoring` installs the upstream `kube-prometheus-stack` Helm chart with Prometheus, Grafana, kube-state-metrics, and node-exporter. The chart version is pinned in `helmrelease.yaml`.

The installation uses the K3s `local-path` storage class. Grafana has no public Ingress and can be accessed through `kubectl port-forward`. Loki is not installed.

## Grafana credentials

Grafana uses the `monitoring/grafana-admin-credentials` Kubernetes Secret for its administrator credentials. The Secret is committed as `grafana-admin.sops.yaml` with its data encrypted using SOPS and age. Flux decrypts it through the `apps` Kustomization before the HelmRelease uses it.

The age private key is **not in Git**. Flux requires a `sops-age` Secret in `flux-system`, with its age identity stored as `identity.agekey`. Recover or install this key separately before reconciling the application after rebuilding a cluster. Retain an independent secure backup of the private key.

On 16 October 2026, Flux reconciled the SOPS change, `apps` and `flux-system` reported Ready, `kube-prometheus-stack` successfully upgraded, and Grafana's Deployment referenced `grafana-admin-credentials`. The browser login check after migration and private-key backup confirmation were still pending at this point.

Grafana stores its administrator password in its persistent database. Updating the Kubernetes Secret alone is not a tested password-rotation procedure.
