#!/bin/sh
echo "Content-Type: text/plain"
echo ""

# 获取addr参数
addr=$(echo "$QUERY_STRING" | sed 's/addr=//')

# 简单验证输入（防止命令注入）
if [ -z "$addr" ] || echo "$addr" | grep -q '[;&|]'; then
    echo "错误: 无效的地址"
    exit 0
fi

# 执行ping并返回结果
ping -c 4 "$addr" 2>&1