# Uptime Kuma

Self-hosted monitoring dashboard for HTTP/TCP/ICMP checks, cron jobs, and custom scripts, with status pages and multi-channel notifications.

If testing for custom DNS resolutions inside the network (i.e., .lan sites) it's a good idea to configure the DNS resolution of the host device.

To achieve this edit `/etc/resolv.conf`, comment all defined nameservers and then add a new line:

>nameserver 127.0.0.1  

We're basically telling the machine to check the Adguard instance for DNS resolution.


# Useful links

- https://github.com/louislam/uptime-kuma
