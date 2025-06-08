# 简介
这个脚本用于自动化操作以保持 discuss论坛 网站的活跃状态，包括浏览帖子并进行点赞，以及通过WxPusher推送消息到微信(可选)、自动回复帖子(可选)、自动加入书签(可选)。

下面是详细介绍如何在 Windows、Linux 服务器、GitHub Workflow 中配置并运行此 `discuss论坛保活脚本` 的 Markdown 文档。

---

# 注意事项
虽然此功能支持自动回复，但不建议启用(变量视环境而言 REPLY_PROBABILITY 或 reply_probability 回复概率配置为 0 即可关闭)。

因为论坛禁止AI生成的内容，自动回复功能可能也被包含在内。

从技术上讲，确实有办法规避检测，想要搞的可以自己研究，但是后果也需要自己承担。

---


# discuss论坛 保活脚本配置与运行指南

## 概述

本指南将详细介绍如何在不同环境下（Windows、Linux 服务器、GitHub Workflow）配置并运行 `discuss论坛保活脚本`。该脚本通过 Playwright 自动化操作对 `discuss论坛` 网站的帖子进行浏览、点赞、加入书签和自动回复，并支持通过 WxPusher 发送通知。

## 项目目录结构

```plaintext
- .github/
  - workflows/
    - run-linuxdo.yml
    - sync.yml
- assets/
  - wxPusher.png
  - wxPusherMsg.png
- config/
  - config.ini
  - reply.txt
  - reply_generator.py
- Docker/
  - bot.tar
- .dockerignore
- .gitignore
- Dockerfile
- LICENSE
- main.py
- README.md
```

## 环境依赖

