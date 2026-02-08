#!/bin/bash
# ═══════════════════════════════════════════════════════════════
#              TrendRadar 一键配置推送脚本
#              无需手动配置环境变量
# ═══════════════════════════════════════════════════════════════

echo "═══════════════════════════════════════════════════════════"
echo "           TrendRadar 推送配置助手"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "请选择你使用的推送方式:"
echo ""
echo "  1) PushPlus (推荐国内用户，微信推送)"
echo "  2) Bark (推荐 iOS 用户)"
echo "  3) Telegram (推荐国际用户)"
echo "  4) 企业微信"
echo "  5) 飞书"
echo "  6) 跳过，稍后手动配置"
echo ""
read -p "请输入选项 (1-6): " choice

case $choice in
    1)
        echo ""
        echo "📱 PushPlus 配置指南"
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        echo "1. 访问 https://www.pushplus.plus"
        echo "2. 微信扫码登录"
        echo "3. 左侧菜单点击 '发送消息'"
        echo "4. 复制你的 Token (一串字符)"
        echo ""
        read -p "请输入你的 PushPlus Token: " token

        if [ -n "$token" ]; then
            # 生成 Zeabur 环境变量配置
            echo ""
            echo "✅ 配置完成！"
            echo ""
            echo "在 Zeabur 控制台添加以下环境变量:"
            echo ""
            echo "┌──────────────────────────────────────────────────┐"
            echo "│  PUSHPLUS_TOKEN=${token}"
            echo "└──────────────────────────────────────────────────┘"
            echo ""
            echo "TZ=Asia/Shanghai"
            echo ""
            # 复制到剪贴板
            echo "$token" | pbcopy 2>/dev/null && echo "✅ Token 已复制到剪贴板"
        fi
        ;;
    2)
        echo ""
        echo "📱 Bark 配置指南"
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        echo "1. 在 App Store 搜索并下载 Bark"
        echo "2. 打开应用，会自动获取推送 key"
        echo "3. 复制显示的推送 URL"
        echo ""
        read -p "请输入你的 Bark URL (如 https://api.day.app/xxxxx): " url

        if [ -n "$url" ]; then
            echo ""
            echo "✅ 配置完成！"
            echo ""
            echo "在 Zeabur 控制台添加以下环境变量:"
            echo ""
            echo "┌──────────────────────────────────────────────────┐"
            echo "│  BARK_URL=${url}"
            echo "└──────────────────────────────────────────────────┘"
            echo ""
            echo "TZ=Asia/Shanghai"
            echo ""
            echo "$url" | pbcopy 2>/dev/null && echo "✅ URL 已复制到剪贴板"
        fi
        ;;
    3)
        echo ""
        echo "📱 Telegram 配置指南"
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        echo "1. 在 Telegram 搜索 @BotFather"
        echo "2. 发送 /newbot 创建机器人"
        echo "3. 按提示设置名称，获得 Token"
        echo "4. 在 Telegram 搜索你的机器人并发送消息"
        echo "5. 访问 https://api.telegram.org/bot<YOUR_BOT_TOKEN>/getUpdates"
        echo "6. 找到 \"chat\":{\"id\":数字}，复制这个数字"
        echo ""
        read -p "请输入 Bot Token: " bot_token
        read -p "请输入 Chat ID: " chat_id

        if [ -n "$bot_token" ] && [ -n "$chat_id" ]; then
            echo ""
            echo "✅ 配置完成！"
            echo ""
            echo "在 Zeabur 控制台添加以下环境变量:"
            echo ""
            echo "┌──────────────────────────────────────────────────┐"
            echo "│  TELEGRAM_BOT_TOKEN=${bot_token}"
            echo "│  TELEGRAM_CHAT_ID=${chat_id}"
            echo "└──────────────────────────────────────────────────┘"
            echo ""
            echo "TZ=Asia/Shanghai"
        fi
        ;;
    4)
        echo ""
        echo "📱 企业微信配置指南"
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        echo "1. 登录企业微信管理后台"
        echo "2. 应用管理 → 创建应用 → 机器人"
        echo "3. 在应用详情页找到 'Webhook' 地址"
        echo ""
        read -p "请输入 Webhook URL: " url

        if [ -n "$url" ]; then
            echo ""
            echo "✅ 配置完成！"
            echo ""
            echo "在 Zeabur 控制台添加以下环境变量:"
            echo ""
            echo "┌──────────────────────────────────────────────────┐"
            echo "│  WEWORK_WEBHOOK_URL=${url}"
            echo "└──────────────────────────────────────────────────┘"
            echo ""
            echo "TZ=Asia/Shanghai"
        fi
        ;;
    5)
        echo ""
        echo "📱 飞书配置指南"
        echo "═══════════════════════════════════════════════════════════"
        echo ""
        echo "1. 打开飞书，创建一个群聊"
        echo "2. 群设置 → 群机器人 → 添加机器人"
        echo "3. 自定义机器人 → 复制 Webhook URL"
        echo ""
        read -p "请输入 Webhook URL: " url

        if [ -n "$url" ]; then
            echo ""
            echo "✅ 配置完成！"
            echo ""
            echo "在 Zeabur 控制台添加以下环境变量:"
            echo ""
            echo "┌──────────────────────────────────────────────────┐"
            echo "│  FEISHU_WEBHOOK_URL=${url}"
            echo "└──────────────────────────────────────────────────┘"
            echo ""
            echo "TZ=Asia/Shanghai"
        fi
        ;;
    6)
        echo ""
        echo "⏭️  已跳过推送配置"
        echo "稍后可在 Zeabur 控制台手动配置环境变量"
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "           下一步: 配置定时任务"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "在 Zeabur 服务设置中添加 Cron 任务，选择一个:"
echo ""
echo "  1) 每2小时执行 (推荐):  0 */2 * * *"
echo "  2) 每天早上9点:         0 9 * * *"
echo "  3) 每天9点和18点:       0 9,18 * * *"
echo "  4) 每1小时:             0 * * * *"
echo ""
echo "命令填写: python -m trendradar"
echo ""
