# Terraform

Terraform creates the five Ubuntu virtual machines used by the K3s cluster.

## Scope

Terraform manages only the VMs created for this implementation. The Azure DevTest Lab and DevTest Lab virtual network already exist and are read as data sources. Terraform does not manage unrelated VMs in the lab.

`main.tf` uses one `azurerm_dev_test_linux_virtual_machine` resource with `for_each`. The `nodes` map defines the name and size of each VM. All five VMs use Ubuntu Server 24.04 LTS and SSH public-key authentication.

The relevant files are:

- `main.tf` for the AzureRM provider, data sources and VM resource
- `variables.tf` for input variables
- `terraform.tfvars.example` for the required environment-specific values
- `.terraform.lock.hcl` for the pinned provider version and checksums

Git ignores the local `terraform.tfvars`, Terraform state and the `.terraform/` working directory.

## Usage

Create the local variable file:

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Set the subscription, DevTest Lab, virtual network, subnet, SSH user, public key path and VM sizes in `terraform/terraform.tfvars`.

Initialize Terraform:

```bash
terraform -chdir=terraform init
```

Validate the configuration:

```bash
terraform -chdir=terraform validate
```

Review the plan:

```bash
terraform -chdir=terraform plan
```

Create or update the VMs:

```bash
terraform -chdir=terraform apply
```

Review a destroy operation before running it:

```bash
terraform -chdir=terraform plan -destroy
```

Keep Terraform state outside Git.

## Tested result

The Terraform configuration created all five cluster VMs in the existing DevTest Lab without changing the lab or its virtual network.

Official references: [Terraform documentation](https://developer.hashicorp.com/terraform) and [AzureRM provider documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs).
