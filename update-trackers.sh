#!/bin/bash

# 定义 Tracker 列表 URL 和保存路径
TRACKER_URL="https://cf.trackerslist.com/best.txt"
ARIA2_CONF="$HOME/.aria2/aria2.conf"  # 根据你的配置文件路径修改
TMP_FILE="/tmp/trackers.txt"

# 下载最新的 Tracker 列表
curl -s $TRACKER_URL -o $TMP_FILE

# 检查是否下载成功
if [ -s $TMP_FILE ]; then
    # 将 Tracker 列表转换为逗号分隔的一行
    TRACKERS=$(cat $TMP_FILE | grep -v '^$' | tr '\n' ',' | sed 's/,$//')

    # 更新 aria2 配置文件
    if grep -q "bt-tracker=" $ARIA2_CONF; then
        # 替换已有的 bt-tracker 行
        sed -i "s|bt-tracker=.*|bt-tracker=$TRACKERS|g" $ARIA2_CONF
    else
        # 新增 bt-tracker 行
        echo "bt-tracker=$TRACKERS" >> $ARIA2_CONF
    fi

    # 通知 aria2 重新加载配置（需启用 RPC）
    # aria2c --rpc-secret=YOUR_RPC_SECRET --reload  # 如果使用 RPC
    killall -1 aria2c  # 发送 SIGHUP 信号重新加载配置
    echo "Tracker 列表已更新！"
else
    echo "下载 Tracker 列表失败！"
fi

# 清理临时文件
rm -f $TMP_FILE
