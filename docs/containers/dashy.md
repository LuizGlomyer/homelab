# Dashy

Dashy is the central, self-hosted homepage for this homelab. It provides a clean, customizable dashboard with quick links to every service, organized into logical sections (HTTPS domains, local HTTP, and certificates). Configuration is managed via Ansible and a versioned [YAML file](/roles/dashy/files/dashy_conf.yml), ensuring the homepage stays in sync with deployed services.

Your local configuration always override the server's, even after a new deploy. In this case, you need to go to the configs and do a reset.

# Useful links

- https://github.com/lissy93/dashy
- https://dashy.to/docs/configuring/
- https://github.com/homarr-labs/dashboard-icons
