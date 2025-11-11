# VMware Settings

## Enable Shared Folder

Add setting to `/etc/fstab`

```
.host:/share  /mnt/share  fuse.vmhgfs-fuse defaults,allow_other,nofail  0 0
```

## Enable Shared Folder (User Mode)

Create `~/.config/systemd/user/vmware-share.service`:

```systemd
[Unit]
Description=Mount VMware shared folder (user mode)
After=vmtoolsd.service
Wants=vmtoolsd.service

[Service]
Type=oneshot
ExecStart=/usr/bin/vmhgfs-fuse .host:/share %h/vmshare -o uid=%U,gid=%G,dmask=022,fmask=133
ExecStop=/bin/fusermount -u %h/vmshare
RemainAfterExit=yes
PrivateDevices=no
ProtectSystem=no
ProtectHome=no

[Install]
WantedBy=default.target
```

Then enable and start the service:

```
systemctl --user enable --now vmware-share.service
```
