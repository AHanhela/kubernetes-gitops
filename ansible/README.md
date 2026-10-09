# Ansible and K3s

Ansible installs K3s on the five VMs created by Terraform. The repository uses the upstream [`k3s-ansible`](https://github.com/k3s-io/k3s-ansible) project as an Ansible Collection and pins it to version `1.2.2`.

`site.yml` imports the upstream `k3s.orchestration.site` playbook. The upstream roles are not copied into this repository.

## Cluster topology

The inventory defines three K3s servers and two agents.

```text
server
├── k8s-gitops-cp-01
├── k8s-gitops-cp-02
└── k8s-gitops-cp-03

agent
├── k8s-gitops-worker-01
└── k8s-gitops-worker-02
```

The servers run the Kubernetes control plane and embedded etcd. The agents run workloads.

The inventory pins K3s to `v1.36.4+k3s1`. Ansible gathers network facts from the nodes and uses the private IPv4 address of the first server as the K3s API endpoint during bootstrap.

## Dependencies and inventory

`requirements.txt` pins `ansible-core==2.19.13` and `netaddr==1.3.0`.

`requirements.yml` pins these Ansible Collections:

- `k3s.orchestration` 1.2.2
- `ansible.posix` 2.1.0
- `ansible.utils` 6.0.0
- `community.general` 11.4.2

`inventory.example.yml` contains the five-node layout without environment-specific SSH hostnames or usernames. Create the local inventory from the example:

```bash
cp ansible/inventory.example.yml ansible/inventory.yml
```

Set the SSH hostnames and user in `ansible/inventory.yml`. Git ignores this local file.

## Bootstrap

Create a Python virtual environment from the repository root:

```bash
python3 -m venv .venv
```

Install the Python packages:

```bash
.venv/bin/python -m pip install -r ansible/requirements.txt
```

Install the Ansible Collections:

```bash
.venv/bin/ansible-galaxy collection install \
  -r ansible/requirements.yml
```

Check the inventory:

```bash
.venv/bin/ansible-inventory \
  -i ansible/inventory.yml \
  --graph
```

Test SSH access:

```bash
.venv/bin/ansible all \
  -i ansible/inventory.yml \
  -m ping
```

Check the playbook syntax:

```bash
.venv/bin/ansible-playbook \
  ansible/site.yml \
  -i ansible/inventory.yml \
  --syntax-check
```

Install K3s:

```bash
.venv/bin/ansible-playbook \
  ansible/site.yml \
  -i ansible/inventory.yml \
  --forks=1
```

## Tested result

The bootstrap completed without failed or unreachable hosts. The resulting cluster had three Ready server nodes and two Ready worker nodes. The three servers formed the embedded etcd control plane.
