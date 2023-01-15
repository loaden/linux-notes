# Gentoo 核心指南

本指南优先选择 ***Wayland+Sway*** 配置，x11 或者其他桌面仅供参考。LFS/Gentoo/Arch 相关技术交流请加**QQ群111601117**。

## 一、Gentoo 安装要点

### 1. 遵循官方维基指南

> <https://wiki.gentoo.org/wiki/Handbook>

### 2. 联网

> `# net-setup`

### 3. 挂载主分区

* 分区 `parted`，查询 `lsblk`
* 切记**不要**把根分区挂载到 `/mnt`，而是 `/mnt/gentoo`

  > ```shell
  > # mount -o subvol=@gentoo /dev/nvme0n1p2 /mnt/gentoo
  > # ls /mnt
  > cdrom gentoo key livecd

### 4. 下载 *stage3*

* *Ctrl+Alt+F2* 切换到 tty2
  > `# cd /mnt/gentoo`
* 下载 ***stage3-\*-desktop-systemd-\*.tar.xz***
  > `# links mirrors.bfsu.edu.cn/gentoo`
* 解压 stage3，注意解压参数
  > `# tar xpvf stage3-*.tar.xz --xattrs-include='*.*' --numeric-owner`
* tty2 查阅文档，使用翻页和方向键导航，支持鼠标交互
  > `# links wiki.gentoo.org/wiki/Handbook`

### 5. 编写[挂载脚本](.bin/chroot.sh)

* 安装与维护多次用到，请酌情修改 `# nano /mnt/gentoo/chroot.sh`

  > ```bash
  > #!/bin/bash
  > mount --types proc /proc /mnt/gentoo/proc
  > mount --rbind /sys /mnt/gentoo/sys
  > mount --make-rslave /mnt/gentoo/sys
  > mount --rbind /dev /mnt/gentoo/dev
  > mount --make-rslave /mnt/gentoo/dev
  > mount --bind /run /mnt/gentoo/run
  > mount --make-slave /mnt/gentoo/run
  > mount -o subvol=@home /dev/nvme0n1p2 /mnt/gentoo/home
  > mount --mkdir /dev/nvme0n1p1 /mnt/gentoo/boot/efi
  > cp --dereference /etc/resolv.conf /mnt/gentoo/etc/
  > chroot /mnt/gentoo /bin/bash

* 执行脚本批量挂载并切换到目标系统
  > `# /mnt/gentoo/chroot.sh`

### 6. 核心配置

* [主配置](etc/portage/make.conf)

  > `# nano /etc/portage/make.conf`
  >
  > ```text
  > ACCEPT_LICENSE="*"
  > GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo"
  > USE="dbus policykit"

* systemd 初始化

  > ```shell
  > # systemd-firstboot --prompt --setup-machine-id
  > # systemctl preset-all --preset-mode=enable-only

* 时区

  > ```shell
  > # ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  > # hwclock --systohc

* 中文语言

  > ```shell
  > # echo "zh_CN.UTF-8 UTF-8" >> /etc/locale.gen
  > # locale-gen
  > # echo "LANG=zh_CN.utf-8" > /etc/locale.conf
  > # eselect locale list

* [分区挂载表](etc/fstab)

  > ```text
  > # <file system>  <mount point>  <type>  <options>      <dump>  <pass>
  > /dev/nvme0n1p1   /boot/efi      vfat    umask=0077     0       0
  > /dev/nvme0n1p2   /              btrfs   noatime,subvol=@gentoo,discard=async,ssd  0  0
  > /dev/nvme0n1p2   /home          btrfs   noatime,subvol=@home,discard=async,ssd    0  0

* 弱密码
  > `# sed -i 's/everyone/none/' /etc/security/passwdqc.conf`

### 7. 基础系统安装

* 更新软件数据库
  > `# emerge-webrsync`
* 更新环境变量
  > `# env-update && source /etc/profile`
* 更新 [`@world` 集合](var/lib/portage/world)
  > `# emerge -avuDN @world`
* 内核与硬件驱动
  > `# emerge -av linux-firmware gentoo-kernel-bin`
* 常用工具
  > `# emerge -av sudo gentoolkit bash-completion ripgrep btrfs-progs`
* 中文字体
  > `# emerge -av source-han-sans source-code-pro`
* 网络

  > ```shell
  > # euse -p net-wireless/iwd standalone wired
  > # emerge -av iwd
  > # systemd enable iwd

* 创建与配置用户

  > ```shell
  > # mkdir /etc/sudoers.d
  > # echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
  > # useradd -m -G wheel <用户名>
  > # passwd <用户名>

* 启动引导

  > ```shell
  > # emerge -av grub efibootmgr
  > # grub-install
  > # grub-mkconfig -o /boot/grub/grub.cfg

### 8. 平铺式桌面 [Sway](https://wiki.gentoo.org/wiki/Sway)

* [桌面](.config/sway/)
  > `# emerge -av sway`
* [任务栏](.config/waybar/)

  > ```shell
  > # euse -p gui-apps/waybar network pulseaudio tray wifi
  > # dispatch-conf
  > # emerge -av --autounmask waybar
  > # emerge -av --autounmask =fontawesome-6.1.1

* 启动器
  > `# emerge -av --autounmask wofi`
* [终端](.config/foot/foot.ini)
  > `# emerge -av foot`
* [通知](.config/mako/config)
  > `# emerge -av gui-apps/mako`
* 登录管理器

  > ```shell
  > # emerge -av --autounmask tuigreet
  > # systemctl enable greetd

  * 修改配置
    > `# nano /etc/greetd/config.toml`
    > ```text
    > command = "tuigreet --cmd sway"

  * 如果登录界面被日志覆盖
    > `# nano /etc/default/grub`
    > ```text
    > GRUB_CMDLINE_LINUX="quiet"

* 文件管理器
  > `# emerge -av thunar`
* 视频播放器
  > `# emerge -av mpv`
* 看图
  > `# emerge -av imv`
* 浏览器
  > `# emerge -av microsoft-edge`
* 代码
  > `# emerge -av --autounmask vscode`

## 二、Gentoo 技巧总结

### 1. 启用 gentoo-zh

* 安装依赖
  > `# emerge -av eselect-repository dev-vcs/git`
* 启用
  > `# eselect repository enable gentoo-zh`
* 同步
  > `# emerge --sync`
* 手动同步

  > ```shell
  > # cd /var/db/repos/gentoo-zh
  > # git pull

### 2. 创建用户目录

> ```shell
> # emerge -av1 xdg-user-dirs
> # xdg-user-dirs-update --force

### 3. 清理未完成的安装任务

> `# emaint --fix cleanresume`
