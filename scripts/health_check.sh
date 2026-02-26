#!/bin/bash
# 健康检查脚本
# 用法: ./scripts/health_check.sh

cd /root/.openclaw/workspace

HEALTH_FILE="memory/health-status.json"
ALERT_FILE="memory/alerts/pending.json"

# 加载环境变量
source .env 2>/dev/null

# 检查结果
CHECKS=()
OVERALL="healthy"

# 检查 OpenClaw Gateway
check_gateway() {
    if curl -s --connect-timeout 5 http://localhost:18789/health > /dev/null 2>&1; then
        echo "healthy"
    else
        echo "unhealthy"
    fi
}

# 检查磁盘空间
check_disk() {
    USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$USAGE" -lt 90 ]; then
        echo "healthy"
    elif [ "$USAGE" -lt 95 ]; then
        echo "warning"
    else
        echo "critical"
    fi
}

# 检查内存
check_memory() {
    FREE_MB=$(free -m | grep "Mem:" | awk '{print $7}')
    if [ "$FREE_MB" -gt 500 ]; then
        echo "healthy"
    elif [ "$FREE_MB" -gt 100 ]; then
        echo "warning"
    else
        echo "critical"
    fi
}

# 检查 Todoist API
check_todoist() {
    if [ -n "$TODOIST_TOKEN" ]; then
        if curl -s --connect-timeout 5 -H "Authorization: Bearer $TODOIST_TOKEN" \
           "https://api.todoist.com/api/v1/user" > /dev/null 2>&1; then
            echo "healthy"
        else
            echo "unhealthy"
        fi
    else
        echo "not_configured"
    fi
}

# 执行检查
GATEWAY=$(check_gateway)
DISK=$(check_disk)
MEMORY=$(check_memory)
TODOIST=$(check_todoist)

# 判断整体状态
if [ "$GATEWAY" = "unhealthy" ] || [ "$DISK" = "critical" ] || [ "$MEMORY" = "critical" ]; then
    OVERALL="critical"
elif [ "$GATEWAY" = "unhealthy" ] || [ "$DISK" = "warning" ] || [ "$MEMORY" = "warning" ]; then
    OVERALL="warning"
fi

# 生成报告
cat > "$HEALTH_FILE" << EOF
{
  "timestamp": "$(date -Iseconds)",
  "overall": "$OVERALL",
  "checks": {
    "gateway": "$GATEWAY",
    "disk": "$DISK",
    "memory": "$MEMORY",
    "todoist": "$TODOIST"
  },
  "hostname": "$(hostname)"
}
EOF

echo "$HEALTH_FILE"
cat "$HEALTH_FILE"

# 如果状态不健康，返回非零退出码
if [ "$OVERALL" = "critical" ]; then
    exit 2
elif [ "$OVERALL" = "warning" ]; then
    exit 1
else
    exit 0
fi
