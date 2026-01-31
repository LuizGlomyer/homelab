#cloud-config
hostname: ${hostname}
manage_etc_hosts: true

users:
  - name: ${user}
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh-authorized-keys:
      - ${ssh_key}

package_upgrade: true
packages:
  - qemu-guest-agent
  - net-tools
  - curl

runcmd:
  - systemctl enable --now qemu-guest-agent
  - systemctl start qemu-guest-agent
