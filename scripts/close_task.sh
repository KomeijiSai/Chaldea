#!/bin/bash
# 用法：./close_task.sh <task_id>
# 完成（关闭）任务

TASK_ID=$1

curl -s -X POST "https://api.todoist.com/api/v1/tasks/$TASK_ID/close" \
  -H "Authorization: Bearer 88cce657cb43ae889b41a5e4e4003e3fe0e87c93"
