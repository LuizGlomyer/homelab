# Samba

One of my VMs is a dedicated NAS that exposes shares to the network via the SMB protocol.

## New disk configuration

A good approach would be to make a raw disk passthrough from Proxmox to the NAS VM. However, no Proxmox Terraform providers support this feature yet. Therefore, it needs to be done manually inside the Proxmox host, ssh into it and run the following commands:

```bash
# Useful to see all disks and their partitions in a organized way
lbslk 
# Grep the disk name from above to take its ID
ls -l /dev/disk/by-id/ | grep sda
# Use the disk reference to pass it to the VM
qm set 201 --scsi1 /dev/disk/by-id/ata-WDC_WD80EFPX-68C4ZN0_WD-RD32H19G
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

## Samba setup

Now we can run the [configure_nas](/ansible/roles/configure_nas/tasks/main.yml) Ansible role to continue. First, we need to set the variables, specially `storage_uuid`, which is the ID that comes from blkid. Passwords for the Samba users should be on the Ansible Vault as well. All shares are folders that have its own permissions, the exception being storage which is a share of the root of the disk accessible only to an admin user.

```bash
# Test your connection with a valid user
smbclient -U glomyer //192.168.0.201/storage

# Also, the disk structure is something like this:
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
