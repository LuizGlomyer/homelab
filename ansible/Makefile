.PHONY: caddy encrypt decrypt

encrypt:
	ansible-vault encrypt group_vars/all/vault.yml

decrypt:
	ansible-vault decrypt group_vars/all/vault.yml

caddy:
	ansible-playbook playbooks/install_host_applications.yml --tags caddy

nas:
	ansible-playbook playbooks/nas_setup.yml --limit NasHost

nas-client:
	ansible-playbook playbooks/nas_setup.yml --limit ServicesHost

lint:
	ansible-lint --fix playbooks/*.yml
