#!/bin/bash
# 服务启动脚本
# 确保 OpenClaw Gateway 和必要服务在运行
# 用法: ./scripts/start_services.sh

cd /root/.openclaw/workspace

echo "🚀 启动服务..."

# 1. 确保 Trojan 代理运行（如果需要）
if ! pgrep -f "trojan" > /dev/null; then
    echo "  启动 Trojan 代理..."
    /opt/trojan/trojan -c /opt/trojan/config.json > /dev/null 2>&1 &
    sleep 2
fi

# 2. 确保 OpenClaw Gateway 运行
if ! curl -s --connect-timeout 5 http://localhost:18789/health > /dev/null 2>&1; then
    echo "  启动 OpenClaw Gateway..."
    openclaw gateway start
    sleep 5
fi

# 3. 检查健康状态
echo "  检查健康状态..."
./scripts/health_check.sh

echo ""
echo "✅ 服务启动完成"
