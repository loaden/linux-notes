#!/bin/bash
# 维护：Yuchen Deng [loaden] 钉钉群：35948877
# QQ群：19346666、111601117

#sudo apt purge evolution -y
sudo apt purge goldendict -y
sudo apt purge gnome-games -y
sudo apt purge gnome-music -y
sudo apt purge libreoffice-common -y
sudo apt purge libreoffice* -y
sudo apt purge rhythmbox -y
sudo apt purge transmission* -y
sudo apt purge xterm -y
sudo apt purge firefox-esr* -y
sudo apt purge fcitx5*

sudo apt install apt-file -y #搜索包
sudo apt install ibus-rime -y #输入法
sudo apt install audacious -y #音频播放器
sudo apt install build-essential -y #开发
sudo apt install fdupes -y #重复文件查找
sudo apt install gimp -y #图像编辑器
sudo apt install remmina -y #远程桌面
sudo apt install telnet -y #远程访问
sudo apt install unar -y #解压缩

sudo apt autopurge -y

