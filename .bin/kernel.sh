#!/bin/bash
# 维护：Yuchen Deng [loaden] 钉钉群：35948877
# QQ群：19346666、111601117

# 确认管理员权限
if [[ $EUID != 0 ]]; then
    echo "请打开终端，在脚本前添加 sudo 执行，或者 sudo -s 获得管理员权限后再执行。"
    exit 1
fi

# 拷贝后执行副本，预防修改后错乱
if [ "$0" != "/etc/$(basename $0)" ]; then
    cp -f $0 /etc/$(basename $0)
    bash /etc/$(basename $0)
    exit 0
fi

cd /usr/src/linux

# 启用Clang编译内核
BUILD_WITH_CLANG=0

# 初始本地配置
read -p "是否生成本地配置？[y/N/old]" choice
case $choice in
YES | yes | Y | y) mv .config .config.bak ; make localmodconfig && sleep 1 ;;
OLD | old | O | o) make oldconfig && sleep 1 ;;
N | n | '') true ;;
*) echo 错误选择，程序意外退出！ && exit ;;
esac

# 启用Clang薄LTO优化
if [ "$BUILD_WITH_CLANG" = "1" ]; then
    export LLVM=1
    scripts/config -e CONFIG_LTO_CLANG_THIN
else
    scripts/config --set-val CONFIG_CLANG_VERSION "0"
fi

# 自定义配置
if [[ -z "$(grep 'Custom Configuration' $PWD/.config)" ]]; then
    echo -e "\n# Custom Configuration" >> $PWD/.config
fi

# 启用
function set_enable()
{
    for arg in $*; do
        if [[ -n "$(grep $arg $PWD/.config)" ]]; then
            scripts/config -e $arg
            sed -i 's/# $arg is not set/$arg=y/g' $PWD/.config
            sed -i 's/$arg=m/$arg=y/g' $PWD/.config
        else
            echo "$arg=y" >> $PWD/.config
        fi
    done
}

# 禁用
function set_disable()
{
    for arg in $*; do
        if [[ -n "$(grep $arg $PWD/.config)" ]]; then
            scripts/config -d $arg
            sed -i 's/$arg=.*/# $arg is not set/g' $PWD/.config
        else
            echo "# $arg is not set" >> $PWD/.config
        fi
    done
}

# 模块
function set_module()
{
    for arg in $*; do
        if [[ -n "$(grep $arg $PWD/.config)" ]]; then
            scripts/config -m $arg
            sed -i 's/# $arg is not set/$arg=m/g' $PWD/.config
            sed -i 's/$arg=y/$arg=m/g' $PWD/.config
        else
            echo "$arg=m" >> $PWD/.config
        fi
    done
}

# 字符串
function set_string()
{
    if [[ -n "$(grep $1 $PWD/.config)" ]]; then
        scripts/config --set-str $1 "$2"
        sed -i "s/# $1 is not set/$1=\"$2\"/g" $PWD/.config
        sed -i "s/.*$1=.*/$1=\"$2\"/g" $PWD/.config
    else
        echo "$1=\"$2\"" >> $PWD/.config
    fi
}

# 数字
function set_value()
{
    if [[ -n "$(grep $1 $PWD/.config)" ]]; then
        scripts/config --set-var $1 "$2"
        sed -i "s/# $1 is not set/$1=$2/g" $PWD/.config
        sed -i "s/.*$1=.*/$1=$2/g" $PWD/.config
    else
        echo "$1=$2" >> $PWD/.config
    fi
}


# 通用设置
set_string CONFIG_DEFAULT_HOSTNAME "(none)"
set_string CONFIG_LOCALVERSION ""

set_disable \
    CONFIG_AUDIT \
    CONFIG_EXPERT \
    CONFIG_HYPERVISOR_GUEST \
    CONFIG_IKCONFIG_PROC \
    CONFIG_MICROCODE \
    CONFIG_MODULE_FORCE_LOAD \
    CONFIG_PRINTK_INDEX \
    CONFIG_PROFILING \
    CONFIG_X86_DECODER_SELFTEST \
    CONFIG_X86_EXTENDED_PLATFORM \
    CONFIG_X86_PLATFORM_DEVICES \

set_enable \
    CONFIG_CHECKPOINT_RESTORE \
    CONFIG_COMPAT_32 \
    CONFIG_IA32_EMULATION \
    CONFIG_IKCONFIG \

