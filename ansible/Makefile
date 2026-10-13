.PHONY: encrypt decrypt lint host caddy olivetin restic container adguard_home dashy diun file_browser glances jellyfin metube navidrome pinchflat pihole portainer stirling_pdf tubearchivist uptime_kuma vaultwarden vikunja nas nas-client

# Ansible commands

encrypt:
	ansible-vault encrypt group_vars/all/vault.yml

decrypt:
	ansible-vault decrypt group_vars/all/vault.yml

lint:
	ansible-lint --fix playbooks/*.yml


# Run host applications
host:
	ansible-playbook playbooks/install_host_applications.yml --tags $(tag) $(if $(limit),--limit $(limit))

caddy:
	$(MAKE) host tag=caddy

olivetin:
	$(MAKE) host tag=olivetin

restic:
	$(MAKE) host tag=restic


# Run host containers
container:
	ansible-playbook playbooks/start_containers.yml --tags $(tag) $(if $(limit),--limit $(limit))

adguard_home:
	$(MAKE) container tag=adguard_home

dashy: 
	$(MAKE) container tag=dashy

diun:
	$(MAKE) container tag=diun

file_browser:
	$(MAKE) container tag=file_browser

glances:
	$(MAKE) container tag=glances

jellyfin:
	$(MAKE) container tag=jellyfin

metube:
	$(MAKE) container tag=metube

navidrome:
	$(MAKE) container tag=navidrome

pinchflat:
	$(MAKE) container tag=pinchflat

pihole:
	$(MAKE) container tag=pihole

portainer:
	$(MAKE) container tag=portainer

stirling_pdf:
	$(MAKE) container tag=stirling_pdf

tubearchivist:
	$(MAKE) container tag=tubearchivist

uptime_kuma:
	$(MAKE) container tag=uptime_kuma

vaultwarden:
	$(MAKE) container tag=vaultwarden

vikunja:
	$(MAKE) container tag=vikunja


# Run NAS setup
nas:
	ansible-playbook playbooks/nas_setup.yml --limit NasHost

nas-client:
	ansible-playbook playbooks/nas_setup.yml --limit ServicesHost
