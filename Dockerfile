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

# 创建数据目录
RUN mkdir -p /app/output

# TrendRadar 使用模块方式启动
CMD ["python", "-m", "trendradar"]