set_module \
    CONFIG_BINFMT_MISC \
    CONFIG_BLK_DEV_NVME \

set_value \
    CONFIG_LOG_BUF_SHIFT 16 \


# Gentoo配置
set_disable \
    CONFIG_GENTOO_LINUX_INIT_SCRIPT
set_enable \
    CONFIG_GENTOO_LINUX_INIT_SYSTEMD

# 精简
set_disable \
    CONFIG_ACPI_DEBUG \
    CONFIG_ACPI_WMI \
    CONFIG_ACRN_GUEST \
    CONFIG_AGP_INTEL \
    CONFIG_AMD_MEM_ENCRYPT \
    CONFIG_ANDROID \
    CONFIG_ARCH_CPUIDLE_HALTPOLL \
    CONFIG_ATA_PIIX \
    CONFIG_AUXDISPLAY \
    CONFIG_AX88796B_PHY \
    CONFIG_BLK_DEV_DM \
    CONFIG_BLK_DEV_MD \
    CONFIG_BLK_DEV_SR \
    CONFIG_BOOT_PRINTK_DELAY \
    CONFIG_CDROM \
    CONFIG_CGROUP_RDMA \
    CONFIG_CHROME_PLATFORMS \
    CONFIG_CPU_IDLE_GOV_TEO \
    CONFIG_CXL_BUS \
    CONFIG_DEBUG_BOOT_PARAMS \
    CONFIG_DEBUG_INFO \
    CONFIG_DEBUG_LIST \
    CONFIG_DEBUG_SHIRQ \
    CONFIG_DETECT_HUNG_TASK \
    CONFIG_DNS_RESOLVER \
    CONFIG_DRM_AMDGPU \
    CONFIG_DRM_DEBUG_MM \
    CONFIG_DRM_RADEON \
    CONFIG_DRM_VIRTIO_GPU \
    CONFIG_FB_INTEL \
    CONFIG_FUSION \
    CONFIG_GOOGLE_FIRMWARE \
    CONFIG_HAMRADIO \
    CONFIG_HARDLOCKUP_DETECTOR \
    CONFIG_HMM_MIRROR \
    CONFIG_HW_RANDOM \
    CONFIG_I2C_MUX \
    CONFIG_INET_TUNNEL \
    CONFIG_INIT_STACK_ALL_ZERO \
    CONFIG_INPUT_JOYDEV \
    CONFIG_INPUT_JOYSTICK \
    CONFIG_INPUT_MOUSEDEV \
    CONFIG_INPUT_TOUCHSCREEN \
    CONFIG_INPUT_UINPUT \
    CONFIG_INTEL_MEI \
    CONFIG_IPMI_HANDLER \
    CONFIG_IPV6_MIP6 \
    CONFIG_IP_FIB_TRIE_STATS \
    CONFIG_IP_NF_IPTABLES \
    CONFIG_ISDN \
    CONFIG_JAILHOUSE_GUEST \
    CONFIG_KALLSYMS_ALL \
    CONFIG_KARMA_PARTITION \
    CONFIG_KEXEC_JUMP \
    CONFIG_LATENCYTOP \
    CONFIG_LEGACY_VSYSCALL_EMULATE \
    CONFIG_LIBNVDIMM \
    CONFIG_LOGO \
    CONFIG_MACINTOSH_DRIVERS \
    CONFIG_MAC_EMUMOUSEBTN \
    CONFIG_MANAGER_SBS \
    CONFIG_MEDIA_ANALOG_TV_SUPPORT \
    CONFIG_MEDIA_TUNER \
    CONFIG_MEDIA_TUNER_TEA5761 \
    CONFIG_MEDIA_TUNER_TEA5767 \
    CONFIG_MELLANOX_PLATFORM \
    CONFIG_MFD_INTEL_PMC_BXT \
    CONFIG_MODULE_FORCE_UNLOAD \
    CONFIG_MODULE_SIG \
    CONFIG_MODULE_SRCVERSION_ALL \
    CONFIG_MOUSE_PS2 \
    CONFIG_MTD \
    CONFIG_NETFILTER_XTABLES \
    CONFIG_NETLINK_DIAG \
    CONFIG_NET_CLS_CGROUP \
    CONFIG_NET_FC \
    CONFIG_NET_IPIP \
    CONFIG_NET_IP_TUNNEL \
    CONFIG_NET_SCH_DEFAULT \
    CONFIG_NET_VENDOR_3COM \
    CONFIG_NET_VENDOR_ADAPTEC \
    CONFIG_NET_VENDOR_AGERE \
    CONFIG_NET_VENDOR_ALACRITECH \
    CONFIG_NET_VENDOR_ALTEON \
    CONFIG_NET_VENDOR_AMAZON \
    CONFIG_NET_VENDOR_AMD \
    CONFIG_NET_VENDOR_AQUANTIA \
    CONFIG_NET_VENDOR_ARC \
    CONFIG_NET_VENDOR_ATHEROS \
    CONFIG_NET_VENDOR_BROADCOM \
    CONFIG_NET_VENDOR_BROCADE \
    CONFIG_NET_VENDOR_CADENCE \
    CONFIG_NET_VENDOR_CAVIUM \
    CONFIG_NET_VENDOR_CHELSIO \
    CONFIG_NET_VENDOR_CISCO \
    CONFIG_NET_VENDOR_CORTINA \
    CONFIG_NET_VENDOR_DEC \
    CONFIG_NET_VENDOR_DLINK \
    CONFIG_NET_VENDOR_EMULEX \
    CONFIG_NET_VENDOR_EZCHIP \
    CONFIG_NET_VENDOR_GOOGLE \
    CONFIG_NET_VENDOR_HUAWEI \
    CONFIG_NET_VENDOR_INTEL \
    CONFIG_NET_VENDOR_LITEX \
    CONFIG_NET_VENDOR_MARVELL \
    CONFIG_NET_VENDOR_MELLANOX \
    CONFIG_NET_VENDOR_MICREL \
    CONFIG_NET_VENDOR_MICROCHIP \
    CONFIG_NET_VENDOR_MICROSEMI \
    CONFIG_NET_VENDOR_MICROSOFT \
    CONFIG_NET_VENDOR_MYRI \
    CONFIG_NET_VENDOR_NATSEMI \
    CONFIG_NET_VENDOR_NETERION \
    CONFIG_NET_VENDOR_NETRONOME \
    CONFIG_NET_VENDOR_NI \
    CONFIG_NET_VENDOR_NVIDIA \
    CONFIG_NET_VENDOR_OKI \
    CONFIG_NET_VENDOR_PACKET_ENGINES \
    CONFIG_NET_VENDOR_PENSANDO \
    CONFIG_NET_VENDOR_QLOGIC \
    CONFIG_NET_VENDOR_QUALCOMM \
    CONFIG_NET_VENDOR_RDC \
    CONFIG_NET_VENDOR_RENESAS \
    CONFIG_NET_VENDOR_ROCKER \
    CONFIG_NET_VENDOR_SAMSUNG \
    CONFIG_NET_VENDOR_SEEQ \
    CONFIG_NET_VENDOR_SILAN \
    CONFIG_NET_VENDOR_SIS \
    CONFIG_NET_VENDOR_SMSC \
    CONFIG_NET_VENDOR_SOCIONEXT \
    CONFIG_NET_VENDOR_SOLARFLARE \
    CONFIG_NET_VENDOR_STMICRO \
    CONFIG_NET_VENDOR_SUN \
    CONFIG_NET_VENDOR_SYNOPSYS \
    CONFIG_NET_VENDOR_TEHUTI \
    CONFIG_NET_VENDOR_TI \
    CONFIG_NET_VENDOR_VIA \
    CONFIG_NET_VENDOR_WIZNET \
    CONFIG_NET_VENDOR_XILINX \
    CONFIG_OSF_PARTITION \
    CONFIG_PACKET_DIAG \
    CONFIG_PAGE_IDLE_FLAG \
    CONFIG_PARAVIRT \
    CONFIG_PCIE_DW_PLAT_HOST \
    CONFIG_PCI_MESON \
    CONFIG_PERF_EVENTS_AMD_UNCORE \
    CONFIG_PINCTRL_AMD \
    CONFIG_PM_DEVFREQ \
    CONFIG_PM_GENERIC_DOMAINS \
    CONFIG_PM_TEST_SUSPEND \
    CONFIG_POWER_RESET_RESTART \
    CONFIG_PVH \
    CONFIG_RCU_TRACE \
    CONFIG_SCHEDSTATS \
    CONFIG_SCHED_STACK_END_CHECK \
    CONFIG_SERIAL_8250_DW \
    CONFIG_SERIAL_8250_FINTEK \
    CONFIG_SERIO \
    CONFIG_SGI_PARTITION \
    CONFIG_SLAB_MERGE_DEFAULT \
    CONFIG_SND_HRTIMER \
    CONFIG_SND_SEQUENCER \
    CONFIG_SOC_TI \
    CONFIG_SOFTLOCKUP_DETECTOR \
    CONFIG_SPI \
    CONFIG_SPI_AMD \
    CONFIG_SPI_SLAVE \
    CONFIG_STAGING \
    CONFIG_SUN_PARTITION \
    CONFIG_SURFACE_PLATFORMS \
    CONFIG_UCLAMP_TASK \
    CONFIG_UNIXWARE_DISKLABEL \
    CONFIG_UNIX_DIAG \
    CONFIG_VGA_SWITCHEROO \
    CONFIG_VHOST_MENU \
    CONFIG_VIDEO_IR_I2C \
    CONFIG_VIRTIO_MENU \
    CONFIG_VIRT_DRIVERS \
    CONFIG_WATCHDOG_PRETIMEOUT_GOV \
    CONFIG_WEXT_CORE \
    CONFIG_WLAN_VENDOR_ADMTEK \
    CONFIG_WLAN_VENDOR_ATH \
    CONFIG_WLAN_VENDOR_ATMEL \
    CONFIG_WLAN_VENDOR_BROADCOM \
    CONFIG_WLAN_VENDOR_CISCO \
    CONFIG_WLAN_VENDOR_INTEL \
    CONFIG_WLAN_VENDOR_INTERSIL \
    CONFIG_WLAN_VENDOR_MARVELL \
    CONFIG_WLAN_VENDOR_MICROCHIP \
    CONFIG_WLAN_VENDOR_QUANTENNA \
    CONFIG_WLAN_VENDOR_RALINK \
    CONFIG_WLAN_VENDOR_REALTEK \
    CONFIG_WLAN_VENDOR_RSI \
    CONFIG_WLAN_VENDOR_ST \
    CONFIG_WLAN_VENDOR_TI \
    CONFIG_WLAN_VENDOR_ZYDAS \


