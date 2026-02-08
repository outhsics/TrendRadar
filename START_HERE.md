# TrendRadar 一键部署指南

## 🚀 全自动部署（推荐）

只需运行一条命令，自动完成以下操作：
- ✅ 检查 GitHub 登录
- ✅ Fork TrendRadar 仓库
- ✅ 应用自定义配置
- ✅ 提交到你的 GitHub
- ✅ 打开 Zeabur 部署页面

### 执行命令

```bash
bash /tmp/TrendRadar/auto_deploy.sh
```

脚本会自动处理一切，你只需要：
1. 按照 Zeabur 页面提示操作
2. 配置推送服务（见下方）

---

## 📱 配置推送服务

运行推送配置助手：

```bash
bash /tmp/TrendRadar/deploy_automation.sh
```

助手会引导你完成推送服务的配置，支持：
- PushPlus（推荐国内用户）
- Bark（推荐 iOS 用户）
- Telegram
- 企业微信
- 飞书

---

## ⚙️ 你的配置

已为你定制的关键词监控：

### 1️⃣ 量化投资
- A股、上证、深证
- 茅台、腾讯、比亚迪、宁德时代

### 2️⃣ AI发展
- AI、ChatGPT、Claude、大模型
- GPT、Llama、Qwen、DeepSeek

### 3️⃣ 最佳实践/工具
- LangChain、LlamaIndex、Semantic Kernel
- Prompt、提示词、提示工程

### 4️⃣ 模型优惠
- 降价、免费、优惠、折扣、促销

### 过滤设置
已自动过滤：娱乐八卦、明星绯闻、游戏、动漫等

---

## 🔧 Zeabur 配置清单

部署后在 Zeabur 控制台添加：

### 环境变量
```bash
TZ=Asia/Shanghai
PUSHPLUS_TOKEN=你的token  # 或其他推送方式
```

### 定时任务（选一个）
```bash
# 每2小时（推荐）
0 */2 * * *

# 每天9点和18点
0 9,18 * * *

# 每1小时
0 * * * *
```

### 任务命令
```bash
python -m trendradar
```

---

## ✅ 部署完成后

1. 查看日志确认运行正常
2. 等待下次定时执行，检查是否收到推送
3. 如需调整，修改 `config/frequency_words.txt` 后重新提交

---

## 📚 更多帮助

- [Zeabur 文档](https://zeabur.com/docs/zh-CN)
- [TrendRadar 项目](https://github.com/sansan0/TrendRadar)
