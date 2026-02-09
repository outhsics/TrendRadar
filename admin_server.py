#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
TrendRadar 管理后台 API 服务器
提供 Web 管理界面和 RESTful API
"""

import os
import json
import time
import hashlib
import subprocess
from datetime import datetime
from pathlib import Path
from http.server import HTTPServer, BaseHTTPRequestHandler
from urllib.parse import urlparse, parse_qs
import base64


# 配置
ADMIN_USERNAME = "admin"
ADMIN_PASSWORD = "123"  # 生产环境应该使用环境变量
SECRET_KEY = os.environ.get("ADMIN_SECRET_KEY", "trendradar-secret-key-2024")
PORT = int(os.environ.get("ADMIN_PORT", "9000"))
DATA_DIR = Path("/app/output")


def generate_token(username):
    """生成认证 token"""
    payload = f"{username}:{int(time.time())}"
    return hashlib.sha256(f"{payload}:{SECRET_KEY}".encode()).hexdigest()


def verify_token(token):
    """验证 token"""
    # 简单实现，生产环境应使用 JWT
    return token and len(token) == 64


class AdminHandler(BaseHTTPRequestHandler):
    """管理后台请求处理器"""

    def _send_json(self, data, status=200):
        """发送 JSON 响应"""
        self.send_response(status)
        self.send_header('Content-Type', 'application/json; charset=utf-8')
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type, Authorization')
        self.end_headers()
        self.wfile.write(json.dumps(data, ensure_ascii=False, indent=2).encode('utf-8'))

    def _send_html(self, content):
        """发送 HTML 响应"""
        self.send_response(200)
        self.send_header('Content-Type', 'text/html; charset=utf-8')
        self.end_headers()
        self.wfile.write(content.encode('utf-8'))

    def _check_auth(self):
        """检查认证"""
        auth_header = self.headers.get('Authorization', '')
        if auth_header.startswith('Bearer '):
            token = auth_header[7:]
            return verify_token(token)
        return False

    def _get_cron_schedule(self):
        """获取 cron 调度配置"""
        crontab_file = Path("/tmp/crontab")
        if crontab_file.exists():
            return crontab_file.read_text().strip()
        return "未设置"

    def _get_uptime(self):
        """获取运行时间"""
        try:
            with open('/proc/1/uptime', 'r') as f:
                uptime_seconds = float(f.read().split()[0])
                hours = int(uptime_seconds // 3600)
                minutes = int((uptime_seconds % 3600) // 60)
                return f"{hours}小时{minutes}分钟"
        except:
            return "未知"

    def _get_task_count(self):
        """获取任务执行次数"""
        try:
            output_dir = Path("/app/output")
            if output_dir.exists():
                html_dir = output_dir / "html"
                if html_dir.exists():
                    return str(len(list(html_dir.rglob("*.html"))))
            return "0"
        except:
            return "未知"

    def do_OPTIONS(self):
        """处理 OPTIONS 预检请求"""
        self._send_json({}, 200)

    def do_GET(self):
        """处理 GET 请求"""
        parsed_path = urlparse(self.path)
        path = parsed_path.path

        # 静态文件服务 - 管理界面
        if path == '/' or path == '/admin' or path == '/admin.html':
            admin_html = Path("/app/admin.html")
            if admin_html.exists():
                self._send_html(admin_html.read_text(encoding='utf-8'))
            else:
                self._send_json({"error": "管理界面文件不存在"}, 404)
            return

        # API: 健康检查
        if path == '/api/health':
            self._send_json({
                "status": "ok",
                "timestamp": datetime.now().isoformat(),
                "service": "TrendRadar Admin"
            })
            return

        # API: 状态查询
        if path == '/api/status':
            if not self._check_auth():
                self._send_json({"error": "未授权"}, 401)
                return

            self._send_json({
                "running": True,
                "uptime": self._get_uptime(),
                "task_count": self._get_task_count(),
                "next_run": self._get_cron_schedule(),
                "timestamp": datetime.now().isoformat()
            })
            return

        # API: 获取日志
        if path == '/api/logs':
            if not self._check_auth():
                self._send_json({"error": "未授权"}, 401)
                return

            logs = []
            log_file = Path("/app/output/logs/latest.log")
            if log_file.exists():
                logs = log_file.read_text(encoding='utf-8').split('\n')[-100:]

            self._send_json({
                "logs": logs,
                "count": len(logs)
            })
            return

        # API: 获取配置
        if path == '/api/config':
            if not self._check_auth():
                self._send_json({"error": "未授权"}, 401)
                return

            config = {
                "cron_schedule": self._get_cron_schedule(),
                "timezone": os.environ.get("TZ", "未设置"),
                "webserver_enabled": os.environ.get("ENABLE_WEBSERVER", "false"),
                "immediate_run": os.environ.get("IMMEDIATE_RUN", "false"),
                "feishu_webhook": os.environ.get("FEISHU_WEBHOOK_URL", "***已配置***" if os.environ.get("FEISHU_WEBHOOK_URL") else "未配置")
            }
            self._send_json(config)
            return

        # API: 文件列表
        if path == '/api/files':
            if not self._check_auth():
                self._send_json({"error": "未授权"}, 401)
                return

            files = []
            output_dir = Path("/app/output")
            if output_dir.exists():
                for html_file in output_dir.rglob("*.html"):
                    stat = html_file.stat()
                    files.append({
                        "name": html_file.name,
                        "path": str(html_file.relative_to(output_dir)),
                        "size": stat.st_size,
                        "modified": datetime.fromtimestamp(stat.st_mtime).isoformat()
                    })

            self._send_json({
                "files": sorted(files, key=lambda x: x['modified'], reverse=True),
                "total": len(files)
            })
            return

        # 404
        self._send_json({"error": "接口不存在", "path": path}, 404)

    def do_POST(self):
        """处理 POST 请求"""
        parsed_path = urlparse(self.path)
        path = parsed_path.path

        # API: 登录
        if path == '/api/login':
            content_length = int(self.headers.get('Content-Length', 0))
            post_data = self.rfile.read(content_length)
            try:
                data = json.loads(post_data.decode('utf-8'))
                username = data.get('username', '')
                password = data.get('password', '')

                if username == ADMIN_USERNAME and password == ADMIN_PASSWORD:
                    token = generate_token(username)
                    self._send_json({
                        "success": True,
                        "token": token,
                        "message": "登录成功"
                    })
                else:
                    self._send_json({
                        "success": False,
                        "message": "账号或密码错误"
                    }, 401)
            except:
                self._send_json({"success": False, "message": "请求格式错误"}, 400)
            return

        # 需要认证的 API
        if not self._check_auth():
            self._send_json({"error": "未授权"}, 401)
            return

        # API: 手动执行
        if path == '/api/run':
            try:
                result = subprocess.run(
                    ['python', '-m', 'trendradar'],
                    cwd='/app',
                    capture_output=True,
                    text=True,
                    timeout=300
                )

                self._send_json({
                    "success": result.returncode == 0,
                    "output": result.stdout[-1000:],  # 最后1000字符
                    "error": result.stderr[-500:] if result.stderr else None
                })
            except subprocess.TimeoutExpired:
                self._send_json({"success": False, "error": "执行超时"}, 500)
            except Exception as e:
                self._send_json({"success": False, "error": str(e)}, 500)
            return

        # API: 重启服务
        if path == '/api/restart':
            self._send_json({
                "success": True,
                "message": "重启命令已发送（容器环境需要重启 Pod）"
            })
            return

        self._send_json({"error": "接口不存在"}, 404)

    def log_message(self, format, *args):
        """自定义日志输出"""
        print(f"[{datetime.now().strftime('%Y-%m-%d %H:%M:%S')}] {format % args}")


def start_server():
    """启动管理服务器"""
    server = HTTPServer(('0.0.0.0', PORT), AdminHandler)
    print(f"🚀 TrendRadar 管理后台启动成功！")
    print(f"📊 访问地址: http://localhost:{PORT}/admin")
    print(f"🔐 默认账号: {ADMIN_USERNAME}")
    print(f"🔑 默认密码: {ADMIN_PASSWORD}")
    print(f"⚠️  生产环境请修改密码！")
    print()

    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n👋 服务器已停止")
        server.shutdown()


if __name__ == "__main__":
    start_server()