# 精简内核调试
set_value \
    CONFIG_CONSOLE_LOGLEVEL_DEFAULT 2
set_value \
    CONFIG_MESSAGE_LOGLEVEL_DEFAULT 3

set_disable \
    CONFIG_DEBUG_BUGVERBOSE \
    CONFIG_DEBUG_FS \
    CONFIG_DEBUG_KERNEL \
    CONFIG_DEBUG_MISC \
    CONFIG_DEBUG_PREEMPT \
    CONFIG_DYNAMIC_DEBUG \
    CONFIG_DYNAMIC_DEBUG_CORE \
    CONFIG_EARLY_PRINTK \
    CONFIG_FTRACE \
    CONFIG_MAGIC_SYSRQ \
    CONFIG_PRINTK_TIME \
    CONFIG_STACKTRACE_BUILD_ID \
    CONFIG_STRICT_DEVMEM \
    CONFIG_SYMBOLIC_ERRNAME \
    CONFIG_X86_DEBUG_FPU \
    RUNTIME_TESTING_MENU \


# 压缩模式
set_disable \
    CONFIG_MODULE_COMPRESS_ZSTD \
    CONFIG_ZSWAP \

set_enable \
    CONFIG_KERNEL_ZSTD \
    CONFIG_MODULE_COMPRESS_NONE \
    CONFIG_ZRAM \
    CONFIG_ZRAM_DEF_COMP_ZSTD \

