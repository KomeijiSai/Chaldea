#!/bin/bash
# 用法：./close_task.sh <task_id> [result]
# 完成（关闭）任务

TASK_ID=$1
RESULT="${2:-已完成}"

# 从环境变量读取 Token
source /root/.openclaw/workspace/.env 2>/dev/null
TOKEN="${TODOIST_TOKEN:-}"

if [ -z "$TOKEN" ]; then
    echo "❌ 错误: TODOIST_TOKEN 未设置"
    exit 1
fi

# 关闭任务
RESPONSE=$(curl -s -X POST "https://api.todoist.com/api/v1/tasks/$TASK_ID/close" \
    -H "Authorization: Bearer $TOKEN")

if [ $? -eq 0 ]; then
    echo "✅ 任务已关闭: $TASK_ID"

    # 检查是否是外部任务，如果是则更新状态
    if [ -f "/root/.openclaw/workspace/scripts/complete_external_task.sh" ]; then
        /root/.openclaw/workspace/scripts/complete_external_task.sh "$TASK_ID" "$RESULT" 2>/dev/null || true
    fi
else
    echo "❌ 关闭任务失败"
    exit 1
fi
