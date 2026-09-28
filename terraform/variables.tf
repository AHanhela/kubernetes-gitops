variable "subscription_id" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "lab_name" {
  type = string
}

variable "virtual_network_name" {
  type = string
}

variable "subnet_name" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "ssh_public_key_path" {
  type = string
}

variable "nodes" {
  type = map(string)
}
