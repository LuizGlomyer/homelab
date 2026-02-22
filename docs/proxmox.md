# Proxmox 

My main server uses [Proxmox](https://www.proxmox.com/en/) to create Virtual Machines (VMs) exposed to the network. You might need to activate VT-d in system BIOS for virtualization to work.

## Post installation configs

[This script](https://community-scripts.github.io/ProxmoxVE/scripts?id=post-pve-install) provides options for managing Proxmox VE repositories, including disabling the Enterprise Repo, adding or correcting PVE sources, enabling the No-Subscription Repo, adding the test Repo, disabling the subscription nag, updating Proxmox VE, and rebooting the system.

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/tools/pve/post-pve-install.sh)"
```

Enable snippets on pve node. Edit the file with `nano /etc/pve/storage.cfg` and paste:

```
dir: local
    path /var/lib/vz
    content backup,iso,vztmpl,snippets
```
# Usefull links

- https://www.proxmox.com/en/downloads/proxmox-virtual-environment
- https://community-scripts.github.io/ProxmoxVE/