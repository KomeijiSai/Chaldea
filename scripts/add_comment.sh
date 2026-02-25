#!/bin/bash
# 用法：./add_comment.sh <task_id> <comment_text>

TASK_ID=$1
TEXT=$2

# 转义文本中的换行符和引号
ESC_TEXT=$(echo "$TEXT" | sed ':a;N;$!ba;s/\n/\\n/g' | sed 's/"/\\"/g')

PAYLOAD="{\"task_id\": \"$TASK_ID\", \"content\": \"$ESC_TEXT\"}"

./scripts/todoist_api.sh "comments" POST "$PAYLOAD"
