#!/bin/bash
# 系统恢复脚本 - 服务重启后自动恢复工作
# 用法: ./scripts/system_resume.sh

cd /root/.openclaw/workspace

echo "🔄 系统恢复中..."
echo "时间: $(date)"
echo ""

# 加载环境变量
source .env 2>/dev/null

# 1. 检查并启动必要服务
echo "📋 检查服务状态..."

# Trojan 代理
if ! pgrep -f "trojan" > /dev/null; then
    echo "  启动 Trojan 代理..."
    /opt/trojan/trojan -c /opt/trojan/config.json > /dev/null 2>&1 &
    sleep 2
fi

# OpenClaw Gateway
if ! curl -s --connect-timeout 5 http://localhost:18789/health > /dev/null 2>&1; then
    echo "  启动 OpenClaw Gateway..."
    openclaw gateway start
    sleep 5
fi

# 2. 恢复工作状态
echo ""
echo "📋 恢复工作状态..."

if [ -f "memory/current-state.json" ]; then
    CURRENT_TASK=$(jq -r '.currentTask // empty' memory/current-state.json)
    STATUS=$(jq -r '.status // "idle"' memory/current-state.json)
    
    echo "  上次状态: $STATUS"
    echo "  当前任务: ${CURRENT_TASK:-无}"
    
    # 更新状态为恢复中
    jq '.status = "resuming" | .lastUpdate = "'$(date -Iseconds)'"' \
        memory/current-state.json > memory/current-state.json.tmp && \
        mv memory/current-state.json.tmp memory/current-state.json
fi

# 3. 同步数据到 GitHub
echo ""
echo "📤 同步数据到 GitHub..."
if [ -n "$GITHUB_TOKEN" ]; then
    export GITHUB_TOKEN
    ./scripts/git_sync.sh "🔄 系统恢复: $(date '+%Y-%m-%d %H:%M')" 2>/dev/null || echo "  同步失败（网络问题）"
fi

# 4. 检查任务队列
echo ""
echo "📋 检查任务队列..."
./scripts/generate_auto_task.sh 2>/dev/null || echo "  任务检查失败"

# 5. 更新状态
echo ""
echo "✅ 系统恢复完成"

# 更新状态为活跃
if [ -f "memory/current-state.json" ]; then
    jq '.status = "active" | .lastUpdate = "'$(date -Iseconds)'" | .context.systemResumed = true' \
        memory/current-state.json > memory/current-state.json.tmp && \
        mv memory/current-state.json.tmp memory/current-state.json
fi

echo ""
echo "📊 当前状态:"
cat memory/current-state.json | jq -r '"  状态: \(.status)\n  更新: \(.lastUpdate)"'
