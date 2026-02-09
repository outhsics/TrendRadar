#!/bin/bash
# TrendRadar 全服务启动脚本
# 同时启动：Web 服务器（8080）+ 管理后台 API（9000）+ Cron 任务

set -e

echo "🚀 TrendRadar 全服务启动中..."

# 检查配置文件
if [ ! -f "/app/config/config.yaml" ] || [ ! -f "/app/config/frequency_words.txt" ]; then
    echo "❌ 配置文件缺失"
    exit 1
fi

# 保存环境变量
env >> /etc/environment

# 生成 crontab
echo "${CRON_SCHEDULE:-0 */2 * * *} cd /app && /usr/local/bin/python -m trendradar" > /tmp/crontab

echo "📅 Cron 配置:"
cat /tmp/crontab

# 验证 crontab
if ! /usr/local/bin/supercronic -test /tmp/crontab; then
    echo "❌ crontab 格式验证失败"
    exit 1
fi

# 启动 Web 服务器（端口 8080 - 提供报告文件访问）
if [ "${ENABLE_WEBSERVER:-false}" = "true" ]; then
    echo "🌐 启动 Web 服务器 (端口 8080)..."
    /usr/local/bin/python manage.py start_webserver
fi

# 启动管理后台 API（端口 9000）
echo "🔐 启动管理后台 API (端口 9000)..."
/usr/local/bin/python /app/admin_server.py &
ADMIN_PID=$!
echo "   管理 API PID: $ADMIN_PID"

# 等待管理 API 启动
sleep 2

# 立即执行一次（如果配置了）
if [ "${IMMEDIATE_RUN:-false}" = "true" ]; then
    echo "▶️ 立即执行一次爬虫任务..."
    /usr/local/bin/python -m trendradar
fi

# 启动 supercronic（作为 PID 1）
echo "⏰ 启动 Cron 任务调度器..."
echo "🎯 supercronic 将作为 PID 1 运行"

# 使用 exec 让 supercronic 成为 PID 1
# 但这会导致其他进程（管理 API）无法直接管理
# 解决方案：使用脚本在后台运行所有服务

# 方案：不使用 exec，让启动脚本作为 PID 1
/usr/local/bin/supercronic /tmp/crontab &
SUPER_PID=$!

# 监控所有子进程
echo "✅ 所有服务已启动"
echo "   - Cron 任务 (PID: $SUPER_PID)"
echo "   - 管理 API (PID: $ADMIN_PID)"
echo ""
echo "📊 访问地址:"
echo "   - Web 界面: http://localhost:8080"
echo "   - 管理后台: http://localhost:9000/admin"
echo ""

# 等待任意子进程退出
wait -n

# 如果有子进程退出，退出整个容器
echo "❌ 某个服务已停止，容器退出"
exit 1
