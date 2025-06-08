#!/bin/bash

# 配置文件优先级处理
if [ ! -f "/app/config/config.ini" ] && [ -f "/app/config-default/config.ini" ]; then
    echo "外挂配置不存在，复制默认配置..."
    cp -r /app/config-default/* /app/config/
fi

# 启动cron服务
service cron start

# 创建日志文件
touch /var/log/bot/bot.log

# 输出启动信息
echo "==================================="
echo "Linux.do Bot 容器启动 - $(date)"
echo "==================================="
echo "配置信息:"
echo "- 工作目录: /app"
echo "- 配置目录: /app/config"
echo "- 日志目录: /var/log/bot"
echo "- 定时任务:"
crontab -l
echo "==================================="

# 检查必要的环境变量
if [ -z "$LINUXDO_USERNAME" ] && [ ! -f "/app/config/config.ini" ]; then
    echo "警告: 未设置 LINUXDO_USERNAME 环境变量且无配置文件"
fi

# 如果设置了IMMEDIATE_RUN环境变量，立即运行一次
if [ "$IMMEDIATE_RUN" = "true" ]; then
    echo "立即运行模式已启用，开始执行..."
    /app/run-bot.sh
    echo "立即运行完成，继续定时任务模式..."
fi

echo "Bot 容器已启动，等待定时任务执行..."
echo "实时日志如下:"
echo "==================================="

# 保持容器运行并显示日志
tail -f /var/log/bot/bot.log
