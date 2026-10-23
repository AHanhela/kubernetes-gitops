# Kubernetes GitOps

Terraform, Ansible and Flux configuration for a bachelor's thesis on deploying a Kubernetes cluster and managing it with GitOps. The implementation runs K3s in Azure DevTest Labs. Flux deploys a Prometheus and Grafana monitoring stack from Git, with Grafana credentials encrypted using SOPS and age.

## Implementation

```text
Existing Azure DevTest Lab and virtual network
                 |
                 v
Terraform -> five Ubuntu virtual machines
                 |
                 v
Ansible + k3s-ansible -> K3s (3 servers, 2 agents)
                 |
                 v
Flux <- Git configuration (clusters/ and apps/)
                 |
                 v
kube-prometheus-stack -> Prometheus and Grafana
```

The three K3s server nodes run the Kubernetes control plane and embedded etcd. The two agent nodes run workloads. Terraform manages only the five cluster VMs, not the existing lab or network.

The implementation uses Terraform 1.16, AzureRM provider 5.7.0, Ubuntu Server 24.04 LTS, Ansible Core 2.19.13, `k3s-ansible` 1.2.2, K3s `v1.36.4+k3s1` and Flux `v2.9.5`. The monitoring application uses the `kube-prometheus-stack` Helm chart, version `92.10.0`.

## Where to find the configuration

- [`terraform/`](terraform/README.md) creates the five VMs and documents the existing Azure prerequisites.
- [`ansible/`](ansible/README.md) installs K3s using the upstream `k3s-ansible` collection.
- [`clusters/`](clusters/README.md) contains the Flux bootstrap configuration, reconciliation paths and GitOps test results.
- [`apps/`](apps/README.md) contains the monitoring installation, Grafana dashboard and SOPS-encrypted credentials.

## Reproducing the implementation

1. Use an existing Azure DevTest Lab and virtual network. Create the local Terraform variables from `terraform/terraform.tfvars.example` and provision the VMs.
2. Create the local Ansible inventory from `ansible/inventory.example.yml` and install K3s.
3. Bootstrap Flux against the chosen Git repository and configure it to reconcile the cluster manifests.
4. Supply the SOPS age private key to Flux through the `flux-system/sops-age` Secret, then let the `apps` Kustomization apply the monitoring configuration.
5. Verify the cluster, Flux resources and monitoring application using the checks in the directory READMEs.

The directory READMEs provide the commands and file paths. Credentials, Terraform state, local variables, the Ansible inventory and the age private key are not stored in Git. Reproducing the deployment requires access to the Azure prerequisites and suitable credentials. The encrypted Grafana Secret cannot be decrypted from the repository alone.

## Tested results

Terraform created five VMs in the existing lab. Ansible installed K3s, and all five nodes reached the Ready state. Flux reconciled the monitoring manifests, and Prometheus and Grafana started. The Grafana dashboard showed five Ready nodes with per-node CPU and memory metrics. SOPS-protected Grafana credentials were deployed and a browser login was verified.

Two tests used the Grafana dashboard itself: Flux repaired a direct change to its ConfigMap without a manual reconciliation command, and a Git revert restored a deliberately incorrect dashboard query. See [Flux and GitOps tests](clusters/README.md#gitops-tests) for the observations and their limits.
