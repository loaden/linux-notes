# Gentoo 核心笔记

本指南优先选择 ***Systemd+GNOME*** 配置，其他桌面仅供参考。LFS/Gentoo/Arch 相关技术交流请加**QQ群111601117**。

## Gentoo 安装要点

### 遵循官方维基指南

  > <https://wiki.gentoo.org/wiki/Handbook>

### 联网

  > `# net-setup  or livegui`

### 挂载主分区

* 分区 `parted`，查询 `lsblk`

* 切记**不要**把根分区挂载到 `/mnt`，而是 `/mnt/gentoo`

  ```shell
  # mount -o subvol=@gentoo /dev/nvme0n1p2 /mnt/gentoo
  # ls /mnt
  cdrom gentoo key livecd
  ```

  * 注意修改实际分区名

### 下载 *stage3*

* *Ctrl+Alt+F2* 切换到 tty2
  > `# cd /mnt/gentoo`
* 下载 ***stage3-\*-desktop-systemd-\*.tar.xz***
  > `# links mirrors.bfsu.edu.cn/gentoo`
* 解压 stage3，注意解压参数
  > `# tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner`
* tty2 查阅文档，使用翻页和方向键导航，支持鼠标交互
  > `# links wiki.gentoo.org/wiki/Handbook`
* 通过按 q 来关闭命令行浏览器

### 编写[挂载脚本](.bin/chroot.sh)

* 安装与维护多次用到，请酌情修改 `# nano /mnt/gentoo/chroot.sh`

  ```bash
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
  echo "nameserver 4.2.2.1" > /mnt/gentoo/etc/resolv.conf
  chroot /mnt/gentoo /bin/bash
  ```

  * 注意修改实际分区名

* 执行脚本批量挂载并切换到目标系统
  > `# /mnt/gentoo/chroot.sh`

* 更新环境变量
  > `# env-update && source /etc/profile && export PS1="(chroot) ${PS1}"`

### 核心配置

* [主配置](etc/portage/make.conf)

  `# nano /etc/portage/make.conf`

  ```text
  COMMON_FLAGS="-march=native -O2 -pipe"

  ACCEPT_LICENSE="*"
  GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo"
  USE="vpx screencast -gnome-online-accounts"
  ```

  * 全局USE的修改，是为了去除`webkit-gtk`依赖

  * 获取配置信息
    > `emerge --info`

  * 更新软件数据库
    > `# emerge-webrsync`

* 常用工具
  > `# emerge -au sudo gentoolkit eix bash-completion dev-vcs/git`

* [Git 方式同步](etc/portage/repos.conf/gentoo.conf)
  > `# mkdir -p /etc/portage/repos.conf`

  `# nano /etc/portage/repos.conf/gentoo.conf`

  ```text
  [DEFAULT]
  main-repo = gentoo

  [gentoo]
  location = /var/db/repos/gentoo
  sync-type = git
  sync-uri = https://mirrors.bfsu.edu.cn/git/gentoo-portage.git
  ```

  * 查询软件源信息
    >`$ portageq repos_config /`

  * 更新替换软件源

    ```shell
    # 删除本地 main tree 目录
    rm -rf /var/db/repos/gentoo

    # 重新同步
    emerge --sync
    ```

* 选择 `default/linux/amd64/23.0/desktop/gnome/systemd` 配置文件

  ```shell
  $ eselect profile list
  # eselect profile set <序号>
  $ eselect profile show
  ```

* systemd 初始化 & hostname

  ```shell
  # systemd-machine-id-setup
  # systemd-firstboot --prompt
  # systemctl preset-all
  ```

* [二进制包配置](etc/portage/binrepos.conf/gentoobinhost.conf)
  > 先查询CPU支持情况: `$ ld.so --help`

  > 然后再修改：
  `# nano /etc/portage/binrepos.conf/gentoobinhost.conf`

  ```text
  [gentoobinhost]
  priority = 1
  sync-uri = https://mirrors.bfsu.edu.cn/gentoo/releases/amd64/binpackages/23.0/x86-64-v3/
  ```

  * 可选择全局选项（不建议）
  > `# nano /etc/portage/make.conf`

  ```text
  FEATURES="${FEATURES} getbinpkg"
  FEATURES="${FEATURES} binpkg-request-signature"
  PORTAGE_TRUST_HELPER=true
  ```

  * 获取密钥
     > `# rm -rf /etc/portage/gnupg ; getuto`

  * 测试安装二进制包
    > `# emerge -avg nano`

