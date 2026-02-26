#!/bin/bash
# 同步外部任务到 Todoist
# 用法: ./scripts/sync_external_tasks.sh

cd /root/.openclaw/workspace

echo "🔄 开始同步外部任务..."

# 1. 拉取最新代码（如果代理可用）
if git pull origin main 2>/dev/null; then
    echo "✅ 拉取最新代码成功"
else
    echo "⚠️ 拉取失败（可能是网络问题），使用本地版本"
fi

# 2. 检查外部任务文件
if [ ! -f "external-tasks.json" ]; then
    echo "ℹ️ 没有外部任务文件"
    exit 0
fi

# 3. 获取待处理任务
PENDING_TASKS=$(jq -c '.tasks[] | select(.status == "pending")' external-tasks.json 2>/dev/null)

if [ -z "$PENDING_TASKS" ]; then
    echo "ℹ️ 没有待处理的外部任务"
    exit 0
fi

# 4. 遍历并同步
echo "$PENDING_TASKS" | while read -r task; do
    TASK_ID=$(echo "$task" | jq -r '.id')
    CONTENT=$(echo "$task" | jq -r '.content')
    PRIORITY=$(echo "$task" | jq -r '.priority')
    LABELS=$(echo "$task" | jq -r '.labels | @json')
    SOURCE=$(echo "$task" | jq -r '.source')
    
    echo "📝 处理任务: $CONTENT (来源: $SOURCE)"
    
    # 创建 Todoist 任务
    TODOIST_RESPONSE=$(./scripts/todoist_api.sh "tasks" POST "{
        \"content\": \"[外部/$SOURCE] $CONTENT\",
        \"project_id\": \"6CrgFVFHFmcxgrF5\",
        \"section_id\": \"6g4xvm8fH4q4wcv5\",
        \"priority\": $PRIORITY,
        \"labels\": $LABELS,
        \"description\": \"来源: $SOURCE | ID: $TASK_ID\"
    }")
    
    TODOIST_ID=$(echo "$TODOIST_RESPONSE" | jq -r '.id')
    
    if [ "$TODOIST_ID" != "null" ] && [ -n "$TODOIST_ID" ]; then
        echo "✅ 已创建 Todoist 任务: $TODOIST_ID"
        
        # 更新 external-tasks.json
        jq "(.tasks[] | select(.id == \"$TASK_ID\") | .todoistId) = \"$TODOIST_ID\" |
            (.tasks[] | select(.id == \"$TASK_ID\") | .status) = \"processing\"" \
            external-tasks.json > external-tasks.json.tmp
        mv external-tasks.json.tmp external-tasks.json
    else
        echo "❌ 创建 Todoist 任务失败"
    fi
done

# 5. 提交更改
if [ -n "$(git status --porcelain external-tasks.json)" ]; then
    git add external-tasks.json
    git commit -m "🔄 同步外部任务到 Todoist"
    
    # 尝试推送（如果代理可用）
    if git push origin main 2>/dev/null; then
        echo "✅ 已推送到 GitHub"
    else
        echo "⚠️ 推送失败（可能是网络问题），下次重试"
    fi
fi

echo "🎉 外部任务同步完成"
