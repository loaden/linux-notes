#!/bin/bash
# 维护：Yuchen Deng - Loaden
# QQ群：19346666、111601117

sudo journalctl --vacuum-size=50M
sudo sed -i 's/.*SystemMaxUse=.*/SystemMaxUse=1g/' /etc/systemd/journald.conf
cat /etc/systemd/journald.conf | grep ^SystemMaxUse=
