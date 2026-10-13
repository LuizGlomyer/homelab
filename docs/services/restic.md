# Restic

Restic is installed on `NasHost` by the `services/restic` Ansible role. The role is registered as a dedicated play in `ansible/playbooks/install_host_applications.yml` and can be applied selectively with `make restic` from `ansible/`.

## Repository and password

The Restic repository is `/mnt/backup/restic-storage`. Its password is supplied by the Ansible Vault variable `vault_restic_password` and written to `/root/.config/restic/storage-password` with root-only permissions. The password is not stored in the role variables or backup script.

Before creating or initializing the repository, the role checks that `/mnt/backup` is mounted from the expected backup filesystem UUID (`c16635fb-1b15-4049-a24f-90e8eeaed060`). It initializes the repository only when the repository directory is empty and has no `config` file. If the directory is non-empty without a Restic config, the role fails without initializing it, protecting existing data. Reapplying the role to an initialized repository does not run `restic init` again.

## Obsidian backup

The root-owned script `/usr/local/sbin/backup-obsidian` backs up `/mnt/storage/Obsidian` with the `obsidian` tag. Before a run, it verifies that the source and backup mounts have the expected UUIDs and that the source, repository, and password file are available. It then creates a snapshot and prunes snapshots tagged `obsidian`, keeping 7 daily, 4 weekly, and 6 monthly snapshots.

Systemd runs the script using the `backup-obsidian.service` oneshot unit. The `backup-obsidian.timer` is enabled and runs daily at 04:00, with `Persistent=true` so a missed run is triggered after the host is available again. Applying the Ansible role installs and enables the timer; it does not execute a backup immediately.

## Operations

Check the timer and recent backup logs on `NasHost`:

```bash
systemctl status backup-obsidian.timer
systemctl list-timers backup-obsidian.timer
sudo journalctl -u backup-obsidian.service
```

To trigger a backup manually, start the service explicitly:

```bash
sudo systemctl start backup-obsidian.service
```

To check the snapshots:

```bash
sudo env \
  RESTIC_REPOSITORY=/mnt/backup/restic-storage \
  RESTIC_PASSWORD_FILE=/root/.config/restic/storage-password \
  restic snapshots
```

To remove a snapshot (`--prune` cleans data not referenced anywhere):

```bash
sudo env \
  RESTIC_REPOSITORY=/mnt/backup/restic-storage \
  RESTIC_PASSWORD_FILE=/root/.config/restic/storage-password \
  restic forget a2a801b8 --prune
```

To restore a snapshot:

```bash
sudo mkdir -p /tmp/restic-restore-test
sudo env \
  RESTIC_REPOSITORY=/mnt/backup/restic-storage \
  RESTIC_PASSWORD_FILE=/root/.config/restic/storage-password \
  restic restore a2a801b8 \
  --target / \
  --include /mnt/storage/Obsidian
```

The snapshot keeps its tree structure. Thus, if we only used `--target /mnt/storage/Obsidian` the files would be restored to `/mnt/storage/Obsidian/mnt/storage/Obsidian/` which might not be ideal.

To check the diff between versions (no output means no change):

```bash
sudo diff -qr \
  /mnt/storage/Obsidian \
  /tmp/restic-restore-test/mnt/storage/Obsidian
```

To check file integrity (heavy disk I/O):
```bash
sudo env \
  RESTIC_REPOSITORY=/mnt/backup/restic-storage \
  RESTIC_PASSWORD_FILE=/root/.config/restic/storage-password \
  restic check --read-data
```


The source and backup filesystem UUIDs, repository and password paths, and script path are defined in `ansible/roles/services/restic/vars/main.yml`. The daily schedule is specified directly in the systemd timer template.