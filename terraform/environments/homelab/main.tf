resource "proxmox_virtual_environment_file" "cloudinit" {
  content_type = "snippets"
  datastore_id = "local"
  node_name    = "pve"

  source_raw {
    file_name = "debian-cloudinit.yaml"
    data = templatefile(
      "${path.module}/../../cloud-init/debian.yaml.tpl",
      {
        hostname = "debian-test-01"
        user     = "glomyer"
        ssh_key  = file(var.ssh_public_key_path)
      }
    )
  }
}


resource "proxmox_virtual_environment_vm" "vm" {
  node_name = "pve"
  name      = "debian-test-01"
  vm_id     = 200

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
    cores = 2
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

    user_account {
      username = "glomyer"
      keys     = [file(var.ssh_public_key_path)]
    }

    ip_config {
      ipv4 {
        address = "192.168.0.200/24"
        gateway = "192.168.0.1"
      }
    }
  }
}
