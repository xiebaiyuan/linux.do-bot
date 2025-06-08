# 使用官方的 Python 3.9 镜像作为基础镜像
FROM python:3.9-slim

# 设置工作目录为 /app
WORKDIR /app

# 设置时区为中国时区
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# 安装系统依赖，包括cron
RUN apt-get update && apt-get install -y --fix-missing \
    cron \
    libgtk-3-0 \
    libasound2 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxext6 \
    libxfixes3 \
    libxrandr2 \
    libxrender1 \
    libxtst6 \
    libfreetype6 \
    libfontconfig1 \
    libpangocairo-1.0-0 \
    libpango-1.0-0 \
    libatk1.0-0 \
    libcairo2 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libdbus-1-3 \
    libxcb1 \
    libxi6 \
    wget \
    && rm -rf /var/lib/apt/lists/*

# 复制 requirements.txt 并安装 Python 依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 安装 Playwright 浏览器（关键修改）
RUN playwright install firefox
RUN playwright install-deps firefox

# 复制应用程序文件
COPY . .

# 创建默认配置目录（如果外挂配置不存在时使用）
RUN mkdir -p /app/config-default
COPY config/ /app/config-default/

# 复制定时任务脚本和cron配置
COPY scripts/run-bot.sh /app/run-bot.sh
COPY scripts/crontab /etc/cron.d/bot-cron

# 设置权限
RUN chmod +x main.py
RUN chmod +x /app/run-bot.sh
RUN chmod 0644 /etc/cron.d/bot-cron

# 创建日志目录和外挂配置目录
RUN mkdir -p /var/log/bot /app/config

# 应用cron配置
RUN crontab /etc/cron.d/bot-cron

# 创建启动脚本
COPY scripts/start.sh /app/start.sh
RUN chmod +x /app/start.sh

# 指定容器启动时执行的命令
CMD ["/app/start.sh"]
