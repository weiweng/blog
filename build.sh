#!/bin/bash

# 使用hugo命令执行编译静态网站代码
if! hugo; then
    echo "执行hugo命令失败，以下是错误信息："
    echo "$(date +'%Y-%m-%d %H:%M:%S'): $(hugo 2>&1)" >&2
    exit 1
fi

# 定义目标目录变量
target_dir="/var/opt/www/index"

# 判断目标目录是否存在，不存在则创建
if [! -d "$target_dir" ]; then
    mkdir -p "$target_dir"
fi

# 先清空目标目录下的所有文件
rm -rf "$target_dir"/*

# 将当前目录中生成的docs目录下的所有文件移动到目标目录
mv docs/* "$target_dir"/