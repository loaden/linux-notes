#!/bin/bash
# 维护：Yuchen Deng [loaden] 钉钉群：35948877
# QQ群：19346666、111601117

sudo grub-mkconfig -o /boot/efi/grub.cfg
sudo sed -i 's/ \/boot\/vmlinuz/ \/@debian\/boot\/vmlinuz/' /boot/efi/grub.cfg
sudo sed -i 's/ \/boot\/initrd/ \/@debian\/boot\/initrd/' /boot/efi/grub.cfg
echo 'Debian Fixing...'
sudo cat /boot/efi/grub.cfg | grep /@debian/boot
echo 'Done!'
