# Homelab Repository Context Rules

This document provides context rules and patterns for working with this homelab repository. It serves as a guide for understanding the established conventions and patterns used throughout the codebase.

## Repository Overview

This is an Infrastructure as Code homelab setup managing a multi-host environment using Terraform for VM provisioning and Ansible for configuration management. The infrastructure includes:
- **Raspberry Pi 4**: Running Raspberry Pi OS (Debian-based, ARM64) for host applications
- **Proxmox Host**: Physical i5-based server running Proxmox virtualization platform
- **Debian VMs**: Multiple Debian 12 (Bookworm) virtual machines provisioned via Terraform for containerized services and NAS functionality

The repository manages both containerized services and host-level services using Infrastructure as Code principles.

## Directory Structure and Organization Patterns

### Standard Directory Layout
```
homelab/
├── AGENTS.md                      # Context rules and patterns for this repository
├── README.md                      # Main documentation and service overview
├── ansible/                       # Ansible automation
│   ├── ansible.cfg                # Ansible configuration
│   ├── inventory.ini              # Host inventory (RaspberryPi, ProxmoxHost, VMs, ServicesHost, NasHost groups)
│   ├── group_vars/all/            # Global variables and secrets
│   │   ├── main.yml               # Global variables (ports, host IPs, vault references)
│   │   ├── vault.yml              # Encrypted secrets (vault references)
│   │   ├── vault.yml.example      # Vault secrets template
│   │   └── vault_pass.txt         # Vault password (gitignored)
│   ├── playbooks/                 # Ansible playbooks (focused, task-specific)
│   │   ├── install_host_applications.yml  # Install services on RaspberryPi and ProxmoxHost
│   │   ├── start_containers.yml           # Deploy containerized services on ServicesHost
│   │   ├── configure_nas.yml              # Configure NasHost Samba setup
│   │   ├── create_proxmox_templates.yml   # Create VM templates for Terraform
│   │   ├── update_packages.yml            # Update packages across hosts
│   │   └── smb_mounts.yml                 # Mount SMB shares on hosts
│   └── roles/                     # Service-specific Ansible roles
│       ├── services/              # System services (installed on host)
│       │   ├── caddy/             # Reverse proxy and CA
│       │   ├── docker/            # Docker installation
│       │   ├── golang/            # Go compiler (for Caddy builds)
│       │   └── olivetin/          # Shell command GUI
│       ├── containers/            # Containerized services (run in Docker)
│       │   ├── adguard_home/
│       │   ├── dashy/
│       │   ├── file_browser/
│       │   ├── glances/
│       │   ├── metube/
│       │   ├── navidrome/
│       │   ├── pihole/
│       │   ├── portainer/
│       │   ├── stirling_pdf/
│       │   ├── uptime_kuma/
│       │   ├── vaultwarden/
│       │   └── vikunja/
│       ├── configure_nas/         # NAS-specific configuration (Samba)
│       ├── extract_metadata/      # Extract system facts for use in playbooks
│       ├── proxmox_template/      # Create Proxmox templates for VMs
│       ├── smb_mounts/            # Mount SMB shares on hosts
│       └── update_packages/       # Package update automation
├── terraform/                     # Infrastructure provisioning
│   ├── cloud-init/
│   │   └── debian.yaml.tpl        # Cloud-init template for VM initialization (hostname, user, SSH key)
│   └── environments/homelab/      # Terraform configuration for homelab VMs
│       ├── main.tf                # VM definitions (centralized map for scalable deployments)
│       ├── providers.tf           # Provider configuration (Proxmox API)
│       ├── variables.tf           # Variable definitions
│       └── terraform.tfvars       # Terraform variable values
└── docs/                          # Service documentation
    ├── ansible.md                 # Ansible setup and usage
    ├── terraform.md               # Terraform setup and usage
    ├── proxmox.md                 # Proxmox configuration
    ├── containers/                # Container service documentation
    │   ├── adguard-home.md
    │   ├── dashy.md
    │   ├── ... (other containers)
    └── services/                  # Host service documentation
        ├── caddy.md
        ├── docker.md
        ├── olivetin.md
        └── samba.md
```

