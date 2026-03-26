#!/bin/bash
# 维护：Yuchen Deng - Loaden
# QQ群：19346666、111601117

for dir in $(ls -d $PWD/*/)
do
    if [ -d "$dir"/.git ]; then
        echo "$dir" && git -C "$dir" $@
    fi
done
