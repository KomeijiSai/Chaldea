#!/usr/bin/env python3
"""
轻量级 Kanban 看板服务器
无外部依赖，内嵌 CSS，动态 API
"""

import json
import os
from http.server import HTTPServer, BaseHTTPRequestHandler
from datetime import datetime

KANBAN_FILE = "memory/system/kanban.json"
PORT = 8081

class KanbanHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        if self.path == "/":
            self.serve_html()
        elif self.path == "/api/status":
            self.serve_status()
        elif self.path == "/api/kanban":
            self.serve_kanban()
        else:
            self.send_error(404, "Not Found")
    
    def serve_html(self):
        html = """<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>九公主云眠 - 工作看板</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f5f5f5; }
        .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; text-align: center; }
        .container { max-width: 1200px; margin: 20px auto; padding: 0 20px; }
        .board { display: grid; grid-template-columns: repeat(3, 1fr); gap: 20px; }
        .column { background: white; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .column-header { padding: 15px; color: white; font-weight: bold; border-radius: 8px 8px 0 0; }
        .todo .column-header { background: #6c757d; }
        .in_progress .column-header { background: #007bff; }
        .done .column-header { background: #28a745; }
        .cards { padding: 15px; min-height: 200px; }
        .card { background: #f8f9fa; padding: 12px; margin-bottom: 10px; border-radius: 6px; border-left: 4px solid #007bff; font-size: 14px; }
        .todo .card { border-left-color: #6c757d; }
        .done .card { border-left-color: #28a745; }
        .footer { text-align: center; padding: 20px; color: #666; font-size: 12px; }
        .refresh { position: fixed; bottom: 20px; right: 20px; background: #007bff; color: white; border: none; padding: 10px 20px; border-radius: 20px; cursor: pointer; box-shadow: 0 2px 8px rgba(0,0,0,0.2); }
    </style>
</head>
<body>
    <div class="header">
        <h1>🏰 九公主云眠的工作看板</h1>
        <p>实时任务追踪 · 自动更新</p>
    </div>
    <div class="container">
        <div class="board">
            <div class="column todo">
                <div class="column-header">📋 待办</div>
                <div class="cards" id="todo"></div>
            </div>
            <div class="column in_progress">
                <div class="column-header">🚀 进行中</div>
                <div class="cards" id="in_progress"></div>
            </div>
            <div class="column done">
                <div class="column-header">✅ 已完成</div>
                <div class="cards" id="done"></div>
            </div>
        </div>
    </div>
    <div class="footer">最后更新: <span id="update_time">加载中...</span></div>
    <button class="refresh" onclick="loadKanban()">🔄 刷新</button>
    <script>
        async function loadKanban() {
            try {
                const res = await fetch('/api/kanban');
                const data = await res.json();
                
                document.getElementById('todo').innerHTML = data.columns.todo.map(t => `<div class="card">${t}</div>`).join('');
                document.getElementById('in_progress').innerHTML = data.columns.in_progress.map(t => `<div class="card">${t}</div>`).join('');
                document.getElementById('done').innerHTML = data.columns.done.map(t => `<div class="card">${t}</div>`).join('');
                document.getElementById('update_time').textContent = new Date(data.updated_at).toLocaleString('zh-CN');
            } catch(e) {
                console.error('加载失败:', e);
            }
        }
        loadKanban();
        setInterval(loadKanban, 10000);
    </script>
</body>
</html>"""
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.end_headers()
        self.wfile.write(html.encode())
    
    def serve_status(self):
        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps({"status": "ok"}).encode())
    
    def serve_kanban(self):
        try:
            with open(KANBAN_FILE, 'r') as f:
                data = json.load(f)
            self.send_response(200)
            self.send_header("Content-Type", "application/json")
            self.send_header("Access-Control-Allow-Origin", "*")
            self.end_headers()
            self.wfile.write(json.dumps(data).encode())
        except Exception as e:
            self.send_error(500, str(e))
    
    def log_message(self, format, *args):
        print(f"[{datetime.now().isoformat()}] {args[0]}")

if __name__ == "__main__":
    os.makedirs(os.path.dirname(KANBAN_FILE), exist_ok=True)
    server = HTTPServer(("0.0.0.0", PORT), KanbanHandler)
    print(f"🏰 Kanban 看板服务器启动在 http://0.0.0.0:{PORT}")
    print(f"📊 访问地址: http://101.132.81.50:{PORT}")
    server.serve_forever()
