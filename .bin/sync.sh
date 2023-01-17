#!/bin/bash
# 维护：Yuchen Deng [loaden] 钉钉群：35948877
# QQ群：19346666、111601117

# 仅允许普通用户权限执行
if [ $EUID == 0 ]; then
    echo $(basename $0) 命令只允许普通用户执行
    exit 1
fi

# portage
[ -d /etc/portage/ ] && rm -rf etc/portage/
mkdir -p etc/portage
[ -d /etc/portage/ ] && cp /etc/portage/make.conf etc/portage/
[ -d /etc/portage/ ] && cp -r /etc/portage/package.accept_keywords/ etc/portage/
echo "# Hi..." > etc/portage/package.accept_keywords/zz-autounmask
[ -d /etc/portage/ ] && cp -r /etc/portage/package.mask/ etc/portage/
[ -d /etc/portage/ ] && cp -r /etc/portage/package.use/ etc/portage/
echo "# Hi..." > etc/portage/package.use/zz-autounmask
[ -d /etc/portage/ ] && cp -r /etc/portage/env/ etc/portage/
[ -d /etc/portage/ ] && cp /etc/portage/package.env etc/portage/

# kernel config
[ -d /usr/src/linux/ ] && cp /usr/src/linux/.config usr/src/linux/
[ -d /usr/src/linux/ ] && find /usr/src/linux/ -maxdepth 1 -name ".config.*.*" -exec cp {} usr/src/linux/ \;

# mnt kernel config
[ -d /mnt/gentoo/ ] && cp /mnt/gentoo/usr/src/linux/.config.*.* usr/src/linux/

# ccache
[ -f /etc/ccache.conf ] && cp /etc/ccache.conf etc/

# iwd
[ -d /etc/iwd/ ] && cp -r /etc/iwd etc/

# network
[ -d /etc/systemd/ ] && rm -rf etc/systemd/
mkdir -p etc/systemd/network
cp -r /etc/systemd/network/* etc/systemd/network/

# fstab
cp -r /etc/fstab etc/

# world
[ -f /var/lib/portage/world ] && sudo cat /var/lib/portage/world > var/lib/portage/world

# dracut
[ -d /etc/dracut.conf.d ] && cp -r /etc/dracut.conf.d etc/

# systemd-boot
[ -d /boot/efi/loader ] && rm -rf boot/efi
mkdir -p boot/efi
sudo cp -r /boot/efi/loader boot/efi/
sudo chown $USER:$USER -R boot/efi/loader
rm boot/efi/loader/random-seed
