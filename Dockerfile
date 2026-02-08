FROM python:3.10-slim

WORKDIR /app

# 安装依赖
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 复制源代码
COPY . .

# 设置时区
ENV TZ=Asia/Shanghai
ENV PYTHONUNBUFFERED=1
ENV CRON_INTERVAL=7200

# 创建数据目录
RUN mkdir -p /app/output

# 复制并设置启动脚本
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 使用启动脚本，让服务持续运行
CMD ["/usr/local/bin/docker-entrypoint.sh"]
