# Vaultwarden

Vaultwarden is an unofficial Bitwarden compatible server written in Rust, formerly known as bitwarden_rs. It's lightweight and resource-efficient, making it perfect for self-hosting password management.

## Configuration Notes

The container is configured with:
- **DOMAIN**: Set to use HTTPS for proper attachment handling
- **SIGNUPS_ALLOWED**: Initially enabled (set to "false" after creating your account)
- **ADMIN_TOKEN**: Optional admin panel access (configured via vault)
- **WEBSOCKET_ENABLED**: Enables real-time sync across devices

## Security Considerations

1. **Disable signups** after creating your initial account by setting `vaultwarden_signups_allowed: "false"` in the role vars
2. **Set admin token** in vault for secure admin panel access
3. **Use strong passwords** and enable 2FA for all accounts
4. **Regular backups** of the `/opt/vaultwarden/data` directory

## Admin Panel

Access the admin panel at `https://vaultwarden.yourdomain.com/admin` using the admin token configured in your vault.

## Client Setup

Vaultwarden is compatible with all official Bitwarden clients:
- **Web Vault**: Access directly through your domain
- **Browser Extensions**: Point to your server URL
- **Mobile Apps**: Configure server URL in settings
- **Desktop Apps**: Set server URL during initial setup

# Useful links

- [Vaultwarden GitHub](https://github.com/dani-garcia/vaultwarden)
- [Vaultwarden Wiki](https://github.com/dani-garcia/vaultwarden/wiki)
- [Docker Compose Setup Guide](https://github.com/dani-garcia/vaultwarden/wiki/Using-Docker-Compose)
- [Bitwarden Official Clients](https://bitwarden.com/download/)
- [Backing up your vault]https://github.com/dani-garcia/vaultwarden/wiki/Backing-up-your-vault

