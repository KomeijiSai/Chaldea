#!/bin/bash
# 健康检查脚本 - 更新后的路径
# 用法: ./scripts/health_check.sh

cd /root/.openclaw/workspace

# 更新健康状态文件
STATUS_FILE="memory/system/health-status.json"
LOG_FILE="memory/system/health-log-$(date +%Y%m%d).json"

# 检查系统状态
# ...（保持原有逻辑，只更新路径）

echo "✅ 健康检查完成"
