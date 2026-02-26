#!/bin/bash
# 用法：./todoist_api.sh <endpoint> <method> [data_json]
# Todoist API v1

ENDPOINT=$1
METHOD=$2
DATA=$3

# 从环境变量读取 Token
source /root/.openclaw/workspace/.env 2>/dev/null
TOKEN="${TODOIST_TOKEN:-}"

if [ -z "$TOKEN" ]; then
    echo "❌ 错误: TODOIST_TOKEN 未设置，请检查 .env 文件"
    exit 1
fi

if [ -z "$DATA" ]; then
  curl -s -X "$METHOD" "https://api.todoist.com/api/v1/$ENDPOINT" \
    -H "Authorization: Bearer $TOKEN"
else
  curl -s -X "$METHOD" "https://api.todoist.com/api/v1/$ENDPOINT" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$DATA"
fi