# initramfs
set_enable \
    CONFIG_BLK_DEV_INITRD \
    CONFIG_BOOT_CONFIG \
    CONFIG_RD_ZSTD \

set_disable \
    CONFIG_RD_BZIP2 \
    CONFIG_RD_GZIP \
    CONFIG_RD_LZ4 \
    CONFIG_RD_LZMA \
    CONFIG_RD_LZO \
    CONFIG_RD_XZ \

# 桌面快速响应
set_disable \
    CONFIG_NO_HZ \

set_enable \
    CONFIG_BFQ_GROUP_IOSCHED \
    CONFIG_HZ_1000 \
    CONFIG_IOSCHED_BFQ \
    CONFIG_NO_HZ_IDLE \
    CONFIG_PREEMPT \
    CONFIG_SCHED_AUTOGROUP \
    CONFIG_TICK_CPU_ACCOUNTING \


# BPF调整
set_disable \
    CONFIG_BPF_PRELOAD \

set_enable \
    CONFIG_BPF \
    CONFIG_BPF_JIT \
    CONFIG_BPF_JIT_ALWAYS_ON \
    CONFIG_BPF_JIT_DEFAULT_ON \
    CONFIG_BPF_UNPRIV_DEFAULT_OFF \
    CONFIG_CGROUP_BPF \
    CONFIG_HAVE_EBPF_JIT \