* 时区

  ```shell
  # ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  # hwclock --systohc --localtime
  ```

* 中文语言

  ```shell
  # echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
  # locale-gen
  # echo "LANG=zh_CN.utf-8" > /etc/locale.conf
  # eselect locale list
  ```

* [分区挂载表](etc/fstab)
  > `# nano /etc/fstab`

  ```text
  # <file system>  <mount point>  <type>  <options>               <dump>  <pass>
  /dev/nvme0n1p1   /boot/efi      vfat    umask=0077              0       0
  /dev/nvme0n1p2   /              btrfs   noatime,subvol=@gentoo  0       0
  /dev/nvme0n1p2   /home          btrfs   noatime,subvol=@home    0       0
  ```

* 弱密码
  > `# sed -i 's/everyone/none/' /etc/security/passwdqc.conf`

### 基础系统安装

* 内核与硬件驱动

  ```shell
  # emerge -av gentoo-kernel-bin linux-firmware
  # dispatch-conf
  ```

* 系统更新 [`@world`](var/lib/portage/world)
  > `# emerge -avuDNg @world`

* 中文字体
  > `# emerge -av source-han-sans`

* 创建与配置用户

  ```shell
  # mkdir /etc/sudoers.d
  # echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
  # useradd -d /home/<用户目录名> -mG wheel <用户名>
  # passwd <用户名>
  ```

* 启动引导

  ```shell
  # emerge -av grub efibootmgr
  # grub-install
  # grub-mkconfig -o /boot/grub/grub.cfg
  ```

### 桌面安装

* 支持内置屏幕录制
  > `# euse -E vpx screencast`

