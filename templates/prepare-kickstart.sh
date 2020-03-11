#!/bin/bash

set -e

MIRROR={{ hcloud_ks__mirror }}/{{ hcloud_ks__version }}/os/x86_64/

wipefs --all --force /dev/{{ hcloud_ks__disk }}
parted -s /dev/{{ hcloud_ks__disk }} mklabel msdos
parted -s /dev/{{ hcloud_ks__disk }} mkpart primary 4M 200M
mkfs.ext4 -q -L OEMDRV /dev/{{ hcloud_ks__disk }}1
mount /dev/{{ hcloud_ks__disk }}1 /boot

curl -o /boot/vmlinuz $MIRROR/isolinux/vmlinuz
curl -o /boot/initrd.img $MIRROR/isolinux/initrd.img

grub-install --no-floppy /dev/{{ hcloud_ks__disk }}
cat >/boot/grub/grub.cfg <<EOF
set default=0
set timeout=5
menuentry "CentOS Kickstart" {
set root=(hd0,1)
linux /vmlinuz
initrd /initrd.img
}
EOF
