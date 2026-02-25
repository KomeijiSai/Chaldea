#!/bin/bash
# 用法：./todoist_api.sh <endpoint> <method> [data_json]
# Todoist API v1

ENDPOINT=$1
METHOD=$2
DATA=$3
TOKEN="88cce657cb43ae889b41a5e4e4003e3fe0e87c93"

if [ -z "$DATA" ]; then
  curl -s -X "$METHOD" "https://api.todoist.com/api/v1/$ENDPOINT" \
    -H "Authorization: Bearer $TOKEN"
else
  curl -s -X "$METHOD" "https://api.todoist.com/api/v1/$ENDPOINT" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d "$DATA"
fi
