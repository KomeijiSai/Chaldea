#!/bin/bash
# 每日任务生成脚本（优化版）
# 时间: 05:00
# 功能: 生成今日任务并推送到 Todoist

cd /root/.openclaw/workspace

# 加载工具函数
source scripts/task_utils.sh

echo "📋 开始生成今日任务..."
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 健康自检
self_health_check

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

    # ✅ 增强：根据时间段和御主目标的任务模板
    HOUR=$(date +%H)
    DAY=$(date +%u)  # 1-7

    # 工作日任务池
    if [ "$DAY" -le 5 ]; then
        if [ "$HOUR" -ge 8 ] && [ "$HOUR" -lt 12 ]; then
            # 上午：变现探索
            TASK_POOL=(
                "分析 3 个小红书 AI 工具博主的内容策略|2|分析报告"
                "研究抖音 AI 话题的变现路径|2|变现方案"
                "调研 YouTube 技术频道的广告收入模式|2|调研报告"
            )
        elif [ "$HOUR" -ge 12 ] && [ "$HOUR" -lt 18 ]; then
            # 下午：项目推进
            TASK_POOL=(
                "iOS 应用：研究 HealthKit 集成方案|1|技术方案"
                "Steam 游戏：调研上架流程|1|流程文档"
                "整理项目文档和 README|1|更新后的文档"
            )
        else
            # 晚上：学习提升
            TASK_POOL=(
                "学习 SwiftUI 动画效果|3|学习笔记"
                "阅读独立开发者成功案例|3|案例总结"
                "研究 AI Agent 最新进展|3|趋势报告"
            )
        fi
    else
        # 周末偏重学习和规划
        TASK_POOL=(
            "规划下周内容选题|3|选题日历"
            "整理本周学习笔记|3|整理后的笔记"
            "复盘本周工作成果|3|周报"
        )
    fi

    # 随机选择 2-3 个任务
    NUM_TASKS=$((RANDOM % 2 + 2))
    CREATED=0

    for i in $(seq 1 $NUM_TASKS); do
        # 随机选择任务
        TASK_INDEX=$((RANDOM % ${#TASK_POOL[@]}))
        TASK_ENTRY="${TASK_POOL[$TASK_INDEX]}"

        # 解析任务内容
        TASK_CONTENT=$(echo "$TASK_ENTRY" | cut -d'|' -f1)
        TASK_PRIORITY=$(echo "$TASK_ENTRY" | cut -d'|' -f2)
        TASK_OUTPUT=$(echo "$TASK_ENTRY" | cut -d'|' -f3)

        echo ""
        echo "创建任务: $TASK_CONTENT"

        # ✅ 新增：检查重复
        if check_duplicate_task "$TASK_CONTENT"; then
            echo "⚠️ 任务已存在，跳过"
            continue
        fi

        # 创建任务到 In Progress
        RESPONSE=$(./scripts/todoist_api.sh "tasks" "POST" "{
            \"content\": \"$TASK_CONTENT\",
            \"project_id\": \"6CrgFVFHFmcxgrF5\",
            \"section_id\": \"6g4xvm8fH4q4wcv5\",
            \"priority\": $TASK_PRIORITY,
            \"description\": \"预期产出: $TASK_OUTPUT\"
        }" 2>/dev/null)

        if [ $? -eq 0 ] && [ -n "$(echo "$RESPONSE" | jq -r '.id' 2>/dev/null)" ]; then
            echo "✅ 任务创建成功"
            CREATED=$((CREATED + 1))
        else
            echo "❌ 任务创建失败"
        fi
    done

    echo ""
    echo "✅ 成功创建 $CREATED 个新任务"
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
$(if [ "$TASK_COUNT" -lt 3 ]; then echo "新增任务: $CREATED 个"; else echo "无需新增任务"; fi)

御主，云眠已经帮您安排好今天的任务了~
哼！才不是因为想让御主轻松一点呢！" 2>&1 | grep -q "messageId" && echo "✅ 通知已发送"
