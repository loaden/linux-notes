#!/bin/bash
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
mount -o subvol=@home /dev/nvme0n1p2 /mnt/gentoo/home
mount --mkdir /dev/nvme0n1p1 /mnt/gentoo/boot/efi
cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
chroot /mnt/gentoo /bin/bash