# systemd需要
set_disable \
    CONFIG_SYSFS_DEPRECATED \

set_enable \
    CONFIG_BPF_SYSCALL \
    CONFIG_DEVTMPFS \
    CONFIG_EPOLL \
    CONFIG_EVENTFD \
    CONFIG_FHANDLE \
    CONFIG_INOTIFY_USER \
    CONFIG_PROC_FS \
    CONFIG_SHMEM \
    CONFIG_SIGNALFD \
    CONFIG_SYSFS \
    CONFIG_TIMERFD \


# iwd需要
set_enable \
    CONFIG_CRYPTO_AES \
    CONFIG_CRYPTO_CBC \
    CONFIG_CRYPTO_CMAC \
    CONFIG_CRYPTO_DES \
    CONFIG_CRYPTO_ECB \
    CONFIG_CRYPTO_HMAC \
    CONFIG_CRYPTO_MD4 \
    CONFIG_CRYPTO_MD5 \
    CONFIG_CRYPTO_SHA256 \
    CONFIG_CRYPTO_SHA512 \
    CONFIG_CRYPTO_USER_API_HASH \
    CONFIG_CRYPTO_USER_API_SKCIPHER \
    CONFIG_KEY_DH_OPERATIONS \
    CONFIG_PKCS8_PRIVATE_KEY_PARSER \

# 虚拟机需要
set_enable \
    CONFIG_VIRTUALIZATION \

set_module \
    CONFIG_KVM \
    CONFIG_KVM_INTEL \


# 牺牲安全性换性能
set_string \
    CONFIG_CMDLINE \
    "spectre_v1=off spectre_v2=off spec_store_bypass_disable=off pti=off"

set_disable \
    CONFIG_HARDENED_USERCOPY \
    CONFIG_KEYS_REQUEST_CACHE \
    CONFIG_KEY_NOTIFICATIONS \
    CONFIG_MQ_IOSCHED_KYBER \
    CONFIG_PAGE_TABLE_ISOLATION \
    CONFIG_PERSISTENT_KEYRINGS \
    CONFIG_RETPOLINE \
    CONFIG_SECURITY \
    CONFIG_SECURITYFS \
    CONFIG_SECURITY_DMESG_RESTRICT \
    CONFIG_STACKPROTECTOR \
    CONFIG_X86_INTEL_TSX_MODE_AUTO \

set_enable \
    CONFIG_CMDLINE_BOOL \
    CONFIG_X86_INTEL_TSX_MODE_ON \


# 苹果手机
set_module \
    CONFIG_USB_IPHETH \
    USB_NET_DRIVERS \


# 文件系统
set_disable \
    CONFIG_DNOTIFY \
    CONFIG_EXPORTFS_BLOCK_OPS \
    CONFIG_EXT4_FS_POSIX_ACL \
    CONFIG_EXT4_FS_SECURITY \
    CONFIG_EXT4_USE_FOR_EXT2 \
    CONFIG_FAT_DEFAULT_UTF8 \
    CONFIG_FS_DAX \
    CONFIG_FS_ENCRYPTION \
    CONFIG_FS_VERITY \
    CONFIG_NTFS3_LZX_XPRESS \
    CONFIG_QFMT_V2 \
    CONFIG_QUOTA \
    CONFIG_VIRTIO_FS \

set_enable \
    CONFIG_AUTOFS_FS \
    CONFIG_BTRFS_FS \
    CONFIG_BTRFS_FS_POSIX_ACL \
    CONFIG_MSDOS_FS \
    CONFIG_NTFS3_FS_POSIX_ACL \
    CONFIG_VFAT_FS \

set_module \
    CONFIG_CIFS \
    CONFIG_EXFAT_FS \
    CONFIG_EXT4_FS \
    CONFIG_FUSE_FS \
    CONFIG_ISO9660_FS \
    CONFIG_NETWORK_FILESYSTEMS \
    CONFIG_NTFS3_FS \
    CONFIG_UDF_FS \


