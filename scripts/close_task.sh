#!/bin/bash
# 用法：./close_task.sh <task_id>
# 完成（关闭）任务

TASK_ID=$1

# 从环境变量读取 Token
source /root/.openclaw/workspace/.env 2>/dev/null
TOKEN="${TODOIST_TOKEN:-}"

if [ -z "$TOKEN" ]; then
    echo "❌ 错误: TODOIST_TOKEN 未设置"
    exit 1
fi

curl -s -X POST "https://api.todoist.com/api/v1/tasks/$TASK_ID/close" \
    -H "Authorization: Bearer $TOKEN"
