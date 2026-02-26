#!/bin/bash
# 完成外部任务并更新状态
# 用法: ./scripts/complete_external_task.sh <todoist_id> <result>

TODOIST_ID="$1"
RESULT="$2"

if [ -z "$TODOIST_ID" ]; then
    echo "❌ 用法: ./scripts/complete_external_task.sh <todoist_id> [result]"
    exit 1
fi

cd /root/.openclaw/workspace

# 检查外部任务文件
if [ ! -f "external-tasks.json" ]; then
    echo "ℹ️ 没有外部任务文件"
    exit 0
fi

# 查找对应的外部任务
TASK_INFO=$(jq -c ".tasks[] | select(.todoistId == \"$TODOIST_ID\")" external-tasks.json)

if [ -z "$TASK_INFO" ]; then
    echo "ℹ️ 不是外部任务，跳过"
    exit 0
fi

TASK_ID=$(echo "$TASK_INFO" | jq -r '.id')
CONTENT=$(echo "$TASK_INFO" | jq -r '.content')

echo "📝 更新外部任务状态: $CONTENT"

# 更新状态
COMPLETED_AT=$(date -Iseconds)
RESULT_TEXT="${RESULT:-已完成}"

jq "(.tasks[] | select(.id == \"$TASK_ID\") | .status) = \"completed\" |
    (.tasks[] | select(.id == \"$TASK_ID\") | .completedAt) = \"$COMPLETED_AT\" |
    (.tasks[] | select(.id == \"$TASK_ID\") | .result) = \"$RESULT_TEXT\"" \
    external-tasks.json > external-tasks.json.tmp
mv external-tasks.json.tmp external-tasks.json

echo "✅ 状态已更新"

# 提交推送
git add external-tasks.json
git commit -m "✅ 完成外部任务: $CONTENT"

if git push origin main 2>/dev/null; then
    echo "✅ 已推送到 GitHub"
else
    echo "⚠️ 推送失败（可能是网络问题），下次重试"
fi
