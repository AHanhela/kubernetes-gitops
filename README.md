# Kubernetes GitOps

This repository contains the practical implementation for a bachelor's thesis on deploying and managing a Kubernetes cluster with GitOps. It contains the Terraform, Ansible and Flux configuration used in the implementation.

## Implementation

```text
Terraform
    |
    v
Azure DevTest Labs
    |
    v
5 Ubuntu virtual machines
    |
    v
Ansible + k3s-ansible
    |
    v
K3s
    |
    v
Flux
    |
    v
Kubernetes resources from Git
```

The cluster has three K3s server nodes and two agent nodes. The servers run the Kubernetes control plane and embedded etcd. The agents run workloads.

| Node | Kubernetes role |
| --- | --- |
| `k8s-gitops-cp-01` | control plane, etcd |
| `k8s-gitops-cp-02` | control plane, etcd |
| `k8s-gitops-cp-03` | control plane, etcd |
| `k8s-gitops-worker-01` | worker |
| `k8s-gitops-worker-02` | worker |

The implementation uses Terraform 1.16, AzureRM provider 5.7.0, Ubuntu Server 24.04 LTS, Ansible Core 2.19.13, `k3s-ansible` 1.2.2, K3s `v1.36.4+k3s1` and Flux `v2.9.5`.

Terraform manages only the five cluster VMs. The Azure DevTest Lab and its virtual network already exist. Ansible installs K3s on the VMs. Flux reconciles Kubernetes resources stored under `clusters/k3s-gitops`.

Local credentials, Terraform state, local Terraform variables and the local Ansible inventory are excluded from Git.

## Repository structure

```text
.
├── ansible/
├── apps/
├── clusters/
└── terraform/
```

Setup details are split by responsibility:

- [Terraform](terraform/README.md)
- [Ansible and K3s](ansible/README.md)
- [Flux and GitOps](clusters/README.md)
- [Applications](apps/README.md)

## Reproducing the implementation

1. Create the five VMs with Terraform.
2. Install K3s with Ansible and `k3s-ansible`.
3. Bootstrap Flux against this repository.
4. Commit Kubernetes configuration to Git and let Flux reconcile it.

The directory READMEs contain the commands and local files needed for each step.

## Validation

Terraform created the five VMs without changing the existing DevTest Lab or its virtual network. Ansible then bootstrapped three K3s server nodes and two worker nodes, and all five nodes reached the Ready state.

Flux was bootstrapped against the `main` branch. Podinfo was used to verify Git-driven deployment and correction of a manual configuration change. The temporary test workload was then removed from the repository.
