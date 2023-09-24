#!/bin/bash
# 维护：Yuchen Deng [loaden] 钉钉群：35948877
# QQ群：19346666、111601117

# 刷新字体缓存
fc-cache -rf

# 查询字体列表
fc-list :lang=zh-cn

# 查询字体匹配
echo
echo fc-match --sort monospace:lang=zh
fc-match --sort monospace:lang=zh
echo
echo fc-match --sort sans:lang=zh
fc-match --sort sans:lang=zh
echo
echo fc-match --sort serif:lang=zh
fc-match --sort serif:lang=zh

# 查询字体名
fc-match -v SourceCodePro-Regular.otf | grep name
fc-match -v SourceHanSerifCN | grep name
fc-match -v SourceHanSansCN | grep name
fc-match -v Ubuntu | grep name
