# Diun - Docker Image Update Notifier

Diun is an automatic Docker image update notifier that monitors your Docker images and sends notifications when updates are available. It supports multiple notification channels including Telegram and Discord.

## Features

- **Automatic monitoring**: Watches Docker images periodically and detects new versions
- **Multiple providers**: Supports Docker provider to monitor local containers
- **Multiple notification channels**: Telegram and Discord integrations
- **Scheduled checks**: Configurable watch schedule with jitter
- **Persistent database**: Uses BBolt database to track image manifests

### Notifications

The service is configured with both Telegram and Discord notifications:

#### Telegram Configuration
- **Token**: Encrypted in `vault_diun_telegram_token`
- **Chat IDs**: Configured in `vault_diun_telegram_chat_ids`
  - Format: Single chat ID or comma-separated IDs
  - Can include topic IDs (e.g., `123456789:25` for chat ID 123456789, topic 25)

#### Discord Configuration
- **Webhook URL**: Encrypted in `vault_diun_discord_webhook_url`
- **Features**: 
  - Rich message embeds with image information
  - Field rendering for detailed update information
  - Configurable mentions


### Monitored Images

Diun monitors all containers labeled with `diun.enable=true`, which is automatically applied to all services in this homelab.

## Notification Messages

### Telegram Format
```
Docker tag [image_name](link) which you subscribed to through [provider] provider has been released on [hostname].
```

### Discord Format
Rich embeds showing:
- Docker image name with link
- Provider (Docker)
- Update status (new or updated)
- Registry information
- Hostname that triggered the notification

## Troubleshooting

```bash
# Check Diun logs
docker logs diun
# Send a test notification to all configured notifiers
docker exec -it diun diun notif test
```

## Useful links

- [Diun Documentation](https://crazymax.dev/diun/)
- [Docker Provider Configuration](https://crazymax.dev/diun/providers/docker/)
- [Telegram Notifications](https://crazymax.dev/diun/notif/telegram/)
- [Discord Notifications](https://crazymax.dev/diun/notif/discord/)
- [GitHub Repository](https://github.com/crazy-max/diun)
