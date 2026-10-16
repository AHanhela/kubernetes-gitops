# Applications

Flux reconciles `apps/monitoring` through `clusters/k3s-gitops/apps.yaml`.

`apps/monitoring` installs the upstream `kube-prometheus-stack` Helm chart with Prometheus, Grafana, kube-state-metrics, and node-exporter. The chart version is pinned in `helmrelease.yaml`.

The installation uses the K3s `local-path` storage class. Grafana has no public Ingress and can be accessed through `kubectl port-forward`. Loki is not installed.
