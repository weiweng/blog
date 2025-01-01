#!/bin/bash

TARGET_DIR="/opt/1panel/apps/openresty/openresty/www/sites/weiweng.top/index"

# 进入当前目录（确保脚本执行时所在的当前目录就是期望操作的git仓库目录）
cd "$(dirname "$0")"

# 执行git pull操作，拉取最新代码
git pull

# 检查git pull命令执行的退出状态码
if [ $? -ne 0 ]; then
    echo "Git pull command failed. Exiting..."
    exit 1
fi

# 检查目标目录是否存在
if [! -d "$TARGET_DIR" ]; then
    echo "Target directory does not exist: $TARGET_DIR"
    exit 1

# 执行hugo命令
hugo

# 检查hugo命令执行是否成功，$? 表示上一个命令的退出状态码，0表示成功，非0表示失败
if [ $? -ne 0 ]; then
    echo "Hugo command failed. Exiting..."
    exit 1
fi

# 先删除/opt/www目录下的所有文件（需谨慎使用，确保这是预期的操作，避免误删重要文件）
rm -rf $TARGET_DIR/*

# 将docs目录下的所有文件拷贝到/opt/www目录下
cp -r docs/* $TARGET_DIR

echo "Hugo build completed successfully. Your website is now available at http://weiweng.top/"