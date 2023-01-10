# Arch 核心指南

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

* 中文语言

  > ```shell
  > # sed -i 's/#zh_CN.GBK/zh_CN.GBK/g' /etc/locale.gen
  > # locale-gen
  > # echo "LANG=zh_CN.UTF-8" > /etc/locale.conf

* 主机名称
  > `# echo <主机名> > /etc/hostname`

## 二、Arch 技巧总结

### 1. 启用archlinuxcn二进制源