- Python 3.7+
- [Playwright](https://playwright.dev/python/docs/intro) 库
- [requests](https://docs.python-requests.org/en/latest/) 库
- 在服务器或 CI 环境中运行时，需配置 WxPusher 以接收脚本执行结果通知(可选)
- WxPusher：https://wxpusher.zjiecode.com/ 查看官方手册(可选)

## 变量检查与说明

- USERNAME: 登录 discuss论坛 的用户名。
- PASSWORD: 登录 discuss论坛 的密码。
- LIKE_PROBABILITY: 点赞概率，值在 0 和 1 之间，例如 0.02 表示 2% 的概率点赞。
- REPLY_PROBABILITY: 回复概率，值在 0 和 1 之间，例如 0.02 表示 2% 的概率回复。
- COLLECT_PROBABILITY: 加入书签概率，值在 0 和 1 之间，例如 0.02 表示 2% 的概率加入书签。
- HOME_URL: discuss论坛 的主页 URL。
- CONNECT_URL: 连接信息页面的 URL。
- USE_WXPUSHER: 是否使用 wxpusher 发送消息通知，true 或 false。
- APP_TOKEN: wxpusher 应用的 appToken，当 USE_WXPUSHER 为 true 时需要配置。
- TOPIC_ID: wxpusher 的 topicId，当 USE_WXPUSHER 为 true 时需要配置。
- MAX_TOPICS: 最大处理的主题数量，如果超过此数量则只处理前 MAX_TOPICS 个主题。

## 一、在 Windows 上配置与运行

### 1.1 安装依赖

首先，确保你已经安装了 Python 3.7 及以上版本。然后在命令行中执行以下命令以安装所需依赖：

```bash
pip install playwright requests tabulate configparser
playwright install
```

### 1.2 配置文件

在项目根目录下config目录下创建 `config.ini` 文件，内容如下：

```ini
[credentials]
username = your_username
password = your_password

[settings]
like_probability = 0.02
reply_probability=0.02
collect_probability=0.02
max_topics = 10

[urls]
home_url = 
connect_url = 

[wxpusher]
use_wxpusher = false
app_token =
topic_id =
```

### 1.3 运行脚本

在命令行中进入脚本所在目录，执行以下命令运行脚本：

```bash
python main.py
```

## 二、在 Linux 服务器上配置与运行

### 2.1 安装依赖

同样，确保服务器上安装了 Python 3.7 及以上版本。安装所需依赖：

```bash
pip install playwright requests tabulate configparser
playwright install
```

### 2.2 配置文件

在服务器main.py的同级目录 `./config` 目录下创建 `config.ini` 文件：

```ini
[credentials]
username = your_username
password = your_password

[settings]
like_probability = 0.02
reply_probability=0.02
collect_probability=0.02
max_topics = 10

[urls]
home_url = 
connect_url = 

[wxpusher]
use_wxpusher = true
app_token = your_app_token
topic_id = your_topic_id
```

### 2.3 设置环境变量

在 `.bashrc` 或 `.bash_profile` 中添加以下环境变量：

```bash
export LINUXDO_USERNAME="your_username"
export LINUXDO_PASSWORD="your_password"
export USE_WXPUSHER=true
export APP_TOKEN="your_app_token"
export TOPIC_ID="your_topic_id"
```

使配置生效：

```bash
source ~/.bashrc
```

### 2.4 运行脚本

进入脚本所在目录，执行以下命令：

```bash
python3 main.py
```

## 三、在 GitHub Workflow 中配置与运行

### 3.1 配置 GitHub Secrets

在 GitHub 仓库中，配置以下 Secrets：

- `LINUXDO_USERNAME`
- `LINUXDO_PASSWORD`
- `LIKE_PROBABILITY`
- `REPLY_PROBABILITY`
- `COLLECT_PROBABILITY`
- `MAX_TOPICS`
- `USE_WXPUSHER`（值为 `true` 或 `false`）
- `APP_TOKEN`（如果 `USE_WXPUSHER` 为 `true`）
- `TOPIC_ID`（如果 `USE_WXPUSHER` 为 `true`）

### 3.2 配置 GitHub Workflow 文件

在项目的 `.github/workflows/` 目录下创建一个新的 Workflow 文件 `run-linuxdo.yml`：

```yaml
name: Run bot Script

on:
  push:
    branches:
      - main
  schedule:
    - cron: '0 0 * * *'  # 每天 UTC 时间午夜运行一次

jobs:
  run-linuxdo:
    runs-on: ubuntu-latest

    steps:
    - name: Checkout code
      uses: actions/checkout@v2

    - name: Set up Python
      uses: actions/setup-python@v2
      with:
        python-version: 3.7

    - name: Install dependencies
      run: |
        pip install playwright requests tabulate configparser
        playwright install

    - name: Run script
      env:
        LINUXDO_USERNAME: ${{ secrets.LINUXDO_USERNAME }}
        LINUXDO_PASSWORD: ${{ secrets.LINUXDO_PASSWORD }}
        LIKE_PROBABILITY: ${{ secrets.LIKE_PROBABILITY }}
        REPLY_PROBABILITY: ${{ secrets.REPLY_PROBABILITY }}
        COLLECT_PROBABILITY: ${{ secrets.COLLECT_PROBABILITY }}
        MAX_TOPICS: ${{ secrets.MAX_TOPICS }}
        USE_WXPUSHER: ${{ secrets.USE_WXPUSHER }}
        APP_TOKEN: ${{ secrets.APP_TOKEN }}
        TOPIC_ID: ${{ secrets.TOPIC_ID }}
      run: |
        python main.py
```

### 3.3 运行 Workflow

提交或合并代码到 `main` 分支，GitHub Actions 会自动触发 Workflow 并运行脚本。你可以在 GitHub 的 Actions 页面查看运行日志。

## 四、如果你想打包成exe

要将 `main.py`、`config.ini` 和 `reply.txt` 一起打包成一个可执行的 `.exe` 文件，你可以按照以下步骤进行：

### 4.1. 安装 PyInstaller

确保你的环境中已经安装了 `PyInstaller`。如果没有安装，可以使用以下命令进行安装：

```bash
pip install pyinstaller
```

### 4.2. 配置打包命令

你可以使用以下命令将 `main.py`、`config.ini` 和 `reply.txt` 打包成一个 `.exe` 文件：

windows:
```bash
pyinstaller --onefile --add-data "config/config.ini;config" --add-data "config/reply.txt;config" --add-data "config/reply_generator.py;config" main.py
```
linux:
windows:
```bash
pyinstaller --onefile --add-data "config/config.ini:config" --add-data "config/reply.txt:config" --add-data "config/reply_generator.py:config" main.py
```

### 4.3. 说明

- `--onefile`：将所有依赖打包成一个独立的 `.exe` 文件。
- `--add-data "config.ini;config"`：将 `config.ini` 文件包含在打包的 `.exe` 文件中，放置在config目录下。
- `--add-data "reply.txt;config"`：将 `reply.txt` 文件也包含在打包的 `.exe` 文件中，放置在config当前目录下。
- `--add-data "reply_generator.py;config"`：将 `reply_generator.py` 文件也包含在打包的 `.exe` 文件中，放置在config当前目录下。

### 4.4. 打包完成

执行命令后，`PyInstaller` 会在项目目录下生成一个 `dist` 目录，里面包含打包好的 `main.exe` 文件。

### 4.5. 修改 `main.py` 以适应打包后的路径

在打包后的 `.exe` 文件中，访问资源文件（如 `config.ini` 和 `reply.txt`）时，文件的路径会有所不同。你可以使用以下代码来动态获取资源文件的路径：

```python
import sys
import os

def resource_path(relative_path):
    """获取资源文件的绝对路径"""
    try:
        # PyInstaller创建临时文件夹，并将路径存储在 _MEIPASS 中
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

# 示例：加载 config.ini 和 reply.txt
config_path = resource_path("config.ini")
reply_path = resource_path("reply.txt")

# 继续编写代码以加载和使用这些文件
```

### 4.6. 运行 .exe 文件

生成的 `.exe` 文件可以直接运行，配置文件 `config.ini` 和 `reply.txt` 会正确加载，无需手动复制到运行目录。

### 总结

通过这种方法，你可以将 Python 脚本和必要的配置文件一起打包，生成一个独立的 `.exe` 文件，方便分发和使用。


## 五、使用 Docker 运行项目

### 5.1 构建 Docker 镜像

首先确保你已经安装了Docker，然后在项目根目录下执行以下命令构建镜像：

```bash
# 构建本地镜像
docker build -t linux-do-bot:latest .
```

### 5.2 使用 Docker Compose（推荐）

#### 快速开始

1. **准备配置文件**：
```bash
# 复制环境变量模板
cp .env.example .env

# 编辑配置文件
vim .env
```

2. **准备外挂配置目录**：
```bash
# 创建外挂配置和日志目录
mkdir -p config logs

# 如果需要自定义config.ini，复制并编辑
cp config/config.ini ./config/config.ini
vim ./config/config.ini
```

3. **启动服务**：
```bash
# 构建并启动定时任务容器
docker-compose up -d

# 查看启动日志
docker-compose logs -f

# 查看容器状态
docker-compose ps
```

#### 配置方式

##### 方式一：使用环境变量（推荐新手）
```bash
# 编辑 .env 文件
LINUXDO_USERNAME=your_username
LINUXDO_PASSWORD=your_password
LIKE_PROBABILITY=0.02
USE_WXPUSHER=false
```

##### 方式二：使用外挂配置文件（推荐高级用户）
```bash
# 编辑 ./config/config.ini
[credentials]
username = your_username
password = your_password

[settings]
like_probability = 0.02
reply_probability = 0.00
collect_probability = 0.02
```

#### 常用命令

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 查看日志
docker-compose logs -f linux-do-bot

# 进入容器调试
docker-compose exec linux-do-bot /bin/bash

# 立即运行一次（测试用）
docker-compose --profile test run --rm linux-do-bot-test

# 更新镜像并重启
docker-compose pull && docker-compose up -d

# 重新构建并启动
docker-compose up -d --build
```

#### 高级配置

##### 自定义定时任务
如果需要修改定时任务频率：

1. 修改 `scripts/crontab` 文件
2. 重新构建镜像：
```bash
docker-compose up -d --build
```

##### 资源限制
在 `docker-compose.yml` 中已配置默认资源限制：
- 内存限制：1GB
- CPU限制：0.5核
- 预留内存：256MB

##### 多实例运行
```yaml
# 在 docker-compose.yml 中添加
linux-do-bot-2:
  extends: linux-do-bot
  container_name: linux-do-bot-2
  environment:
    - LINUXDO_USERNAME=${LINUXDO_USERNAME_2}
    - LINUXDO_PASSWORD=${LINUXDO_PASSWORD_2}
```

#### 故障排除

##### 查看详细日志
```bash
# 查看容器日志
docker-compose logs linux-do-bot

# 查看应用日志
tail -f logs/bot.log

# 实时监控
docker-compose logs -f --tail=50
```

##### 配置检查
```bash
# 进入容器检查配置
docker-compose exec linux-do-bot cat /app/config/config.ini

# 检查环境变量
docker-compose exec linux-do-bot env | grep LINUXDO

# 检查定时任务
docker-compose exec linux-do-bot crontab -l
```

##### 重置配置
```bash
# 停止服务
docker-compose down

# 清理配置和日志
rm -rf config/* logs/*

# 重新启动（会使用默认配置）
docker-compose up -d
```

#### 生产环境建议

1. **使用外部卷**：
```yaml
volumes:
  - bot-config:/app/config
  - bot-logs:/var/log/bot
```

2. **配置监控**：
```bash
# 添加监控脚本
echo '#!/bin/bash
if ! docker-compose ps | grep -q "Up"; then
    docker-compose up -d
    echo "Bot service restarted at $(date)"
fi' > monitor.sh

chmod +x monitor.sh
echo "*/5 * * * * /path/to/monitor.sh" | crontab -
```

3. **日志轮转**：
```yaml
# 在 docker-compose.yml 中添加
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

## 六、常见问题

### 6.1 如何调试登录失败的问题？

- 确保用户名和密码正确配置在环境变量或配置文件中。
- 尝试手动访问登录页面，检查登录元素的类名或 ID 是否有变化。

### 6.2 如何调整点赞概率？

在 `config.ini` 文件或环境变量中修改 `LIKE_PROBABILITY` 的值，例如将 `0.02` 修改为 `0.05`，意味着 5% 的概率会点赞。

### 6.3 WxPusher 配置失败怎么办？

- 确保 `APP_TOKEN` 和 `TOPIC_ID` 配置正确。
- 在 WxPusher 的管理后台确认 `appToken` 是否启用，以及 `topicId` 是否可用。
- WxPusher官册：https://wxpusher.zjiecode.com/ 查看官方手册

### 6.4 WxPusher 运行发送的消息是？
- ![](https://github.com/LeeYouRan/bot/blob/main/assets/wxPusher.png)

- ![](https://github.com/LeeYouRan/bot/blob/main/assets/wxPusherMsg.png)

---

按照以上指南配置并运行脚本后，您将能够在不同环境下自动浏览和点赞 `discuss论坛` 的帖子，并根据配置接收通知。
