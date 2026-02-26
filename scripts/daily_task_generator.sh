#!/bin/bash
# 每日任务生成脚本
# 时间: 05:00
# 功能: 生成今日任务并推送到 Todoist

cd /root/.openclaw/workspace

echo "📋 开始生成今日任务..."
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 检查 Todoist 任务数量
TASK_COUNT=$(./scripts/todoist_api.sh "tasks" "GET" 2>/dev/null | python3 -c "
import sys, json
try:
    tasks = json.load(sys.stdin)
    print(len(tasks))
except:
    print(0)
")

echo "当前 Todoist 任务数: $TASK_COUNT"

# 如果任务少于3个，生成新任务
if [ "$TASK_COUNT" -lt 3 ]; then
    echo ""
    echo "⚠️ 任务数量不足，开始生成新任务..."
    
    # 任务模板
    TASKS=(
        "检查并优化系统配置"
        "清理临时文件和日志"
        "更新项目文档"
        "检查系统安全状态"
        "优化内存使用"
    )
    
    # 随机选择 2-3 个任务
    NUM_TASKS=$((RANDOM % 2 + 2))
    
    for i in $(seq 1 $NUM_TASKS); do
        TASK_INDEX=$((RANDOM % ${#TASKS[@]}))
        TASK_CONTENT="${TASKS[$TASK_INDEX]}"
        
        echo ""
        echo "创建任务: $TASK_CONTENT"
        
        # 创建任务到 In Progress
        ./scripts/todoist_api.sh "tasks" "POST" "{
            \"content\": \"$TASK_CONTENT\",
            \"project_id\": \"6CrgFVFHFmcxgrF5\",
            \"section_id\": \"6g4xvm8fH4q4wcv5\"
        }" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "✅ 任务创建成功"
        else
            echo "❌ 任务创建失败"
        fi
    done
else
    echo ""
    echo "✅ 任务数量充足，无需生成新任务"
fi

echo ""
echo "✅ 每日任务生成完成"

# 发送通知到钉钉
/usr/local/bin/openclaw message send \
    --channel dingtalk \
    --target "cidhsc8TVbyE18YlFgDKCPTMw==" \
    --message "📋 每日任务生成完成

当前任务数: $TASK_COUNT
$(if [ "$TASK_COUNT" -lt 3 ]; then echo "新增任务: $NUM_TASKS 个"; else echo "无需新增任务"; fi)

御主，云眠已经帮您安排好今天的任务了~
哼！才不是因为想让御主轻松一点呢！" 2>&1 | grep -q "messageId" && echo "✅ 通知已发送"
