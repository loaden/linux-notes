#!/bin/bash
# 维护：Yuchen Deng [loaden] 钉钉群：35948877
# QQ群：19346666、111601117
# https://mirrors.sjtug.sjtu.edu.cn/docs/flathub
# 上海交大智能镜像缓存

read -p "是否添加Flatpak国内源到系统目录？[y/N]" choice
case $choice in
    Y | y) SYSTEM_INSTALL=1 ;;
    N | n | '') SYSTEM_INSTALL=0 ;;
    *) echo 错误选择，程序意外退出！ && exit ;;
esac

if [ "$SYSTEM_INSTALL" == "1" ]; then
    sudo flatpak remote-add --system --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    sudo flatpak remote-modify --system flathub --url=https://mirror.sjtu.edu.cn/flathub
    sudo flatpak remote-modify --system flathub --prio=2
    sudo sed -i 's/.*url-is-set=.*/url-is-set=true/g' /var/lib/flatpak/repo/config
    [[ -z $(cat /var/lib/flatpak/repo/config | grep url-is-set=true ) ]] && sudo bash -c 'echo "url-is-set=true" >> /var/lib/flatpak/repo/config'
fi


read -p "是否添加Flatpak国内源到用户目录？[y/N]" choice
case $choice in
    Y | y) USER_INSTALL=1 ;;
    N | n | '') USER_INSTALL=0 ;;
    *) echo 错误选择，程序意外退出！ && exit ;;
esac

if [ "$USER_INSTALL" == "1" ]; then
    flatpak remote-add --user --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak remote-modify --user flathub --url=https://mirror.sjtu.edu.cn/flathub
    sed -i 's/.*url-is-set=.*/url-is-set=true/g' ~/.local/share/flatpak/repo/config
    [[ -z $(cat ~/.local/share/flatpak/repo/config | grep url-is-set=true ) ]] && echo "url-is-set=true" >> ~/.local/share/flatpak/repo/config
fi


flatpak remote-list --columns=name,title,options,priority,url
