#!ipxe

set base-url http://deb.debian.org/debian/dists/bookworm/main/installer-arm64/current/images/netboot/debian-installer/arm64/

kernel ${base-url}linux initrd=initrd.gz auto=true priority=critical preseed/url=http://10.0.2.2/preseed.cfg
initrd ${base-url}initrd.gz
boot
