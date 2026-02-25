#!/bin/bash
# 用法：./sync_task.sh <task_content> <status> [task_id] [description] [labels_json_array]
# 状态: "In Progress" | "Waiting" | "Done" | "Todo"
# 项目: OpenClaw WorkSpace

CONTENT=$1
STATUS=$2
TASK_ID=$3
DESCRIPTION=$4
LABELS=$5

PROJECT_ID="6CrgFVFHFmcxgrF5"

case $STATUS in
  "In Progress")
    SECTION_ID="6g4xvm8fH4q4wcv5"
    ;;
  "Waiting")
    SECTION_ID="6g4xvmpmQg8X2MgX"
    ;;
  "Done")
    SECTION_ID="6g4xvp6Rc5x698p5"
    ;;
  *)
    SECTION_ID=""
    ;;
esac

PAYLOAD="{\"content\": \"$CONTENT\""

[ -n "$SECTION_ID" ] && PAYLOAD="$PAYLOAD, \"section_id\": \"$SECTION_ID\""
[ -n "$PROJECT_ID" ] && [ -z "$TASK_ID" ] && PAYLOAD="$PAYLOAD, \"project_id\": \"$PROJECT_ID\""

if [ -n "$DESCRIPTION" ]; then
  # 转义描述中的换行符和引号
  ESC_DESC=$(echo "$DESCRIPTION" | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')
  PAYLOAD="$PAYLOAD, \"description\": \"$ESC_DESC\""
fi

[ -n "$LABELS" ] && PAYLOAD="$PAYLOAD, \"labels\": $LABELS"

PAYLOAD="$PAYLOAD}"

if [ -n "$TASK_ID" ]; then
  ./scripts/todoist_api.sh "tasks/$TASK_ID" POST "$PAYLOAD"
else
  ./scripts/todoist_api.sh "tasks" POST "$PAYLOAD"
fi
