# Terraform

Terraform, automates the provisioning of Debian-based virtual machines using the Proxmox provider. The [main.tf](/terraform/environments/homelab/main.tf) file defines VM parameters (ID, hostname, IP, template) in a centralized map, enabling scalable and consistent deployments. Each VM is cloned from a specified template (created by the [proxmox_template](/ansible/roles/proxmox_template/tasks/main.yml) role), initialized with custom [cloud-init YAML](/terraform/cloud-init/debian.yaml.tpl) (including hostname, user, and SSH key), and configured with dedicated CPU, memory, storage, and network settings. The setup leverages Proxmox's API for secure orchestration, supports idempotent operations, and integrates with the infrastructure as code workflow for reproducible VM management. [BPG](https://github.com/bpg/terraform-provider-proxmox) is the provider used.

I've ran into some issues relating to exposing the VMs to the network. The Proxmox templates I use are cloud images configured with cloud-init. QEMU only exposes the network interfaces if installed directly in the [cloud-init template](/terraform/cloud-init/debian.yaml.tpl). The command `terraform apply` will not stop until the interfaces are published. Today it takes like 4 minutes if I boot up 2 new VMs, or 1 minute and a half if I restart a VM.


## Useful CLI commands

```bash
terraform plan
terraform apply
terraform destroy

# Recreated VMs rotate credentials, this is useful when attempting to ssh into them
ssh-keygen -R 192.168.0.200

# Displays the resource addresses for all resources that Terraform is currently managing
terraform state list

# Removes a single resource from the state, useful if definitions get desynced (for example, a VM destroyed via Proxmox)
terraform destroy -target='proxmox_virtual_environment_vm.debian_vms["debian12-01"]'
# Replacing a resource is a more elegant solution
terraform apply -replace='proxmox_virtual_environment_vm.debian_vms["debian12-01"]'
```

# Useful links

- https://registry.terraform.io/providers/bpg/proxmox/latest/docs
- https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm
- https://registry.terraform.io/providers/bpg/proxmox/latest/docs/guides/cloud-init