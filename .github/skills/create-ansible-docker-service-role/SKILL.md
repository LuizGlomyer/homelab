---
name: create-ansible-docker-service-role
description: 'Create a new Ansible role for a Docker-based homelab service by name. Use when adding a container service to this repository and you need the standard role structure, variables, playbook wiring, and deployment conventions.'
argument-hint: 'Service name, for example: immich'
user-invocable: true
disable-model-invocation: false
---

# Create an Ansible Docker Service Role

## When to Use
- You are adding a new containerized service to this homelab repository.
- You need a new role under ansible/roles/containers/<service_name>/.
- You need the service wired into the shared playbooks, port variables, and documentation.

## Inputs
- Service name in lowercase snake_case, for example: immich
- Optional target host: ServicesHost or RaspberryPi
- Optional image name, internal port, data directory, and environment variables if known

## Procedure
1. Normalize the service name.
   - Use lowercase snake_case.
   - Derive the role directory name from the service name exactly.

2. Create the role skeleton.
   - Create ansible/roles/containers/<service_name>/tasks/main.yml.
   - Create ansible/roles/containers/<service_name>/vars/main.yml.
   - Follow the existing pattern used by roles such as navidrome and dashy.

3. Define the service variables.
   - Add variables for:
     - <service>_image
     - <service>_container_name
     - <service>_data_dir
   - If the service is exposed on a web port, add <service>_web_port in ansible/group_vars/all/main.yml.
   - If the service needs credentials or secrets, add placeholder entries to [ansible/group_vars/all/vault.yml.example](../../../ansible/group_vars/all/vault.yml.example) under the appropriate "Hosts credentials and secrets" or "Services credentials and secrets" section, using the existing `vault_...` naming pattern and placeholder format.
   - Prefer the existing naming convention and keep values consistent with neighboring services.

4. Implement the container tasks.
   - Create an idempotent task flow that:
     - Ensures the data directory exists.
     - Copies any config files when needed.
     - Runs the container with community.docker.docker_container.
   - Use restart_policy: unless-stopped for standard services.
   - Use published_ports with the shared host port and container port.
   - Use volumes for persistent data and config.
   - Include labels and environment variables only when the service requires them.

5. Wire the role into the deployment playbooks.
   - Add the new role to ansible/playbooks/start_containers.yml.
   - Use a role tag matching the service name.
   - Add a host condition when the service should only run on a specific host, such as ServicesHost or RaspberryPi.
   - Add a matching target to ansible/Makefile under the host or container application commands, according to the application's type.

6. Update Caddy routing.
   - For services exposed through the edge proxy, add an entry to [ansible/roles/services/caddy/templates/edge.Caddyfile.j2](../../../ansible/roles/services/caddy/templates/edge.Caddyfile.j2) using the same pattern as the existing public services.
   - For services that should be reachable only internally, add an entry to [ansible/roles/services/caddy/templates/services.Caddyfile.j2](../../../ansible/roles/services/caddy/templates/services.Caddyfile.j2) using the tls-mtls import and a reverse_proxy to localhost:{{ <service_name>_web_port }}.
   - If the service is a Raspberry Pi host service, add it to the edge file with a local reverse_proxy to localhost:<port>.
   - Follow the conventions described in [docs/services/caddy.md](../../../docs/services/caddy.md) for domain naming, mTLS, and certificate handling.

7. Update the Dashy menu.
   - Add a new item to [ansible/roles/containers/dashy/files/dashy_conf.yml](../../../ansible/roles/containers/dashy/files/dashy_conf.yml) in the Apps (glomyer.dev) section and, when appropriate, the Apps (local HTTP) section.
   - Keep the same structure as the existing entries: title, description, icon, url, target, and a unique id.

8. Update supporting documentation.
   - Add a service doc under docs/containers/ if appropriate.
   - Add the service to the main README service table if it should be part of the documented stack.

9. Validate the result.
   - Check that the new role follows existing naming and structure.
   - Verify the playbook references the new role and tag.
   - Confirm the new Caddy entries and Dashy entries are in the expected files.
   - If possible, run ansible-playbook --syntax-check or a targeted dry run.

## Repository-Specific Patterns
- Public edge routes typically use the cloudflare-cert block and, for VM-hosted services, the mtls_backend import in [ansible/roles/services/caddy/templates/edge.Caddyfile.j2](../../../ansible/roles/services/caddy/templates/edge.Caddyfile.j2).
- Internal-only routes typically use the tls-mtls import and reverse_proxy localhost:{{ <service_name>_web_port }} in [ansible/roles/services/caddy/templates/services.Caddyfile.j2](../../../ansible/roles/services/caddy/templates/services.Caddyfile.j2).
- Dashy entries should be added in both the HTTPS and local HTTP sections of [ansible/roles/containers/dashy/files/dashy_conf.yml](../../../ansible/roles/containers/dashy/files/dashy_conf.yml) when the service should be accessible from both views.

## Role Template
Use this structure as a starting point:

```yaml
# ansible/roles/containers/<service_name>/vars/main.yml
<service_name>_image: <image>:<tag>
<service_name>_container_name: <service_name>
<service_name>_data_dir: /opt/<service_name>/data
```

```yaml
# ansible/roles/containers/<service_name>/tasks/main.yml
- name: Ensure <Service> data directory exists
  become: true
  ansible.builtin.file:
    path: "{{ <service_name>_data_dir }}"
    state: directory
    mode: '0755'

- name: Run <Service> container
  community.docker.docker_container:
    name: "{{ <service_name>_container_name }}"
    image: "{{ <service_name>_image }}"
    state: started
    restart_policy: unless-stopped
    container_default_behavior: compatibility
    published_ports:
      - "{{ <service_name>_web_port }}:<internal-port>"
    volumes:
      - "{{ <service_name>_data_dir }}:/data"
```

## Decision Points
- If the service is a standard web app, add a web port and expose it through the shared port map.
- If the service requires special config files, add a templates/ or files/ directory and copy them before starting the container.
- If the service is only meant for RaspberryPi, add the relevant host condition in the playbook and wire it in the edge Caddyfile.
- If the service should be publicly reachable, also add an entry in the edge Caddyfile and the Dashy homepage.
- If the service should stay internal, add it to the services Caddyfile and optionally the Dashy menu if it should still be visible locally.

## Completion Checklist
- The role exists under ansible/roles/containers/<service_name>/.
- The role contains tasks/main.yml and vars/main.yml.
- Shared port variables and container variables are defined.
- Placeholder credentials are added to [ansible/group_vars/all/vault.yml.example](../../../ansible/group_vars/all/vault.yml.example) when required.
- start_containers.yml includes the new role with a matching tag.
- ansible/Makefile includes a target under the correct host or container command for the new application.
- The service has the appropriate Caddy entries in the edge and/or services Caddyfiles.
- The service has Dashy menu entries in the relevant Dashy sections.
- The service is documented or linked from the main docs if appropriate.
