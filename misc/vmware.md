# VMware Settings

## Enable shared folder

Add setting to `/etc/fstab`

```
.host:/share  /mnt/share  fuse.vmhgfs-fuse defaults,allow_other,nofail  0 0
```
