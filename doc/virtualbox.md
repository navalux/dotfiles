# VirtualBox Settings

## Disable timesync with host

### /usr/lib/systemd/sysytem/vboxadd-service.service

Remove systemd-timesyncd.service from Conflicts.

```
Conflicts=shutdown.target
```

### /opt/VBoxGuestAdditions-x.x.x/init/vboxadd-service

Add $4

```
daemon() {
    $1 $2 $3 $4
}
```

Add --disable-timesync option

start() {
    // snip
    daemon $binary --pidfile $PIDFILE --disable-timesync > /dev/null
    // snip
}
