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
[ -d /etc/portage/ ] && cp -r /etc/portage/package.use/ etc/portage/
rm -f etc/portage/package.use/zz-autounmask
[ -d /etc/portage/env ] && cp -r /etc/portage/env/ etc/portage/
[ -f /etc/portage/package.env ] && cp /etc/portage/package.env etc/portage/

# kernel config
[ -d /usr/src/linux/ ] && cp /usr/src/linux/.config usr/src/linux/
[ -d /usr/src/linux/ ] && find /usr/src/linux/ -maxdepth 1 -name ".config.*.*" -exec cp {} usr/src/linux/ \;

# environment
cp /etc/environment etc/

# world
[ -f /var/lib/portage/world ] && cp /var/lib/portage/world var/lib/portage/world

# dracut
[ -d /etc/dracut.conf.d ] && cp -r /etc/dracut.conf.d etc/
