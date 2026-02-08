#!/bin/bash
# TrendRadar 定时任务启动脚本

echo "🚀 TrendRadar 定时任务启动中..."
echo "⏰ 执行间隔: ${CRON_INTERVAL:-7200} 秒 ($((${CRON_INTERVAL:-7200}/60)) 分钟)"
echo "🕐 时区: $TZ"
echo ""

# 首次立即执行
echo "📊 执行首次数据爬取..."
python -m trendradar
echo "✅ 首次执行完成"
echo ""

# 循环执行
INTERVAL=${CRON_INTERVAL:-7200}  # 默认 2 小时
while true; do
    echo "⏳ 等待 ${INTERVAL} 秒后执行下次任务..."
    sleep $INTERVAL

    echo "📊 开始执行定时任务..."
    python -m trendradar
    echo "✅ 任务执行完成"
    echo ""
done
