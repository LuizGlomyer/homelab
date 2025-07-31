# homelab

This repository is my home server setup. I'm mainly using Ansible to do provisining and configuration management, it is quite handy to centralize changes on my network.

Currently I have only one node acting as a server, a Raspberry Pi 4 with [Raspberry Pi OS](https://www.raspberrypi.com/software/), thus some configurations make use of arm64 binaries and Debian based utilities, such as apt.

Multiple services are defined using Ansible roles, most are containerized but there are host services as well.

| Adguard Home | Ad blocker & DNS resolver                        | Type      |
|--------------|--------------------------------------------------|-----------|
| Caddy        | Certificate Authority and HTTPS server           | Host      |
| Dashy        | Webpage for quick access to the network services | Container |
| Glances      | System processes & device status monitor         | Container |
| MeTube       | GUI for downloading videos with yt-dlp           | Container |
| OliveTin     | GUI for running shell commands                   | Host      |
| Pi-hole      | Ad blocker & DNS resolver                        | Container |
| Portainer    | Container management                             | Container |
| Stirling PDF | Local operations on .pdf files                   | Container |
| Uptime Kuma  | Online services monitor                          | Container |

# Dependencies

Aside from Ansible, you might need some other software on your controller node (your machine).

- sshpass
- [Ansible-lint](https://ansible.readthedocs.io/projects/lint/installing/#installing-the-latest-version)


# Initial configuration

## Ansible vault

Secrets are managed with Ansible vault. What needs to be done is the following:

- Make a copy of both [vault.yml.example](group_vars/all/vault.yml.example) and [vault_pass.txt.example](group_vars/all/vault_pass.txt.example)
- Remove .example from their filenames
- Put your vault password and secrets into the files
- Encrypt your vault with the following command:

```bash
ansible-vault encrypt group_vars/all/vault \
--vault-password-file group_vars/vault_pass.txt
``` 

## Raspberry Pi server

Upon booting the Raspberry, run ```sudo raspi-config``` and enable VNC to allow remote GUIs through the network. I'm currently using RealVNC Viewer to access my server.

![RealVNC Viewer](docs/images/vnc-viewer.png)

# Running the playbooks

There are multiple Ansible roles, one for each service and one named [common](/roles/common/tasks/main.yml) that lays the groundwork installing packages and Docker. Each role can be ran individually by using tags (configured as their own name).

```bash
ansible-playbook playbooks/main.yml \
--user pi \
--ask-pass \
--ask-become-pass \
--vault-password-file group_vars/all/vault_pass.txt \
--tags common # Optional but useful!
```
