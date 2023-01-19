# Arch 核心指南

本指南优先选择 ***Wayland+GNOME*** 配置，x11 或者其他桌面仅供参考。LFS/Gentoo/Arch 相关技术交流请加**QQ群111601117**。

## 一、Arch 安装要点

### 1. 遵循官方维基指南

> <https://wiki.archlinux.org/title/Installation_guide>

### 2. 联网

* 查看网卡信息 `# ip link`
* 有线网络尽量自动获取地址
* 无线网卡使用 [iwctl](https://wiki.archlinux.org/title/Iwctl) 连接

  > ```shell
  > [iwd]# station list  #例如输出 wlan0
  > [iwd]# station wlan0 scan
  > [iwd]# station wlan0 get-networks
  > [iwd]# station wlan0 connect SSID
  > [iwd]# station wlan0 show

### 3. 检查时间

> `# timedatectl status`

### 4. 分区

* 推荐分区工具 [parted](https://wiki.archlinux.org/title/Parted)
* 查看分区 `# lsblk -f`
* 挂载示例

  > ```shell
  > # mkfs.fat -F32 /dev/nvme0n1p1
  > # mkfs.btrfs /dev/nvme0n1p2
  > # mount /dev/nvme0n1p2 /mnt
  > # mount --mkdir /dev/nvme0n1p1 /mnt/boot/efi

* 建议家目录单独分区，不建议使用 *swap* 分区
* 推荐使用 *[btrfs](https://wiki.archlinux.org/title/Btrfs)* 文件系统

### 5. 优选国内源

> reflector -c china -p https,http --fastest 5 --connection-timeout 2 --sort rate --save /etc/pacman.d/mirrorlist

### 6. 安装系统

* 基础系统与桌面
  > pacstrap -K /mnt base linux linux-firmware grub efibootmgr sudo nano networkmanager gnome bash-completion
* 分区挂载表
  > `# genfstab -L /mnt >> /mnt/etc/fstab`
* 切换到目标系统
  > `# arch-chroot /mnt`
* 创建与配置用户

  > ```shell
  > # echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
  > # useradd -m -G wheel <用户名>
  > # passwd <用户名>

* 启用服务

  > ```shell
  > # systemctl enable NetworkManager
  > # systemctl enable gdm

* 修改时区

  > ```shell
  > # ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  > # hwclock --systohc --localtime

* 中文语言和字体

  > ```shell
  > # sed -i 's/#zh_CN.UTF-8/zh_CN.UTF-8/g' /etc/locale.gen
  > # locale-gen
  > # echo "LANG=zh_CN.UTF-8" > /etc/locale.conf
  > # pacman -S adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts

* 在 *GRUB* 之前安装 [Microcode](https://wiki.archlinux.org/title/Microcode)

  > ```shell
  > # pacman -S intel-ucode #for Intel processors
  > # pacman -S amd-ucode #for AMD processors

* [GRUB](https://wiki.archlinux.org/title/GRUB) 启动加载器

  > ```shell
  > # grub-install
  > # grub-mkconfig -o /boot/grub/grub.cfg

* 主机名称
  > `# echo <主机名> > /etc/hostname`

* 实用工具 *[可选]*
  > `# pacman -S fakeroot patch ed git`

## 二、Arch 技巧总结

### 1. 启用archlinuxcn二进制源

* 修改配置文件
  > \# nano /etc/pacman.conf
* 尾部添加自定义源

  > ```text
  > [archlinuxcn]
  > Server = https://mirrors.bfsu.edu.cn/archlinuxcn/$arch

* 安装密钥

  > ```shell
  > # pacman -Syy
  > # pacman -S archlinuxcn-keyring

* 安装AUR包管理yay
  > `# pacman -S yay`

### 2. 安装中文输入法

* 安装 ibus-rime
  > `# pacman -S ibus-rime`
* 简体中文词库与配置
  > <https://github.com/loaden/rime>
* 设置 > 键盘 > 输入源，添加汉语“*中文(Rime)*”
* 设置环境变量，重启生效
  > `# nano /etc/environment`
  >
  > ```text
  > GTK_IM_MODULE=ibus
  > QT_IM_MODULE=ibus
  > XMODIFIERS=@im=ibus

* 文档
  > <https://wiki.archlinux.org/title/IBus>

### 3. 添加用户扩展

* 拷贝[推荐扩展](.local/share/gnome-shell/extensions)到相应目录
  > .local/share/gnome-shell/extensions
* 注销或者 *Alt+F2, r* 重启 *shell* 生效
* 更多扩展
  > <https://extensions.gnome.org>

### 4. 系统商店 “软件”

* 首先设置 Flatpak 国内软件源[加速](.bin/flatpak-config.sh)
  > <https://mirrors.sjtug.sjtu.edu.cn/docs/flathub>
* 其次安装系统软件包插件
  > `# pacman -S gnome-software-packagekit-plugin`
* 请耐心等待加载页面，之后考虑关闭 Flatpak 软件源

### 5. 用户商店 “AUR”

* 建议在线精准搜索
  > <https://aur.archlinux.org>
* 建议`yay`包管理

  > ```text
  > $ yay linuxqq #QQ
  > $ yay visual-studio-code #VSCode
  > $ yay dingtalk #钉钉
  > $ yay microsoft-edge #Edge浏览器
  > $ yay anydesk #AnyDesk
  > $ yay wps-office-cn #WPS

* 查询软件包信息 `yay -Ps`
* 卸载不需要的依赖包 `yay -Yc`
* `yay` 缓存路径
  > ~/.cache/yay

### 6. 触控手势

* 项目地址
  > <https://github.com/bulletmark/libinput-gestures>
* 从 archlinuxcn 源安装二进制包
  > `# pacman -S libinput-gestures`
* 将用户加入 input 组，重启生效
  > `# gpasswd -a <用户名> input`
* 安装扩展功能依赖
  > `# pacman -S wmctrl xdotool`
* 启动
  > `$ libinput-gestures-setup autostart start`
* 自定义[配置](.config/libinput-gestures.conf)

  > ```text
  > gesture swipe left _internal ws_up
  > gesture swipe right _internal ws_down
  > gesture swipe up xdotool key super+s
  > gesture swipe down xdotool key super+s
  > gesture pinch in xdotool key ctrl+minus
  > gesture pinch out xdotool key ctrl+plus

### 7. Snapper 备份还原

* 安装
  > `# pacman -S snapper`
* 配置

  > ```shell
  > # snapper create-config /
  > # snapper set-config ALLOW_GROUPS="wheel"

* 创建
  > `$ snapper create`
  >
  > * snapper create -d init -c number
  > * snapper create -d desc

* 查看
  > `$ snapper list`
* 还原
  > `$ snapper undochange 1..0`
