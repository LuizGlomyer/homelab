variable "VMs" {
  description = "VM definitions for the homelab"
  type = map(object({
    vm_id       = number
    hostname    = string
    ipv4        = string
    template_id = number
  }))

  default = {
    debian12-01 = {
      vm_id       = 200
      hostname    = "debian12-01"
      ipv4        = "192.168.0.200/24"
      template_id = 9000
    }

    debian13-01 = {
      vm_id       = 201
      hostname    = "debian13-01"
      ipv4        = "192.168.0.201/24"
      template_id = 9001
    }
  }
}


resource "proxmox_virtual_environment_file" "cloudinit" {
  for_each = var.VMs

  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.pve_node_name

  source_raw {
    file_name = "${each.key}-cloudinit.yaml"

    data = templatefile(
      "${path.module}/../../cloud-init/debian.yaml.tpl",
      {
        hostname = each.value.hostname
        user     = var.vm_username
        ssh_key  = file(var.ssh_public_key_path)
      }
    )
  }
}


resource "proxmox_virtual_environment_vm" "debian12" {
  for_each = var.VMs

  node_name = var.pve_node_name
  name      = each.value.hostname
  vm_id     = each.value.vm_id

  started                              = true
  machine                              = "q35"
  stop_on_destroy                      = true
  purge_on_destroy                     = true
  delete_unreferenced_disks_on_destroy = true

  clone {
    vm_id = each.value.template_id
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = 4096
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-lvm"
    interface    = "scsi0"
    size         = 10
  }

  initialization {
    user_data_file_id = proxmox_virtual_environment_file.cloudinit[each.key].id

    ip_config {
      ipv4 {
        address = each.value.ipv4
        gateway = "192.168.0.1"
      }
    }
  }
}
