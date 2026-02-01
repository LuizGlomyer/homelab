variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "/home/glomyer/.ssh/id_ed25519.pub"
}

variable "pve_user" {
  description = "Path to SSH public key"
  type        = string
  default     = "root@pam"
}

variable "pve_password" {
  description = "Path to SSH public key"
  type        = string
  sensitive   = true
}


variable "pve_node_name" {
  description = "Name of the Proxmox node"
  type        = string
  default     = "pve"
}

variable "vm_hostname" {
  description = "Hostsname of the Debian VM"
  type        = string
  default     = "homelab-debian-01"
}

variable "vm_username" {
  description = "Username for the VM"
  type        = string
  default     = "glomyer"
}
