#!/bin/bash

# 设置环境变量的默认值
export LINUXDO_USERNAME=${LINUXDO_USERNAME:-""}
export LINUXDO_PASSWORD=${LINUXDO_PASSWORD:-""}
export LIKE_PROBABILITY=${LIKE_PROBABILITY:-"0.02"}
export REPLY_PROBABILITY=${REPLY_PROBABILITY:-"0.02"}
export COLLECT_PROBABILITY=${COLLECT_PROBABILITY:-"0.02"}
export MAX_TOPICS=${MAX_TOPICS:-"10"}
export USE_WXPUSHER=${USE_WXPUSHER:-"false"}
export APP_TOKEN=${APP_TOKEN:-""}
export TOPIC_ID=${TOPIC_ID:-""}

# 切换到应用目录
cd /app

# 记录执行时间
echo "$(date): Starting bot execution" >> /var/log/bot/bot.log

# 执行Python脚本
python main.py >> /var/log/bot/bot.log 2>&1

# 记录完成时间
echo "$(date): Bot execution completed" >> /var/log/bot/bot.log
echo "----------------------------------------" >> /var/log/bot/bot.log
