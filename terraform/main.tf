terraform {
  required_version = "~> 1.16.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 5.7.0"
    }
  }
}

provider "azurerm" {
  features {}

  subscription_id                 = var.subscription_id
  resource_provider_registrations = "none"
}

data "azurerm_dev_test_lab" "target" {
  name                = var.lab_name
  resource_group_name = var.resource_group_name
}

data "azurerm_dev_test_virtual_network" "target" {
  name                = var.virtual_network_name
  lab_name            = var.lab_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_dev_test_linux_virtual_machine" "node" {
  for_each = var.nodes

  name                = each.key
  lab_name            = var.lab_name
  resource_group_name = var.resource_group_name
  location            = data.azurerm_dev_test_lab.target.location

  size         = each.value
  storage_type = "Standard"

  username = var.admin_username
  ssh_key  = file(pathexpand(var.ssh_public_key_path))

  lab_virtual_network_id = data.azurerm_dev_test_virtual_network.target.id
  lab_subnet_name        = var.subnet_name

  allow_claim                = false
  disallow_public_ip_address = false

  gallery_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server-gen1"
    version   = "latest"
  }
}
