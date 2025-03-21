#!/bin/sh
echo "Content-Type: text/plain"
echo ""

# 检查WAN状态（使用ping 8.8.8.8作为示例）
ping -c 1 8.8.8.8 >/dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "1"  # 在线
else
    echo "0"  # 离线
fi