# 配置优先级说明

## 配置方式优先级

当同时存在多种配置方式时，优先级从高到低为：

1. **环境变量** (最高优先级)
   - Docker Compose 中的 `environment` 设置
   - 系统环境变量
   - `.env` 文件中的变量

2. **配置文件** (中等优先级)
   - 挂载的 `./config/config.ini` 文件
   - 容器内默认的配置文件

3. **代码默认值** (最低优先级)
   - Python 代码中的硬编码默认值

## 使用场景推荐

### 场景1：纯环境变量配置（推荐CI/CD）
```bash
# 使用 env-only profile
docker-compose --profile env-only up -d linux-do-bot-env-only
```

### 场景2：纯配置文件配置（推荐本地开发）
```bash
# 使用 config-only profile
docker-compose --profile config-only up -d linux-do-bot-config-only
```

### 场景3：混合配置（推荐生产环境）
```bash
# 使用默认配置，环境变量优先
docker-compose up -d linux-do-bot
```

## 配置示例

### .env 文件示例
```bash
# 敏感信息通过环境变量设置
LINUXDO_USERNAME=your_username
LINUXDO_PASSWORD=your_password
APP_TOKEN=your_app_token
TOPIC_ID=your_topic_id

# 行为配置可以留空，使用配置文件
LIKE_PROBABILITY=
REPLY_PROBABILITY=
```

### config.ini 文件示例
```ini
[credentials]
# 如果环境变量为空，则使用这里的配置
username = fallback_username
password = fallback_password

[settings]
# 详细的行为配置
like_probability = 0.05
reply_probability = 0.00
collect_probability = 0.03
max_topics = 20
```

## 验证配置

### 检查最终使用的配置
```bash
# 进入容器检查
docker-compose exec linux-do-bot /bin/bash

# 查看环境变量
env | grep LINUXDO

# 查看配置文件
cat /app/config/config.ini

# 查看应用启动日志
tail -f /var/log/bot/bot.log
```

### 测试不同配置
```bash
# 测试环境变量优先级
LINUXDO_USERNAME=test_user docker-compose up linux-do-bot-test

# 测试配置文件优先级
docker-compose --profile config-only up linux-do-bot-config-only
```

## 最佳实践

1. **敏感信息**：使用环境变量或Docker Secrets
2. **行为配置**：使用配置文件，便于调整和版本控制
3. **部署配置**：使用环境变量，便于不同环境切换
4. **开发调试**：使用配置文件，便于快速修改测试
