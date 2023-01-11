#!/bin/bash
# 维护：Yuchen Deng [loaden] 钉钉群：35948877
# QQ群：19346666、111601117

efibootmgr
read -p "请选择下次启动的系统：" next
sudo efibootmgr -n $next
[ $? -eq 0 ] && sleep 2
[ $? -eq 0 ] && sudo reboot