### Role Structure Pattern
Each service follows a consistent role structure:
- **tasks/main.yml**: Main automation tasks
- **vars/main.yml**: Service-specific variables (ports, image names, paths)
- **templates/**: Jinja2 templates for configuration files (when needed)
- **files/**: Static files to be copied (when needed)

## Ansible Patterns and Conventions

### Playbook Organization
- **Multiple playbooks**: Task-specific playbooks organized by purpose rather than a monolithic main.yml
  - **install_host_applications.yml**: System-level services (Docker, Caddy, OliveTin, Golang) on RaspberryPi and ServicesHost
  - **start_containers.yml**: Containerized services deployment on ServicesHost
  - **configure_nas.yml**: NAS-specific configuration (Samba) on NasHost
  - **create_proxmox_templates.yml**: VM template creation on ProxmoxHost
  - **update_packages.yml**: Package updates across all hosts
- **Multi-host targeting**: Playbooks target specific host groups (RaspberryPi, ServicesHost, NasHost, ProxmoxHost)
- **Role tagging**: Each role tagged with its own name for selective execution
- **Privilege escalation**: System roles use `become: true`, container roles rely on Docker group membership
- **Metadata extraction**: `extract_metadata` role runs on all hosts to gather system facts

### Task Naming and Structure
- Descriptive task names following the pattern: "Action + Object + Context"
- Examples: "Ensure Navidrome data directory exists", "Run Navidrome container"
- Consistent use of `ansible.builtin.` and `community.docker.` module prefixes

### Variable Management Patterns
- **Global variables**: Defined in `group_vars/all/main.yml`
- **Service ports**: Centrally managed with pattern `{service}_web_port`- **Host IPs**: Defined as variables (e.g., `raspberry_host_ip`, `services_host_ip`, `nas_host_ip`)- **Secrets**: Referenced via vault variables with pattern `vault_{secret_name}`
- **Service-specific vars**: Defined in each role's `vars/main.yml`

### Common Variable Patterns
```yaml
# Port definitions (in group_vars/all/main.yml)
{service_name}_web_port: {port_number}

# Container configurations (in role vars/main.yml)
{service_name}_image: {docker_image}:{tag}
{service_name}_container_name: {container_name}
{service_name}_data_dir: /opt/{service_name}/data

# Vault references (in group_vars/all/main.yml)
{service_name}_secret: "{{ vault_{service_name}_secret }}"
```

## Container Deployment Patterns

### Standard Container Configuration
All containerized services follow this pattern:
```yaml
- name: Run {Service} container
  community.docker.docker_container:
    name: "{{ {service}_container_name }}"
    image: "{{ {service}_image }}"
    state: started
    restart_policy: unless-stopped
    container_default_behavior: compatibility
    published_ports:
      - "{{ {service}_web_port }}:{internal_port}"
    volumes:
      - "{{ {service}_data_dir }}:/data"  # or service-specific paths
    env:  # Service-specific environment variables
      KEY: "{{ value }}"
```

### Volume Management
- **Host directories**: Services use `/opt/{service_name}/` for persistent data
- **Permission handling**: Uses `user_uid` and `user_gid` facts from common role
- **Docker volumes**: Used sparingly (mainly for Portainer)

### Container Lifecycle
- **Restart policies**: `unless-stopped` for most services, `always` for critical services
- **Health checks**: Implemented where Docker image supports it
- **Dependency management**: Implicit through role inclusion and tagging

## Configuration Management Patterns

### Template Usage
- **Jinja2 templates**: Used for complex configuration files (Caddyfile, OliveTin config)
- **Static files**: Used for simple configuration files (Dashy config)
- **Template naming**: `{config_name}.j2` pattern

### Dashy Configuration Management
- **Homepage configuration**: `roles/dashy/files/dashy_conf.yml` defines the homepage layout and service links
- **Service sections**: Organized into multiple sections (HTTPS domains, local HTTP, certificates)
- **Dual access patterns**: Each service listed with both domain-based HTTPS and local HTTP access
- **Manual maintenance**: New services must be manually added to both sections when added to the homelab
- **Service structure**: Each service entry includes title, description, icon, URL, and unique ID

### Configuration File Locations
- **Service configs**: Typically in `/opt/{service}/` or `/etc/{service}/`
- **Systemd services**: `/etc/systemd/system/{service}.service`
- **Web server configs**: `/etc/{service}/` (e.g., `/etc/caddy/Caddyfile`)

## Service Categories and Patterns

### Host Services (System-level installation)
- **Caddy**: Reverse proxy with custom build (DNS plugins)
- **OliveTin**: Web GUI for shell commands

**Common patterns:**
- Direct binary installation or package management
- Systemd service management
- Custom user/group creation
- Configuration file templating

### Containerized Services
All other services run in Docker containers with consistent patterns:
- Port exposure through variables
- Data persistence via host volumes
- Environment variable configuration
- Standardized container lifecycle management

## Security and Secrets Management

### Ansible Vault
- **Secrets storage**: `group_vars/all/vault.yml` (encrypted)
- **Password file**: `group_vars/all/vault_pass.txt` (gitignored)
- **Variable referencing**: `"{{ vault_{secret_name} }}"` pattern

### SSL/TLS Management
- **Caddy CA**: Self-signed certificates for internal use
- **Let's Encrypt**: DNS challenges via Cloudflare/DuckDNS
- **Certificate distribution**: Caddy root CA copied to system trust store

### Access Control
- **OliveTin**: Password-based authentication with API-generated hashes
- **Service exposure**: All services behind Caddy reverse proxy

## Network and Reverse Proxy Patterns

### Port Management
- **Centralized definition**: All ports in `group_vars/all/main.yml`
- **Non-conflicting assignment**: Each service has unique port
- **Reverse proxy integration**: Caddy automatically configured for all services

### Domain Strategy
- **Multiple domains**: Internal (.lan), public (.dev), and DuckDNS (.duckdns.org)
- **Wildcard certificates**: Supported via DNS challenges
- **Service subdomains**: `{service}.{domain}` pattern

### Caddy Configuration Patterns
- **Template-driven**: Service list in vars drives reverse proxy configuration
- **TLS strategies**: Internal certs, Cloudflare DNS, DuckDNS DNS
- **Special handling**: Services requiring TLS passthrough (Portainer)

### Caddy Architecture and mTLS

Caddy operates in a **dual-instance architecture** for secure internal and external service exposure:

**Raspberry Pi (Edge Instance)**
- **Role**: Public-facing reverse proxy and TLS terminator
- **Location**: Runs on Raspberry Pi 4 at 192.168.0.88
- **Certificates**: Let's Encrypt with DNS-01 challenges via Cloudflare for *.glomyer.dev and *.edge.glomyer.dev
- **Exposed domains**: Services accessible via public domains (e.g., navidrome.glomyer.dev)
- **mTLS Client**: Acts as an mTLS client to connect securely to Services VM
- **Configuration**: `templates/edge.Caddyfile.j2`

**Services VM (Internal Instance)**
- **Role**: Internal service proxy with mTLS server
- **Location**: Runs on ServicesHost VM at 192.168.0.200
- **Certificates**: Self-signed via Caddy's internal CA for internal domains (*.internal.glomyer.dev)
- **mTLS Server**: Requires client certificate authentication from Raspberry Pi
- **Port exposure**: Listens on localhost for containerized services, forwards external requests via mTLS
- **Configuration**: `templates/services.Caddyfile.j2`

**mTLS (Mutual TLS) Trust Chain**
- **Root CA**: Generated by Caddy on Services VM at `/var/lib/caddy/.local/share/caddy/pki/authorities/local/root.crt`
- **Server Certificate**: Services VM presents `services-server.crt` and `services-server.key` for domain *.internal.glomyer.dev
- **Client Certificate**: Raspberry Pi uses `raspberry-client.crt` and `raspberry-client.key` to authenticate to Services VM
- **Certificate Distribution**: Root CA and client certificates distributed from Services VM to Raspberry Pi for mutual trust

**Request Flow**
1. External request arrives at Raspberry Pi for `navidrome.glomyer.dev`
2. Raspberry Pi validates Let's Encrypt certificate from Cloudflare DNS challenge
3. Raspberry Pi establishes mTLS tunnel to Services VM: `https://192.168.0.200:443` with client certificate
4. Request routed internally to Navidrome container on localhost:9700
5. Response flows back through mTLS tunnel to Raspberry Pi and out to client

**Port Management**
- **Raspberry Pi ports**: Exposes 80 (HTTP) and 443 (HTTPS) publicly for Let's Encrypt challenges and HTTPS traffic
- **Services VM ports**: Listens on 443 for mTLS connections from Raspberry Pi, containers expose localhost ports
- **Container ports**: Each service (Navidrome, Jellyfin, etc.) runs on unique localhost port defined in `group_vars/all/main.yml`

**Security Benefits**
- **Encrypted internal communication**: mTLS ensures all traffic between edge and services is encrypted and authenticated
- **Certificate pinning**: Client certificate requirement prevents unauthorized access to internal services
- **Credential isolation**: Only Raspberry Pi has access credentials to internal Services VM
- **Public certificate management**: Let's Encrypt handles public certificates, no manual certificate management required

## Documentation Patterns

### Service Documentation
- **Individual docs**: Each service has `docs/{service-name}.md`
- **Consistent structure**: Description, configuration notes, useful links
- **Image organization**: Screenshots in `docs/images/{service}/`

### README Structure
- Service table with descriptions and types
- Setup instructions (dependencies, configuration)
- Usage examples with actual commands

## Development and Deployment Workflow

### Ansible Execution Patterns
```bash
# Install host applications (Caddy, Docker, OliveTin on RaspberryPi and ServicesHost)
ansible-playbook playbooks/install_host_applications.yml --user pi --ask-pass --ask-become-pass --vault-password-file group_vars/all/vault_pass.txt

# Deploy containerized services (on ServicesHost)
ansible-playbook playbooks/start_containers.yml --user ansible --ask-pass --vault-password-file group_vars/all/vault_pass.txt

# Configure NAS (on NasHost)
ansible-playbook playbooks/configure_nas.yml --user ansible --ask-pass --ask-become-pass --vault-password-file group_vars/all/vault_pass.txt

# Create Proxmox templates (on ProxmoxHost)
ansible-playbook playbooks/create_proxmox_templates.yml --user root --ask-pass --vault-password-file group_vars/all/vault_pass.txt

# Update packages across all hosts
ansible-playbook playbooks/update_packages.yml --user pi --ask-pass --ask-become-pass --vault-password-file group_vars/all/vault_pass.txt

# Service-specific deployment (single service across relevant hosts)
ansible-playbook playbooks/start_containers.yml --user ansible --ask-pass --vault-password-file group_vars/all/vault_pass.txt --tags {service_name}

# Skip common dependencies (Docker, packages)
ansible-playbook playbooks/start_containers.yml --user ansible --ask-pass --vault-password-file group_vars/all/vault_pass.txt --tags {service_name} --skip-tags docker
```

### Tag Strategy
- **Role tags**: Each role tagged with its name
- **Subtags**: `apt`, `docker` for skipping common setup
- **Selective deployment**: Enables individual service management

## Architecture-Specific Considerations

### ARM64/Raspberry Pi Patterns
- **Architecture detection**: Common role detects and maps architecture
- **ARM-specific binaries**: URLs and packages selected for ARM64
- **Debian-based utilities**: APT package management, systemd services
- **Resource constraints**: Limited CPU and memory for host services

### Multi-Host Architecture
- **Distributed deployment**: Services split across multiple hosts based on resource needs
  - **RaspberryPi**: Host services (Caddy, OliveTin) and metadata extraction; lightweight, low-power always-on
  - **ServicesHost VM**: Containerized services (Dashy, Navidrome, media services, etc.); higher resource allocation
  - **NasHost VM**: NAS functionality with Samba; dedicated for file storage and sharing
  - **ProxmoxHost**: Host-level only; manages the hypervisor and VM templates
- **Network integration**: All hosts communicate over 192.168.x.x network; centralized reverse proxy on RaspberryPi
- **Inventory-driven**: Ansible groups define which services run on which hosts

## Best Practices Established

### Code Organization
- **Single responsibility**: Each role manages one service
- **Consistent naming**: Variables, files, and tasks follow patterns
- **Modular design**: Services can be deployed independently

### Configuration Management
- **Environment separation**: Use of different domains for different access patterns
- **Secret management**: Centralized vault with clear referencing patterns
- **Template reusability**: Common patterns abstracted into templates

### Operational Patterns
- **Idempotent operations**: All tasks can be run repeatedly safely
- **Service validation**: Configuration validation where possible
- **Graceful handling**: Services designed to handle restarts and updates

## Extension Guidelines

When adding new services to this homelab:

1. **Follow role structure**: Create standard directories (tasks, vars, optionally templates/files)
2. **Determine service category**: 
   - Container services go in `roles/containers/{service_name}/`
   - Host-level services go in `roles/services/{service_name}/`
3. **Add port allocation**: Define `{service}_web_port` in `group_vars/all/main.yml`
4. **Add to appropriate playbook**: 
   - Container services: Add role to `playbooks/start_containers.yml`
   - Host services: Add role to `playbooks/install_host_applications.yml`
5. **Configure reverse proxy**: Add service to `caddy_services` list in Caddy vars (if exposing via domain)
6. **Create documentation**: Add `docs/{service-name}.md` with service details
7. **Update README**: Add service entry to the main services table
8. **Update Dashy homepage**: Add service entries to both HTTPS and local HTTP sections in `roles/dashy/files/dashy_conf.yml`
9. **Redeploy Caddy and Dashy**: After adding a new service, redeploy Caddy and Dashy to update their configurations:
   ```bash
   ansible-playbook playbooks/install_host_applications.yml --user pi --ask-pass --ask-become-pass --vault-password-file group_vars/all/vault_pass.txt --tags caddy
   ansible-playbook playbooks/start_containers.yml --user ansible --ask-pass --vault-password-file group_vars/all/vault_pass.txt --tags dashy
   ```

This ensures consistency with established patterns and maintains the cohesive architecture of the homelab setup.
