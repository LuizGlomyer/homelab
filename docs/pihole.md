# Pi-hole

The easiest way to set up Pi-hole is by using network: host in the Docker configuration in which the container ports behaves as if they were native to the host. However, this poses a problem: Pi-hole 6 is hardcoded to expose port 80 and 443 and this clashes with Caddy acting as a reverse proxy. Unfortunatelly there's no port binding with network: host and no way to reassign server ports in Pi-hole, so that leaves us with to using network: bridge, but then things start getting messy and configurations conflict. Not worth the time.

tl;dr: use [Adguard](adguard-home.md). 

# Unbound

Test unbound from the pi
```bash
dig pi-hole.net @127.0.0.1 -p 5335
```

# Useful links

https://github.com/pi-hole/pi-hole
https://docs.pi-hole.net/docker/
https://docs.pi-hole.net/guides/dns/unbound/
https://docs.pi-hole.net/docker/configuration/