* [移除webkit-gtk依赖](https://wiki.gentoo.org/wiki/GNOME/Guide#Emerge)

  ```shell
  # euse -p gnome-base/nautilus -D previewer
  # euse -D gnome-online-accounts
  # emerge -p gnome-light | grep webkit
  ```

* 安装桌面
  > `# emerge -avg gnome-light`

* 添加用户组

  ```shell
  $ getent group plugdev
  # usermod -aG plugdev <用户名>
  $ groups <用户名>
  $ id <用户名>
  ```

* 启用显示管理器
  > `# systemctl enable gdm.service`

### 清理重启

  ```shell
  # exit
  # umount -Rl /mnt/gentoo
  # reboot
  ```

## Gentoo 登录桌面后配置

### 启动网络服务
>
> `# systemctl enable --now NetworkManager`

### 启动蓝牙服务
>
> `# systemctl enable --now bluetooth`

### 启动音频服务

  ```shell
  systemctl --user enable --now pulseaudio
  systemctl --user status pulseaudio
  ```

### 启动PipeWire服务

* 必须启用，否则PipeWire相关功能不正常，例如OBS捕获屏幕黑屏等。

  ```shell
  systemctl --user enable --now pipewire
  systemctl --user enable --now wireplumber
  ```

  * 这个依赖也是必须的
    > `# emerge -av xdg-desktop-portal-wlr`

* 查询
    > `$ LANG=C pactl info | grep "Server Name"`

### 启用[扩展库](etc/portage/repos.conf/eselect-repo.conf)

* 安装工具
  > `# emerge -au eselect-repository`
* 启用软件源
  > `# eselect repository enable guru gentoo-zh`

* 独立同步，提高成功率

  ```shell
  # emerge --sync guru
  # emerge --sync gentoo-zh
  ```

  * 查询软件源信息
    >`$ portageq repos_config /`

  * 手动克隆

    ```shell
    # git clone --depth 1 https://github.com/gentoo-mirror/guru.git /var/db/repos/guru
    # git clone --depth 1 https://github.com/gentoo-mirror/gentoo-zh.git /var/db/repos/gentoo-zh
    ```

  * 手动同步

    ```shell
    # cd /var/db/repos/guru
    # git pull
    ```

  * 更新数据库
      > `# eix-update`

### 普通用户授权

  > `# nano /etc/polkit-1/rules.d/49-wheel.rules`

```text
polkit.addAdminRule(function(action, subject) {
  return ["unix-group:wheel"];
});
```

  > `# systemctl restart polkit.service`

### 字体配置

* 安装补充字体

  ```shell
  # emerge -avg ubuntu-font-family source-code-pro
  # emerge -avg --autounmask source-han-serif
  # dispatch-conf
  ```

* [用户字体配置文件](.config/fontconfig/fonts.conf)
  > ~/.config/fontconfig/fonts.conf

* 查看字体匹配顺序

  ```shell
  fc-match --sort monospace:lang=zh
  fc-match --sort sans:lang=zh
  fc-match --sort serif:lang=zh
  ```

### 输入法

  ```shell
  # emerge -avg ibus-rime --autounmask
  # dispatch-conf
  ```

* 执行重启`ibus`输入法框架命令，或者注销电脑
  > `$ ibus restart`

* 添加输入法
  * 设置 - 键盘 - 输入源 - + - 汉语 - 中文(Rime)

### GNOME组件补充

  ```shell
  # emerge -avug gnome-text-editor gnome-disk-utility gnome-calculator gnome-tweaks evince eog file-roller
  ```

### 常用软件

* 提前配置USE

  ```shell
  # euse -p media-video/obs-studio -E pipewire v4l
  # euse -p media-libs/opencv -E contrib
  # euse -p app-editors/vscode -D wayland
  # euse -p media-video/ffmpeg -E x265
  ```

* 批量安装

  ```shell
  # emerge -avug --autounmask microsoft-edge vscode celluloid audacious gimp obs-studio ffmpeg kdenlive flameshot
  ```

### 扩展软件

  ```shell
  # emerge -avug --autounmask wps-office dingtalk tencent-qq wechat neofetch xlsclients
  ```

### 远程桌面

  ```shell
  # euse -p net-misc/remmina -E vnc rdp
  # emerge -avg remmina
  ```

### 科学上网

  ```shell
  # emerge -avg cloudflare-warp --autounmask
  # dispatch-conf
  ```

* 启动服务

  ```shell
  # systemctl enable --now warp-svc.service
  $ systemctl --user enable --now warp-taskbar.service
  ```

### 快照还原

* 安装

  ```shell
  # emerge -avg --autounmask timeshift btrfs-progs
  # dispatch-conf
  ```

* 加入用户组

  ```shell
  # usermod -aG cron <用户名>
  ```

* Timeshift只支持安装在`@`子卷中的系统，并且家目录挂载在`@home`子卷上。

### Overlay仓库

* 海量野包下载：<https://gpo.zugaina.org/>

* 创建本地仓库 `lucky`
  > `$ eselect repository create lucky`

* 安装野包
  * 以 `net-misc/synology-drive-client` 野包为例：<https://gpo.zugaina.org/net-misc/synology-drive-client>

  ```shell
  # mkdir -p /var/db/repos/lucky/net-misc/synology-drive-client
  # cp synology-drive-client-3.5.0.16084.ebuild /var/db/repos/lucky/net-misc/synology-drive-client/
  # ebuild /var/db/repos/lucky/net-misc/synology-drive-client/synology-drive-client-3.5.0.16084.ebuild manifest
  # eix-update
  # emerge -avg =synology-drive-client-3.5.0.16084 --autounmask
  # dispatch-conf
  ```

### HP打印机配置

* 安装`cups`扩展

  ```shell
  # emerge -avg cups-filters
  # systemctl restart cups
  ```

* 安装驱动

  ```shell
  # euse -p net-print/hplip -D qt5 snmp libnotify
  # emerge -avg hplip-plugin
  # hp-setup
  ```

  * 扫描
    > `# emerge -avg simple-scan`

## Gentoo 技巧总结

### 紧凑模式搜索以`ibus`开头的包
  >
  > `$ eix -c ^ibus`

### 紧凑模式搜索以`editor`结尾的包
  >
  > `$ eix -c editor$`

### 紧凑模式搜索`ibus`且包含`engine`描述的包
  >
  > `$ eix -c -S engine ibus`

### 查询文件隶属哪个已安装包
  >
  > `$ equery belongs eix` </br>
  > `$ equery b eix`

### 查询 *USE* 被哪些包所用
  >
  > `$ equery hasuse gnome-online-accounts` </br>
  > `$ equery h gnome-online-accounts`

### 查询已安装包文件列表
  >
  > `$ equery files --tree eix` </br>
  > `$ equery f --tree eix`

### 查询 *EBUILD* 路径
  >
  > `$ equery which eix` </br>
  > `$ equery w eix`

### 检查系统已经安装的包版本
  >
  > `$ equery list '*'` </br>
  > `$ equery l '*'`

### 检查当前系统的glibc版本
  >
  > `$ equery list glibc` </br>
  > `$ equery l glibc`

### 通过文件查找未安装包

  ```shell
  # emerge -av pfl
  $ e-file libunwind.a
  ```

### 清理源文件
  >
  > `# eclean-dist --deep`

### 清理二进制文件
  >
  > `# eclean-pkg --deep`

### 清理旧内核

  ```shell
  # emerge -av eclean-kernel
  # eclean-kernel --list-kernels
  # eclean-kernel -n 2
  ```

### 查询已安装包
  >
  > `$ eix xdg-desktop- --installed`

### 恢复编译
  >
  > `# emerge --resume`

### 清理未完成的安装任务
  >
  > `# emaint --fix cleanresume`

### 检查”孤儿”包
  >
  > `$ eix-test-obsolete`

### 更新时 Github 下载包失败

  部分ebuild需要从github.com下载包，但墙的原因，可能会下载失败，此时可通过命令获取需要下载包的链接地址。
  >
  > `# tail -f /var/log/emerge-fetch.log`

  通过 <https://gh.api.99988866.xyz> Github下载加速，
  将下载到的包拷贝到缓存目录 `/var/cache/distfiles`，删除与该文件相关的lock隐藏文件及下载缓存文件，再次运行更新命令即可。

### 查询服务

  ```shell
  systemctl list-unit-files --state=enabled
  systemctl list-unit-files --state=disabled
  systemctl list-unit-files --state=enabled --user
  systemctl list-unit-files --state=disabled --user
  systemctl list-units --type=service --state=running
  systemctl list-units --type=service --state=active
  systemctl list-units --type=service
  ```

### 从`@world`集合中移除包
  >
  > `# emerge --deselect gnumeric`

### 修改用户主目录

* 注销桌面，进另一个`tty`登录`root`
  >
  > `# usermod -d <新目录> -m <用户名>`
  * `-m` 选项将原主目录中的文件全部移动到新主目录。

### 修改用户名

* 注销桌面，进另一个`tty`登录`root`
  >
  > `# usermod -l <新用户名> <旧用户名>`

### 修改用户组名
  >
  > `# groupmod -n <新组名> <旧组名>`

### Flameshot支持Wayland

* 方法一：GNOME添加快捷键命令
  > `script --command "flameshot gui"`
* 方法二：终端运行 `nohup flameshot &`

### 修复编译链接错误

  一般是二进制的包与当前编译的包使用了不同的编译器，错误信息如下:

  ```shell
  libQt5Core.so: undefined reference to `__cxa_call_terminate@CXXABI_1.3.15'
  ```

  尝试切换到高版本的GCC编译器: `eselect gcc`

## Gentoo 定制内核 <可忽略>

### 下载与选择源码

  ```shell
  # emerge -av gentoo-sources
  # eselect kernel list
  # eselect kernel set <序号>
  # ls -l /usr/src
  ```

### 从官方二进制内核生成配置

  ```shell
  # uname -r
  5.15.88-gentoo-dist
  # cd /usr/src/linux
  # make help
  # make localyesconfig
  ```

### 修改配置

  ```shell
  # cp .config .config.bak
  # scripts/config -d CONFIG_GENTOO_LINUX_INIT_SCRIPT
  # scripts/config -e CONFIG_GENTOO_LINUX_INIT_SYSTEMD
  # scripts/config --set-str CONFIG_LOCALVERSION ""
  # scripts/config  --refresh
  # scripts/diffconfig .config.bak .config
  ```

* 这里只是修改了 Gentoo 相关的基本配置，请根据自己的硬件定制配置。
* 建议通过[脚本文件](.bin/kernel.sh)来逐步完善配置。

### 编译
  >
  > `# make -j$(nproc) && make modules_install && make install`

### 生成 initrd
  >
  > `# dracut /boot/initramfs-5.15.88-gentoo.img --force --hostonly --modules "rootfs-block base btrfs" --early-microcode --fstab --zstd`

### 启动
  >
  > `# grub-mkconfig -o /boot/grub/grub.cfg`

### [定制](.bin/kernel.sh)
  >
  > .bin/kernel.sh

## Gentoo 程序开发 <可忽略>

### Rust 环境配置

* 调整`rust-bin`的USE
  > `# euse -p dev-lang/rust-bin -E rust-analyzer rust-src rustfmt doc`

* 安装
  > `# emerge -avuDNg rust-bin rustup --autounmask`

* 配置
  > `$ rustup-init-gentoo --symlink`

  * 将 `.cargo/bin` 添加到 `PATH` 最前面
