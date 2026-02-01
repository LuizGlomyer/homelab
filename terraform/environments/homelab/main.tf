resource "proxmox_virtual_environment_file" "cloudinit" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = var.pve_node_name

  source_raw {
    file_name = "debian-cloudinit.yaml"
    data = templatefile(
      "${path.module}/../../cloud-init/debian.yaml.tpl",
      {
        hostname = var.vm_hostname
        user     = var.vm_username
        ssh_key  = file(var.ssh_public_key_path)
      }
    )
  }
}


resource "proxmox_virtual_environment_vm" "debian" {
  node_name = var.pve_node_name
  name      = var.vm_hostname
  vm_id     = 200

  started                              = true
  machine                              = "q35"
  stop_on_destroy                      = true
  purge_on_destroy                     = true
  delete_unreferenced_disks_on_destroy = true

  clone {
    vm_id = 9000
    full  = true
  }

  agent {
    enabled = true
  }

  cpu {
    cores = 4
  }

  memory {
    dedicated = 2048
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
    user_data_file_id = proxmox_virtual_environment_file.cloudinit.id

    ip_config {
      ipv4 {
        address = "192.168.0.200/24"
        gateway = "192.168.0.1"
      }
    }
  }
}
