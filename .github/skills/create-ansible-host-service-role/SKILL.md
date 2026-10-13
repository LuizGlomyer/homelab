---
name: create-ansible-host-service-role
description: 'Create an Ansible role that installs and configures a host application by name. Use when adding a non-containerized application under ansible/roles/services/ and wiring it into the host application playbook.'
argument-hint: 'Service name, for example: my_application; optional target hosts and installation commands'
user-invocable: true
disable-model-invocation: false
---

# Create an Ansible Host Service Role

## When to Use
- You are adding a host-installed application that does not run as a container.
- You need a role under `ansible/roles/services/<service_name>/`.
- You need the role registered in `ansible/playbooks/install_host_applications.yml` for selected hosts.

## Inputs
- Service name, normalized to lowercase snake_case.
- Optional target host group(s) or host(s). If none are given, target `[VMs]`.
- Optional terminal commands, package names, download URLs, configuration details, service unit name, and required credentials.

## Procedure
1. Normalize the service name.
   - Use lowercase snake_case for the role directory and tag.
   - Preserve the application's actual package, binary, and systemd service names where they differ.

2. Choose target hosts.
   - Use the host group(s) or host(s) supplied by the user.
   - If no target is supplied, use `[VMs]`.
   - Register the role in its own play in `ansible/playbooks/install_host_applications.yml`, with `hosts` set to the selected host group(s). The existing host-applications play targets only `[RaspberryPi, ServicesHost]`; do not place a `[VMs]`-targeted role inside that play, since it would not reach every VM.
   - Set `become: true` when installation or configuration requires elevated privileges.

3. Create the role skeleton.
   - Create `ansible/roles/services/<service_name>/tasks/main.yml` and `vars/main.yml`.
   - Add `handlers/main.yml`, `templates/`, or `files/` only when needed.
   - Follow the local patterns in roles such as `services/docker`, `services/golang`, and `services/olivetin`.

4. Implement installation and configuration tasks.
   - Convert user-provided terminal commands into Ansible tasks that preserve their intended order and behavior.
   - Prefer Ansible modules over raw terminal commands. For example, use `ansible.builtin.apt` or `package` for packages; `get_url` for downloads; `unarchive` for archives; `file`, `copy`, or `template` for files; `user` for accounts; and `systemd` or `service` for services.
   - Use `ansible.builtin.command` only when no suitable module expresses the operation. Use `ansible.builtin.shell` only when shell features such as pipes, redirection, or expansion are genuinely required.
   - For command or shell tasks, make execution idempotent with an appropriate `creates`/`removes` condition or explicit `changed_when`/`when` logic. Use `changed_when: false` for read-only checks. Avoid reporting every run as changed.
   - Use fully qualified module names (`ansible.builtin.*`) and descriptive task names.
   - Store tunable package versions, URLs, paths, and service names in `vars/main.yml` where useful. Do not add container image or web-port variables unless the application genuinely needs them.
   - Start and enable a system service with the appropriate Ansible service module. Notify a handler for restarts when configuration changes should trigger one.
   - Keep secrets in Ansible Vault variables; do not put credentials in task arguments, templates, or unencrypted vars. Add placeholders to `ansible/group_vars/all/vault.yml.example` when new secrets are required.

5. Register the role in the host application playbook.
   - Add a dedicated play with `hosts: [<selected_hosts>]` (or `hosts: [VMs]` when the user supplied no host), `become: true` when required, and the role `services/<service_name>`.
   - Apply a role tag matching `<service_name>` so the role can be run selectively.
   - Keep the existing RaspberryPi/ServicesHost plays and their role targeting unchanged unless the user explicitly requests a broader change.

6. Add a Makefile target.
   - Add the service name to `.PHONY` and create a target in `ansible/Makefile` that invokes the existing `host` target with `tag=<service_name>`.
   - Follow the existing `caddy` and `olivetin` targets.

7. Add service documentation.
   - Create `docs/services/<service-name>.md` describing the application's configuration in this repository, including its role, target hosts, managed files or units, relevant paths, and operational details useful for maintainers.
   - Keep the documentation specific to the implementation; do not document secrets or invent configuration that is not present.

8. Add integrations only when appropriate.
   - If the application should be proxied, add the relevant Caddy route following the existing host-specific edge or services configuration.
   - Add Dashy entries when the application should be discoverable. Do not expose a service or add homepage links without sufficient user intent and connection details.

9. Validate the result.
   - Confirm the role directory, tasks, variables, and optional handlers/configuration files are present.
   - Verify the new play uses the requested hosts, or `[VMs]` when none were supplied, and includes the matching role and tag.
   - Run `ansible-playbook playbooks/install_host_applications.yml --syntax-check` from `ansible/` when available. Review task idempotency and check the Makefile target.

## Role Template

```yaml
# ansible/roles/services/<service_name>/tasks/main.yml
- name: Install <Application> packages
  ansible.builtin.apt:
    name: <package_name>
    state: present
    update_cache: true

- name: Ensure <Application> service is enabled and started
  ansible.builtin.systemd:
    name: <service_unit>
    enabled: true
    state: started
```

```yaml
# ansible/roles/services/<service_name>/vars/main.yml
<service_name>_package: <package_name>
<service_name>_service: <service_unit>
```

```yaml
# ansible/playbooks/install_host_applications.yml
- name: Install <Application>
  hosts: [VMs] # Replace with user-specified hosts when provided.
  become: true
  roles:
    - role: services/<service_name>
      tags: <service_name>
```

## Completion Checklist
- The role exists under `ansible/roles/services/<service_name>/` and uses Ansible modules where available.
- User-provided installation commands are represented in order, with any unavoidable command tasks made idempotent.
- The role is registered in `install_host_applications.yml` for the user-specified hosts, or `[VMs]` by default, with a matching tag.
- A matching `ansible/Makefile` target is available.
- Service documentation exists in `docs/services/<service-name>.md` and describes the repository-specific configuration.
- Required secrets are represented as Vault references with example placeholders, and any requested integrations or documentation are updated.
- The host application playbook passes syntax validation when dependencies and inventory are available.
