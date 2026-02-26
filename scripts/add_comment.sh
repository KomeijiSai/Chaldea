#!/bin/bash
# 用法：./add_comment.sh <task_id> <comment>
# 为任务添加评论

TASK_ID=$1
COMMENT="$2"

# 从环境变量读取 Token
source /root/.openclaw/workspace/.env 2>/dev/null
TOKEN="${TODOIST_TOKEN:-}"

if [ -z "$TOKEN" ]; then
    echo "❌ 错误: TODOIST_TOKEN 未设置"
    exit 1
fi

if [ -z "$TASK_ID" ] || [ -z "$COMMENT" ]; then
    echo "用法: ./add_comment.sh <task_id> <comment>"
    exit 1
fi

curl -s -X POST "https://api.todoist.com/api/v1/comments" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"task_id\": \"$TASK_ID\", \"content\": \"$COMMENT\"}"
