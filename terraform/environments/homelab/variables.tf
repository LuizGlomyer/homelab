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
