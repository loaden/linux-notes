#!/bin/bash
# 维护：Yuchen Deng [loaden] 钉钉群：35948877
# QQ群：19346666、111601117

# 有些发行版会安装一堆字体，于是存在一堆字体配置
# 字体不是越多越好，字体配置更是如此
read -p "是否删除系统中可能影响字体效果的配置？[y/N]" choice
case $choice in
    Y | y) DEL_SYS_FONT_CONFS=1 ;;
    N | n | '') DEL_SYS_FONT_CONFS=0 ;;
    *) echo 错误选择，程序意外退出！ && exit ;;
esac
if test $DEL_SYS_FONT_CONFS; then
    sudo mkdir -pv /etc/fonts/conf.d.bak
    find /etc/fonts/conf.d/ -name "*.conf"  \
        ! -name "*hinting*"     \
        ! -name "*lcdfilter*"   \
        ! -name "*sansserif*"   \
        ! -name "*latin*"       \
        ! -name "*generic.conf" \
        ! -name "*user*"        \
        ! -name "*no-bitmaps*"  \
        -exec sudo mv -v {} /etc/fonts/conf.d.bak/ \; | sort
fi

# 刷新字体缓存
fc-cache -rv

# 检查字体匹配
fc-match Monospace
fc-match Sans
fc-match Serif
FC_DEBUG=1024 fc-match | grep Loading
fc-conflist | grep +
fc-match --verbose sans-serif | grep -v 00
# FC_DEBUG=4 fc-match Monospace | grep -v 00 > log
find /etc/fonts/conf.d/ -name "*.conf" | sort
echo
echo fc-match --sort 'serif:lang=zh-cn' ......
fc-match --sort 'serif:lang=zh-cn'
echo
echo fc-match --sort 'monospace:lang=zh-cn' ......
fc-match --sort 'monospace:lang=zh-cn'
echo
echo fc-match --sort 'sans-serif:lang=zh-cn' ......
fc-match --sort 'sans-serif:lang=zh-cn'
