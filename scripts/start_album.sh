#!/bin/bash
# 启动 Clawra 相册服务器
# 端口: 8082

cd /root/.openclaw/workspace/memory/selfies

PORT=8082

# 检查端口是否被占用
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
    echo "⚠️ 端口 $PORT 已被占用"
    echo "正在停止旧服务..."
    lsof -ti:$PORT | xargs kill -9 2>/dev/null
    sleep 1
fi

echo "📸 Clawra 相册服务器"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "端口: $PORT"
echo "地址: http://101.132.81.50:$PORT/"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# 启动 Python 服务器
python3 -m http.server $PORT
