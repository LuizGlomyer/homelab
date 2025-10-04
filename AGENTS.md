# Homelab Repository Context Rules

This document provides context rules and patterns for working with this homelab repository. It serves as a guide for understanding the established conventions and patterns used throughout the codebase.

## Repository Overview

This is an Ansible-based homelab setup for a Raspberry Pi 4 server running Raspberry Pi OS (Debian-based, ARM64). The repository manages both containerized services and host-level services using Infrastructure as Code principles.

## Directory Structure and Organization Patterns

### Standard Directory Layout
```
homelab/
├── ansible.cfg                    # Ansible configuration
├── inventory.ini                  # Host inventory (single host: raspberrypi.local)
├── group_vars/all/                # Global variables and secrets
│   ├── main.yml                   # Non-sensitive global variables
│   ├── vault.yml.example          # Vault secrets template
│   └── vault_pass.txt.example     # Vault password template
├── playbooks/                     # Ansible playbooks
│   └── main.yml                   # Main playbook orchestrating all roles
├── roles/                         # Service-specific Ansible roles
│   ├── common/                    # Base system setup (Docker, packages)
│   ├── {service_name}/            # Individual service roles
│   │   ├── tasks/main.yml         # Main task file
│   │   ├── vars/main.yml          # Service-specific variables
│   │   ├── templates/             # Jinja2 templates (optional)
│   │   └── files/                 # Static files (optional)
└── docs/                          # Service documentation
    ├── {service-name}.md          # Per-service documentation
    └── images/                    # Documentation images
```

### Role Structure Pattern
Each service follows a consistent role structure:
- **tasks/main.yml**: Main automation tasks
- **vars/main.yml**: Service-specific variables (ports, image names, paths)
- **templates/**: Jinja2 templates for configuration files (when needed)
- **files/**: Static files to be copied (when needed)

## Ansible Patterns and Conventions

### Playbook Organization
- **Two-phase deployment**: System setup (common, caddy, olivetin) vs containerized services
- **Role tagging**: Each role tagged with its own name for selective execution
- **Host targeting**: All roles target the `servers` group
- **Privilege escalation**: System roles use `become: true`, container roles rely on Docker group membership

### Task Naming and Structure
- Descriptive task names following the pattern: "Action + Object + Context"
- Examples: "Ensure Navidrome data directory exists", "Run Navidrome container"
- Consistent use of `ansible.builtin.` and `community.docker.` module prefixes

### Variable Management Patterns
- **Global variables**: Defined in `group_vars/all/main.yml`
- **Service ports**: Centrally managed with pattern `{service}_web_port`
- **Secrets**: Referenced via vault variables with pattern `vault_{secret_name}`
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
    restart_policy: unless-stopped  # or 'always'
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
# Full deployment
ansible-playbook playbooks/main.yml --user pi --ask-pass --ask-become-pass --vault-password-file group_vars/all/vault_pass.txt

# Service-specific deployment
ansible-playbook playbooks/main.yml --user pi --ask-pass --ask-become-pass --vault-password-file group_vars/all/vault_pass.txt --tags {service_name}

# Skip common dependencies
ansible-playbook playbooks/main.yml --user pi --ask-pass --ask-become-pass --vault-password-file group_vars/all/vault_pass.txt --tags {service_name} --skip-tags apt,docker
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

### Resource Constraints
- **Single-host deployment**: All services on one Raspberry Pi 4
- **Port management**: Careful allocation to avoid conflicts
- **Volume optimization**: Efficient use of SD card storage

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
2. **Add port allocation**: Define `{service}_web_port` in `group_vars/all/main.yml`
3. **Update main playbook**: Add role with appropriate tags to `playbooks/main.yml`
4. **Configure reverse proxy**: Add service to `caddy_services` list in Caddy vars
5. **Create documentation**: Add `docs/{service-name}.md` with service details
6. **Update README**: Add service entry to the main services table
7. **Update Dashy homepage**: Add service entries to both HTTPS and local HTTP sections in `roles/dashy/files/dashy_conf.yml`
8. **Redeploy Caddy and Dashy**: After adding a new service, redeploy Caddy and Dashy to update their configurations:
   ```bash
   ansible-playbook playbooks/main.yml --user pi --ask-pass --ask-become-pass --vault-password-file group_vars/all/vault_pass.txt --tags caddy,dashy
   ```

This ensures consistency with established patterns and maintains the cohesive architecture of the homelab setup.
