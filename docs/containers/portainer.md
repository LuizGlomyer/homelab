# Portainer

Web UI for managing Docker: containers, images, networks, volumes, and stacks. Useful for inspecting logs, updating containers, and performing routine maintenance without the CLI.

## Portainer Agent

The Portainer Agent is a lightweight component that runs alongside Portainer to provide remote management capabilities. It allows Portainer (hosted on the Services VM) to monitor and manage Docker environments on other hosts or edge devices.

On Portainer UI, go to Environments and create a new one. Use the URL to your instance, preferably an IP address such as `https://192.168.0.200:9443`; **the port is important!** After that the UI will generate a command to run a **Portainer Edge Agent** instance on the remote host that you want to control, similar to the following:

```bash
docker run -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /var/lib/docker/volumes:/var/lib/docker/volumes \
  -v /:/host \
  -v portainer_agent_data:/data \
  --restart always \
  -e EDGE=1 \
  -e EDGE_ID={{ secret_id }} \
  -e EDGE_KEY={{ secret_key }} \
  -e EDGE_INSECURE_POLL=1 \
  --name portainer_edge_agent \
  portainer/agent:2.39.0
```
The Portainer server uses port 8000 as an encrypted reverse tunnel to communicate with the remote instance, 9443 is used solely for the initial handshake. Both `secret_id` and `secret_key` are given by Portainer.


# Useful links

- https://github.com/portainer/portainer
- https://docs.portainer.io/start/install-ce
- https://downloads.portainer.io/edge_agent_guide.pdf
