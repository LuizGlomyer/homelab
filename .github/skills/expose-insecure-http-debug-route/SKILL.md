---
name: expose-insecure-http-debug-route
description: "Expose a service over plain HTTP on both the edge and internal services Caddy hosts for debugging, using an insecure subdomain such as {service}.insecure.glomyer.dev. Use when you need temporary routes that bypass TLS for local debugging."
argument-hint: "Service name, for example tubearchivist"
user-invocable: true
disable-model-invocation: false
---

# Expose an Insecure HTTP Debug Route

## When to Use
- You need temporary HTTP-only routes for debugging an application.
- The service is already deployed behind Caddy and has a known web port.
- You want routes matching {service}.insecure.glomyer.dev on both the edge and internal services Caddy hosts.

## Inputs
- Service name in lowercase snake_case or kebab-case, for example tube-archivist.
- The service upstream port, usually the existing web port variable such as {{ service_name }}_web_port.
- The target Caddyfiles: [ansible/roles/services/caddy/templates/edge.Caddyfile.j2](../../../ansible/roles/services/caddy/templates/edge.Caddyfile.j2) and [ansible/roles/services/caddy/templates/services.Caddyfile.j2](../../../ansible/roles/services/caddy/templates/services.Caddyfile.j2).

## Procedure
1. Add the route to both the edge Caddyfile and the services Caddyfile.
2. Add the comment immediately above each new route definition:
   TODO: Remove insecure HTTP test route
3. Create a plain HTTP site block using the insecure subdomain pattern in both files:

   ```caddy
   TODO: Remove insecure HTTP test route
   <service>.insecure.glomyer.dev {
     reverse_proxy localhost:<service_web_port>
   }
   ```

4. Reuse the existing service web port variable when available instead of hard-coding a port.
5. Do not change any other existing routes in either file; only add the new insecure route if it is not already present.
6. Verify the route name and port match the existing service deployment in both files.

## Completion Checklist
- The route is present in both the edge Caddyfile and the services Caddyfile.
- The block uses plain HTTP and the insecure subdomain pattern.
- The required comment appears immediately above the definition.
- The service name and port match the existing deployment.
