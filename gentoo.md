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

### 5. 编写挂载脚本

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
  > cp /etc/resolv.conf /mnt/gentoo/etc/
  > chroot /mnt/gentoo /bin/bash

* 执行脚本批量挂载并切换到目标系统
  > `# /mnt/gentoo/chroot.sh`

### 6. 核心配置

* 主配置

  > `# nano /etc/portage/make.conf`
  >
  > ```text
  > COMMON_FLAGS="-march=native -O2 -pipe"
  > ACCEPT_LICENSE="*"
  > GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo"
  > USE="wayland dbus policykit pipewire"

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

* 主机名称
  > `# echo <主机名> > /etc/hostname`
* 弱密码
  > `# sed -i 's/everyone/none/' /etc/security/passwdqc.conf`
* 启用基础的 systemd 单元
  > `# systemctl preset-all --preset-mode=enable-only`
* 更新环境变量
  > `# env-update && source /etc/profile`

### 7. 基础系统安装

* 更新软件数据库
  > `# emerge-webrsync`
* 更新 `@world` 集合
  > `# emerge -avuDN @world`
* 内核与硬件驱动
  > `# emerge -av gentoo-kernel-bin linux-firmware`
* 常用工具
  > `# emerge -av sudo gentoolkit bash-completion iwd ripgrep btrfs-progs`

* 创建与配置用户

  > ```shell
  > # useradd -m -G wheel <用户名>
  > # passwd <用户名>
  > # mkdir /etc/sudoers.d
  > # echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel

* 启动引导

  > ```shell
  > # emerge -av grub efibootmgr
  > # grub-install
  > # grub-mkconfig -o /boot/grub/grub.cfg
