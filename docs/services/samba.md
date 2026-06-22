# Samba

One of my VMs is a dedicated NAS that exposes shares to the network via the SMB protocol.

## New disk configuration

A good approach would be to make a raw disk passthrough from Proxmox to the NAS VM. However, no Proxmox Terraform providers support this feature yet. Therefore, it needs to be done manually inside the Proxmox host; ssh into it and run the following commands:

```bash
# Useful to see all disks and their partitions in a organized way
lbslk 
# Grep the disk name from above to take its ID
ls -l /dev/disk/by-id/ | grep sda
# Use the disk reference to pass it to the VM
qm set 201 --scsi1 /dev/disk/by-id/ata-WDC_WD80EFPX-68C4ZN0_WD-RD32H19G,backup=0
```
Now the VM has access to the disk, but we must first format it.

### Inside the VM

```bash
# Install needed packages
sudo apt install -y parted e2fsprogs util-linux
# Create GPT partition table
sudo parted /dev/sdb --script mklabel gpt
# Create partition (full disk), from 1MiB to 100% (disk end)
# 1MiB is to avoid boot sector overlap
sudo parted /dev/sdb mkpart primary 1MiB 100%
# Inform kernel of partition change
sudo partprobe /dev/sdb
# Create filesystem
sudo mkfs.ext4 /dev/sdb1
# Use UUID instead of device name. Device names change. UUIDs don’t.
sudo blkid /dev/sdb1
```

Then mount the disk and apply Samba using the [configure_smb](/ansible/roles/configure_smb/tasks/main.yml) role.

## Samba setup

Now we can run the [configure_smb](/ansible/roles/configure_smb/tasks/main.yml) Ansible role to continue. Volumes are defined in [`vars/main.yml`](/ansible/roles/configure_smb/vars/main.yml) as `smb_volumes`: each entry has `storage_uuid` (from the disk's `blkid`), `smb_volume_root_path`, `smb_volume_root_share` (admin-only root share name), and `smb_shares`. Passwords for Samba users belong in Ansible Vault. Non-admin shares are folders with their own permissions; each volume also exposes a root share (e.g. `storage`, `backup`) valid only for the admin user.

```bash
# See mounted partitions on SMB host
df -h 
# [Client] Test your connection with a valid user
smbclient -U glomyer //192.168.0.201/storage
# [Client] See mounted drives on the client
sudo mount -t cifs | grep mnt
# [NAS] See logs from the client connection
sudo tail -f /var/log/samba/log.b550m
# [NAS] Debug filesystem traversal permissions
sudo -u metube namei -l /mnt/storage/shared/metube
# [NAS] Debug ACL permissions
sudo getfacl /mnt/storage/videos/
# [NAS] Also, the disk structure is something like this:
ansible@nas-01:~$ sudo tree /mnt/storage/ -d -L 1
/mnt/storage/
├── music
├── shared
└── videos
```

### Samba user management

```bash
# Remove a samba user
sudo pdbedit -x glomyer
# Verify user
sudo pdbedit -L
# Check user groups
id glomyer
```

### Connection logs on clients

```bash
sudo journalctl -b | grep -i cifs
sudo journalctl -u remote-fs.target
# Make your share (/mnt/music) follow this pattern in order to inspect it
sudo systemctl status mnt-music.mount
cat /etc/fstab
```
