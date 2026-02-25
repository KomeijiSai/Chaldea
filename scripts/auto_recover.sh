#!/bin/bash
# 自动恢复脚本
# 用法: ./scripts/auto_recover.sh [issue]

cd /root/.openclaw/workspace

# 加载环境变量
source .env 2>/dev/null

ISSUE="${1:-}"

# 通知御主
notify_master() {
    local level="$1"
    local message="$2"
    
    # 这里可以接入钉钉通知
    echo "[$level] $message"
    
    # 记录到日志
    echo "$(date '+%Y-%m-%d %H:%M:%S') [$level] $message" >> memory/work-log/recovery.log
}

# 恢复 Gateway
recover_gateway() {
    notify_master "WARNING" "Gateway 不健康，尝试恢复..."
    
    # 尝试重启 Gateway
    openclaw gateway restart 2>&1
    
    sleep 5
    
    # 检查是否恢复
    if curl -s --connect-timeout 5 http://localhost:18789/health > /dev/null 2>&1; then
        notify_master "INFO" "✅ Gateway 恢复成功"
        return 0
    else
        notify_master "ERROR" "❌ Gateway 恢复失败，需要人工介入"
        return 1
    fi
}

# 清理磁盘
recover_disk() {
    notify_master "WARNING" "磁盘空间不足，尝试清理..."
    
    # 清理临时文件
    rm -f /tmp/*.tmp 2>/dev/null
    rm -f /tmp/*.log 2>/dev/null
    
    # 清理旧备份（保留最近7天）
    find /root/.openclaw/workspace -name "*.tar.gz" -mtime +7 -delete 2>/dev/null
    
    # 检查效果
    USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$USAGE" -lt 90 ]; then
        notify_master "INFO" "✅ 磁盘清理成功，当前使用率 ${USAGE}%"
        return 0
    else
        notify_master "ERROR" "❌ 磁盘清理后仍不足，当前使用率 ${USAGE}%"
        return 1
    fi
}

# 主恢复逻辑
case "$ISSUE" in
    "gateway")
        recover_gateway
        ;;
    "disk")
        recover_disk
        ;;
    *)
        # 自动检测
        ./scripts/health_check.sh > /dev/null 2>&1
        EXIT_CODE=$?
        
        if [ $EXIT_CODE -eq 2 ]; then
            # 严重问题
            if curl -s --connect-timeout 5 http://localhost:18789/health > /dev/null 2>&1; then
                :
            else
                recover_gateway
            fi
            
            USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
            if [ "$USAGE" -ge 90 ]; then
                recover_disk
            fi
        fi
        ;;
esac
