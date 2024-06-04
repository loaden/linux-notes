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
  GENTOO_MIRRORS="https://mirrors.bfsu.edu.cn/gentoo/"
  ```

  * 获取配置信息
    > `emerge --info`

  * 更新软件数据库
    > `# emerge-webrsync`

* 常用工具

  ```shell
  # emerge -au sudo links gentoolkit eix bash-completion dev-vcs/git
  # dispatch-conf
  ```

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
  # eselect profile set <number>
  $ eselect profile show
  ```

* systemd 初始化 & hostname

  ```shell
  # systemd-machine-id-setup
  # systemd-firstboot --prompt
  # systemctl preset-all
  ```

* [二进制包配置](etc/portage/binrepos.conf/gentoobinhost.conf)
  > `$ ld.so --help`

  `# nano etc/portage/binrepos.conf/gentoobinhost.conf`

  ```text
  [gentoobinhost]
  priority = 1
  sync-uri = https://mirrors.bfsu.edu.cn/gentoo/releases/amd64/binpackages/23.0/x86-64-v3/
  ```

  * 可选择全局选项
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

  ```text
  # <file system>  <mount point>  <type>  <options>               <dump>  <pass>
  /dev/nvme0n1p1   /boot/efi      vfat    umask=0077              0       0
  /dev/nvme0n1p2   /              btrfs   noatime,subvol=@gentoo  0       0
  /dev/nvme0n1p2   /home          btrfs   noatime,subvol=@home    0       0
  ```

* 弱密码
  > `# sed -i 's/everyone/none/' /etc/security/passwdqc.conf`

### 基础系统安装

* 更新 [`@world` 集合](var/lib/portage/world)
  > `# emerge -avuDN @world`

* 内核与硬件驱动
  > `# emerge -av linux-firmware gentoo-kernel-bin`

* 中文字体
  > `# emerge -av source-han-sans`

* 创建与配置用户

  ```shell
  # mkdir /etc/sudoers.d
  # echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
  # useradd -m -G wheel <用户名>
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
  # gpasswd -a <username> plugdev
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

* 查询
    > `$ LANG=C pactl info | grep "Server Name"`

### 启用[扩展库](etc/portage/repos.conf/eselect-repo.conf)

* 安装依赖
  > `# emerge -au eselect-repository dev-vcs/git`
* 启用
  > `# eselect repository enable gentoo-zh guru`
* 同步
  > `# emerge --sync gentoo-zh guru`

  * 克隆

    ```shell
    # git clone --depth 1 https://github.com/gentoo-mirror/guru.git /var/db/repos/guru
    # git clone --depth 1 https://github.com/gentoo-mirror/gentoo-zh.git /var/db/repos/gentoo-zh
    # emerge --update
    # eix-update
    ```

  * 手动同步

    ```shell
    # cd /var/db/repos/gentoo-zh
    # git pull
    # emerge --update
    # eix-update
    ```

### 普通用户授权

  > `# nano /etc/polkit-1/rules.d/10-admin.rules`

  ```text
  polkit.addAdminRule(function(action, subject) {
    return ["unix-group:wheel"];
  });
  ```

  > `# systemctl restart polkit.service`

### 字体配置

* 安装补充字体

  ```shell
  # emerge -av ubuntu-font-family source-code-pro
  # emerge -av --autounmask source-han-serif
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

* 注销电脑，之后：设置 - 键盘 - 输入源 - + - 汉语 - 中文(Rime)

### 常用软件

  ```shell
  # emerge -av microsoft-edge
  # emerge -avg gnome-text-editor
  # emerge -av vscode
  ```

## Gentoo 技巧总结

### 创建用户目录

  ```shell
  # emerge -av1 xdg-user-dirs
  $ xdg-user-dirs-update --force
  ```

### 清理未完成的安装任务
  >
  > `# emaint --fix cleanresume`

### 查询文件隶属哪个已安装包
  >
  > `# equery belongs eix`

### 通过文件查找未安装包

  ```shell
  # emerge -av pfl
  # e-file libunwind.a
  ```

### 查询 *USE* 被哪些包所用
  >
  > `# equery hasuse gnome-online-accounts`

### 查询已安装包文件列表
  >
  > `# equery files --tree eix`

### 查询 *EBUILD* 路径
  >
  > `# equery which eix`

### 恢复编译
  >
  > `# emerge --resume`

### 检查”孤儿”包
  >
  > `$ eix-test-obsolete`

### 检查系统已经安装的包版本
  >
  > `$ equery list '*'`

### 检查当前系统的glibc版本
  >
  > `# equery list glibc`

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

## Gentoo 平铺式桌面 [Sway](https://wiki.gentoo.org/wiki/Sway)

* 选择 `default/linux/amd64/23.0/desktop/systemd` 配置文件

  ```shell
  # eselect profile list
  # eselect profile set <number>
  # eselect profile show
  ```

### 网络

  ```shell
  # euse -p net-wireless/iwd standalone wired
  # emerge -av iwd
  # systemctl enable iwd
  ```

### [桌面](.config/sway/)
  >
  > `# emerge -av sway`

### [顶栏](.config/waybar/)

  ```shell
  # euse -p gui-apps/waybar -E network pulseaudio tray wifi
  # emerge -av --autounmask waybar
  # dispatch-conf
  # emerge -av --autounmask =fontawesome-6.1.1
  # dispatch-conf
  ```

### 启动器
  >
  > `# emerge -av --autounmask wofi`

### [终端](.config/foot/foot.ini)
  >
  > `# emerge -av foot`

### [通知](.config/mako/config)
  >
  > `# emerge -av gui-apps/mako`

### 登录管理器

  ```shell
  # emerge -av --autounmask tuigreet
  # systemctl enable greetd
  ```

* 修改配置
    > `# nano /etc/greetd/config.toml`

    ```text
    command = "tuigreet --cmd sway"
    ```

* 如果登录界面被日志覆盖
    > `# nano /etc/default/grub`

    ```text
    GRUB_CMDLINE_LINUX="quiet"
    ```

### [触控板](.config/sway/config)

  ```text
  input "1267:23:Elan_Touchpad" {
    dwt enabled
    tap enabled
    natural_scroll enabled
    middle_emulation enabled
  }
  ```

### 环境变量
  >
  > `# nano /etc/environment`

  ```text
  XDG_CURRENT_DESKTOP=sway
  XDG_SESSION_DESKTOP=sway
  ```

### 文件管理器

  > `# emerge -av thunar thunar-archive-plugin thunar-volman tumbler xarchiver`

* Thunar 右键终端

  当提示错误`无法启动类别“TerminalEmulator”的首选应用程序。`时，可以修改[配置文件](.config/xfce4/helpers.rc)，添加内容：
  > TerminalEmulator=foot

### 其他安装

* 文本编辑器
  > `# emerge -av leafpad`
* 视频播放器
  > `# emerge -av mpv`
* 音乐播放器
  > `# emerge -av audacious`
* 看图
  > `# emerge -av imv`
* 浏览器
  > `# emerge -av microsoft-edge`
* 开发
  > `# emerge -av vscode`

## Gentoo 定制内核

### 下载与选择源码

  ```shell
  # emerge -av gentoo-sources
  # eselect kernel list
  # eselect kernel set <number>
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
