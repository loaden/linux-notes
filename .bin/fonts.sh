#!/bin/bash
# 维护：Yuchen Deng [loaden] 钉钉群：35948877
# QQ群：19346666、111601117

# 刷新字体缓存
fc-cache -rv

# 查询字体列表
fc-list :lang=zh-cn

# 查询字体匹配
fc-match --sort monospace:lang=zh-cn
fc-match --sort sans:lang=zh-cn
fc-match --sort serif:lang=zh-cn

# 查询字体名
fc-match -v SourceCodePro-Regular.otf | grep name
fc-match -v SourceHanSerifCN | grep name