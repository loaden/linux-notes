#!/bin/bash
# 维护：Yuchen Deng - Loaden
# QQ群：19346666、111601117
# URL: https://fists.cc/posts/linux/ubuntu-wayland-screenshot-satty/
# Satty: https://github.com/Satty-org/Satty

# 生成一个带时间戳的临时文件路径
TMP_FILE="/tmp/screenshot_$(date +%s).png"

# 1. 调用 gnome-screenshot 进行区域截图
# -a: 区域选择模式 (Area)
# -f: 输出到文件
gnome-screenshot -a -f "$TMP_FILE"

# 2. 检查文件是否存在
# (如果用户按 Esc 取消了截图，文件就不会生成，防止 Satty 报错)
if [ -f "$TMP_FILE" ]; then
    # 3. 用 Satty 打开图片进行编辑
    satty --filename "$TMP_FILE" --copy-command wl-copy --early-exit

    # 4. (可选) 清理临时文件
    # Satty 编辑完复制到剪贴板后，这个原图就可以删了
    rm "$TMP_FILE"
fi