# 显卡
set_disable \
    CONFIG_DRM_NOUVEAU

set_module \
    CONFIG_DRM_I915 \
    CONFIG_DRM_SIMPLEDRM \


# 蓝牙
set_disable \
    CONFIG_BT_BNEP \
    CONFIG_RFCOMM \

set_enable \
    CONFIG_BT_HCIBTUSB \
    CONFIG_BT_HCIUART \
    CONFIG_BT_HIDP \
    CONFIG_UHID \

set_module \
    CONFIG_BT \


# 摄像头
set_disable \
    CONFIG_MEDIA_DIGITAL_TV_SUPPORT \
    CONFIG_MEDIA_PCI_SUPPORT \
    CONFIG_MEDIA_RADIO_SUPPORT \
    CONFIG_MEDIA_TEST_SUPPORT \

set_enable \
    CONFIG_MEDIA_CAMERA_SUPPORT \
    CONFIG_MEDIA_PLATFORM_SUPPORT \
    CONFIG_MEDIA_SUBDRV_AUTOSELECT \
    CONFIG_MEDIA_SUPPORT_FILTER \
    CONFIG_MEDIA_USB_SUPPORT \
    CONFIG_SND_USB_AUDIO_USE_MEDIA_CONTROLLER \
    CONFIG_USB_VIDEO_CLASS_INPUT_EVDEV \
    CONFIG_VIDEO_V4L2_SUBDEV_API \

set_module \
    CONFIG_MEDIA_SUPPORT \
    CONFIG_SND_USB_AUDIO \
    CONFIG_SND_USB_UA101 \
    CONFIG_SND_USB_US122L \
    CONFIG_SND_USB_USX2Y \
    CONFIG_USB_VIDEO_CLASS \
    CONFIG_VIDEO_DEV \
    CONFIG_VIDEO_V4L2 \


# 无线网卡
set_enable \
    CONFIG_MT76_LEDS \
    CONFIG_WLAN_VENDOR_MEDIATEK \

set_module \
    CONFIG_MT76_CORE \
    CONFIG_MT76_USB \
    CONFIG_MT76x02_LIB \
    CONFIG_MT76x02_USB \
    CONFIG_MT76x2U \
    CONFIG_MT76x2_COMMON \


# 手机USB网络共享
set_module \
    CONFIG_USB_NET_DRIVERS \
    CONFIG_USB_USBNET \


# USB设备支持
set_disable \
    CONFIG_USB_OHCI_HCD \
    CONFIG_USB_SERIAL \
    CONFIG_USB_UHCI_HCD \

set_enable \
    CONFIG_USB_HID \
    CONFIG_USB_UAS \

set_module \
    CONFIG_QRTR \
    CONFIG_TYPEC \
    CONFIG_USB_PRINTER \
    CONFIG_USB_STORAGE \


# # #
# 刷新
scripts/config  --refresh


# # #
# 图形界面调整编译选项
# 一定要保存配置
make menuconfig

# 对比选项
echo scripts/diffconfig .config.bak .config
scripts/diffconfig .config.bak .config

# 输出配置文件大小
ls -lh .config

read -p "是否编译并安装内核？[y/N]" choice
case $choice in
Y | y) COMPILE_KERNEL=1 ;;
N | n | '') COMPILE_KERNEL=0 ;;
*) echo 错误选择，程序意外退出！ && exit ;;
esac

if [ "$COMPILE_KERNEL" = "1" ]; then
    make -j$(nproc) && make modules_install && make install
    find /boot/ -maxdepth 1 -mmin -1 -type f -name vmlinuz-* -exec cp -fv {} /boot/efi/EFI/gentoo/vmlinuz \; -print
    rm -f /etc/dracut.conf.d/*
    dracut --force /boot/initramfs-$(grep 'Kernel Configuration' /usr/src/linux/.config | cut -d ' ' -f 3).img \
        --hostonly --show-modules --modules "rootfs-block base btrfs" \
        --no-early-microcode --fstab --zstd
    find /boot/ -maxdepth 1 -mmin -1 -type f -name initramfs-*.img -exec cp -fv {} /boot/efi/EFI/gentoo/initramfs.img \; -print
    ls -lh /boot/efi/EFI/gentoo/
    ls -lh /boot/vmlinuz*
    ls -lh /boot/initramfs*
    du -sh /lib/modules/*
fi
