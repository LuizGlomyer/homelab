terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "~> 0.45"
    }
  }
}

provider "proxmox" {
  endpoint = "https://192.168.0.99:8006/api2/json"
  insecure = true # Skip TLS
  username = var.pve_user
  password = var.pve_password
}