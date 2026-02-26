#!/bin/bash
# 任务队列检查脚本
# 时间: 每2小时
# 功能: 检查任务队列，不足则生成新任务

cd /root/.openclaw/workspace

echo "🔍 检查任务队列..."
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 检查任务数量
TASK_COUNT=$(./scripts/todoist_api.sh "tasks" "GET" 2>/dev/null | python3 -c "
import sys, json
try:
    tasks = json.load(sys.stdin)
    print(len(tasks))
except:
    print(0)
" 2>/dev/null || echo "0")

echo "当前任务数: $TASK_COUNT"

# 如果任务少于3个，生成新任务
if [ "$TASK_COUNT" -lt 3 ]; then
    echo ""
    echo "⚠️ 任务数量不足，开始生成新任务..."
    ./scripts/daily_task_generator.sh
else
    echo "✅ 任务数量充足"
fi
