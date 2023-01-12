#!/bin/bash
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount -o subvol=@home /dev/sda2 /mnt/gentoo/home
mount /dev/sda1 /mnt/gentoo/boot/efi
cp /etc/resolv.conf /mnt/gentoo/etc/
chroot /mnt/gentoo /bin/bash
