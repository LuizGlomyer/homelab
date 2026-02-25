# Ansible

All playbooks are fully functional on Debian 12 (Bookworm). Most playbooks execute normally on Debian 13 (Trixie), but some fails. APIs get deprecated, so there are no guarantees.

## Dependencies

You might need some other software on your controller node (your machine):

- sshpass
- Ansible collections (install with `ansible-galaxy collection install [collection]`)
  - community.general
  - community.docker
  - ansible.posix
- [Ansible-lint](https://ansible.readthedocs.io/projects/lint/installing/#installing-the-latest-version)


# Ansible vault

Secrets are managed by Ansible vault. Here's how to set it up:

- Make a copy of both [vault.yml.example](group_vars/all/vault.yml.example) and [vault_pass.txt.example](group_vars/all/vault_pass.txt.example)
- Remove .example from their filenames
- Put your vault password and secrets into the files
- Encrypt your vault with the following command:

```bash
ansible-vault encrypt group_vars/all/vault \
--vault-password-file group_vars/all/vault_pass.txt

# Or decrypt later when needed
ansible-vault decrypt group_vars/all/vault.yml \
--vault-password-file group_vars/all/vault_pass.txt
``` 


# Running the playbooks

There are multiple Ansible roles, one for each service or specific configuration. One of them is named [extract_metadata](/roles/extract_metadata/tasks/main.yml), it lays the groundwork for setting up some needed variables, thus helping other roles. For simplicity containerized roles don't depend on Docker in their task files, so you must run the docker role at least once to ensure that Docker is properly installed. Generally, each role can be ran individually by using tags (configured as their own name).

Execution example:

```bash
ansible-playbook playbooks/create_template.yml \
--vault-password-file group_vars/all/vault_pass.txt

# If you didn't configure ssh keys you need to authenticate with credentials
# Tags usage bellow
ansible-playbook playbooks/main.yml \
--user pi \ 
--ask-pass \
--ask-become-pass \
--vault-password-file group_vars/all/vault_pass.txt \
--tags navidrome \ 
--skip-tags apt,docker

# Just copy your ssh key to the host, it's easier this way
ssh-copy-id -i ~/.ssh/id_ed25519.pub root@192.168.0.99
```

Some playbooks may set up things that are later used by other playbooks. Therefore, this is the recommended order to run them:

- update_packages
- install_host_applications
- start_containers
- Any other playbooks


# Useful links

- https://docs.ansible.com/projects/ansible/latest/playbook_guide/playbooks_intro.html#playbook-syntax