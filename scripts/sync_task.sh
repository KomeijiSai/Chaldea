#!/bin/bash
# 用法：./sync_task.sh <content> <status> [task_id] [description] [labels]
# 创建或更新任务

CONTENT="$1"
STATUS="$2"
TASK_ID="$3"
DESCRIPTION="$4"
LABELS="$5"

# 从环境变量读取 Token
source /root/.openclaw/workspace/.env 2>/dev/null
TOKEN="${TODOIST_TOKEN:-}"

if [ -z "$TOKEN" ]; then
    echo "❌ 错误: TODOIST_TOKEN 未设置"
    exit 1
fi

PROJECT_ID="6CrgFVFHFmcxgrF5"

# 根据 status 确定 section_id
case "$STATUS" in
    "in_progress"|"In Progress")
        SECTION_ID="6g4xvm8fH4q4wcv5"
        ;;
    "waiting"|"Waiting")
        SECTION_ID="6g4xvmpmQg8X2MgX"
        ;;
    "done"|"Done")
        SECTION_ID="6g4xvp6Rc5x698p5"
        ;;
    *)
        SECTION_ID=""
        ;;
esac

if [ -n "$TASK_ID" ]; then
    # 更新现有任务
    curl -s -X POST "https://api.todoist.com/api/v1/tasks/$TASK_ID" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"$CONTENT\"${DESCRIPTION:+, \"description\": \"$DESCRIPTION\"}${SECTION_ID:+, \"section_id\": \"$SECTION_ID\"}}"
else
    # 创建新任务
    curl -s -X POST "https://api.todoist.com/api/v1/tasks" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"$CONTENT\", \"project_id\": \"$PROJECT_ID\"${SECTION_ID:+, \"section_id\": \"$SECTION_ID\"}${DESCRIPTION:+, \"description\": \"$DESCRIPTION\"}${LABELS:+, \"labels\": $LABELS}}"
fi
