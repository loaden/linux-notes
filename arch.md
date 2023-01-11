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
  > [iwd]# device list
  > [iwd]# station device scan
  > [iwd]# station device get-networks
  > [iwd]# station device connect SSID
  > [iwd]# known-networks list

### 3. 检查时间

> `# timedatectl status`

### 4. 分区

* 推荐分区工具 [parted](https://wiki.archlinux.org/title/Parted)
* 查看分区 `# lsblk -f`
* 挂载示例

  > ```shell
  > # mkfs.fat -F32 /dev/sda1
  > # mkfs.ext4 /dev/sda2
  > # mount /dev/sda2 /mnt
  > # mount --mkdir /dev/sda1 /mnt/boot/efi

* 建议家目录单独分区，不建议使用 *swap* 分区
* 推荐使用 *btrfs* 文件系统

### 5. 优选国内源

> reflector -c china -p https,http --fastest 5 --connection-timeout 2 --sort rate --save /etc/pacman.d/mirrorlist

### 6. 安装系统

* 基础系统与桌面
  > pacstrap -K /mnt base linux linux-firmware grub efibootmgr sudo nano networkmanager gnome bash-completion
* 自动挂载分区表
  > `# genfstab -L /mnt >> /mnt/etc/fstab`
* 切换到目标系统
  > `# arch-chroot /mnt`
* 创建与配置用户

  > ```shell
  > # useradd -m -G wheel <用户名>
  > # passwd <用户名>
  > # echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel

* 启用服务

  > ```shell
  > # systemctl enable NetworkManager
  > # systemctl enable gdm

* 修改时区

  > ```shell
  > # ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
  > # hwclock --systohc

* 中文语言和字体

  > ```shell
  > # sed -i 's/#zh_CN.GBK/zh_CN.GBK/g' /etc/locale.gen
  > # locale-gen
  > # echo "LANG=zh_CN.UTF-8" > /etc/locale.conf
  > # pacman -S adobe-source-han-sans-cn-fonts adobe-source-han-serif-cn-fonts

* 主机名称
  > `# echo <主机名> > /etc/hostname`

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
* 替换优化配置
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

* 查询软件包信息 `yay -Ps`
* 卸载不需要的依赖包 `yay -Yc`
* `yay` 缓存路径
  > ~/.cache/yay
