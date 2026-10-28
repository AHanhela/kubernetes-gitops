# Monitoring application

Flux applies `apps/monitoring` through [`Kustomization/apps`](../clusters/k3s-gitops/apps.yaml). The [`HelmRepository`](monitoring/helmrepository.yaml) and [`HelmRelease`](monitoring/helmrelease.yaml) resources install the upstream `kube-prometheus-stack` chart, version `92.10.0`.

## Metrics and dashboard

The stack includes Prometheus, Grafana, kube-state-metrics and node-exporter. Prometheus collects metrics from the K3s cluster and its nodes. Grafana visualizes them using the [`k3s-nodes-dashboard` ConfigMap](monitoring/k3s-node-dashboard.yaml), which defines panels for the number of Ready nodes and CPU and memory use per node.

The tested dashboard showed five Ready nodes and separate CPU and memory data for all five nodes. The Grafana and Prometheus workloads started, and their persistent volume claims were Bound.

Grafana uses a 1 GiB volume and Prometheus uses a 4 GiB volume with the K3s `local-path` storage class. Prometheus retention is set to two days. Alertmanager is disabled, Loki is not installed, and no public Ingress is configured for Grafana. Grafana can be accessed using `kubectl port-forward`.

## Grafana credentials

Grafana reads its administrator credentials from the `monitoring/grafana-admin-credentials` Kubernetes Secret. The [`grafana-admin.sops.yaml`](monitoring/grafana-admin.sops.yaml) file stores the Secret with its data encrypted using SOPS and age. Flux decrypts it when applying the `apps` Kustomization, and the HelmRelease references the resulting Secret.

The age private key is **not stored in Git**. Flux requires a `sops-age` Secret in the `flux-system` namespace with the private key under `identity.agekey`. This key must be supplied separately when rebuilding the cluster; the encrypted Secret cannot be recovered from the repository alone. Keep an independent secure backup of the key.

The committed `grafana-admin.sops.yaml` is encrypted for the age recipient used in the thesis environment. A new age key **cannot decrypt this file**. For a separate deployment, create your own age key, generate a Secret named `grafana-admin-credentials` with the `admin-user` and `admin-password` keys, encrypt its `data` or `stringData` with SOPS for your recipient, and replace the encrypted manifest in your own repository. Store the private key securely and install it in Flux as `flux-system/sops-age` before expecting the `apps` Kustomization to reconcile. Never commit the plaintext credentials. The [Flux SOPS guide](https://fluxcd.io/flux/guides/mozilla-sops/) shows the age encryption and key installation steps.

On 16 October 2026, Flux reconciled the SOPS change, the monitoring HelmRelease upgraded successfully and Grafana's Deployment referenced the credential Secret. A browser login using the decrypted credentials succeeded. This verified the credential migration, not password rotation. Grafana also stores administrator credentials in its persistent database, so updating the Kubernetes Secret alone is not a validated password-rotation method.

The [GitOps test record](../clusters/README.md#gitops-tests) describes the dashboard configuration correction and Git revert tests.

## Checks

```bash
flux get helmreleases -n monitoring
kubectl -n monitoring get pods
kubectl -n monitoring get configmap k3s-nodes-dashboard
```
