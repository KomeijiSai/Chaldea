#!/bin/bash
# 每日任务生成脚本
# 用法: ./scripts/daily_plan_generator.sh

cd /root/.openclaw/workspace

# 加载环境变量
. ./.env 2>/dev/null

DATE=$(date '+%Y-%m-%d')
DAY_OF_WEEK=$(date +%u)

echo "📋 生成今日任务计划: $DATE"
echo "今天是周$DAY_OF_WEEK"
echo ""

PROJECT_ID="6CrgFVFHFmcxgrF5"
IN_PROGRESS_SECTION="6g4xvm8fH4q4wcv5"

CREATED=0

# 创建任务函数
create_task() {
    local task="$1"
    local response=$(curl -s -X POST "https://api.todoist.com/api/v1/tasks" \
        -H "Authorization: Bearer $TODOIST_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"content\": \"$task\", \"project_id\": \"$PROJECT_ID\", \"section_id\": \"$IN_PROGRESS_SECTION\"}")
    
    if echo "$response" | jq -e '.id' > /dev/null 2>&1; then
        echo "✅ $task"
        return 0
    else
        echo "❌ 创建失败: $task"
        return 1
    fi
}

# P1 项目任务
echo "🔴 P1 项目任务"
create_task "📱 iOS 应用：设计双人早睡挑战的登录界面" && CREATED=$((CREATED + 1))
create_task "📱 iOS 应用：研究 SwiftUI 基础组件" && CREATED=$((CREATED + 1))

# P2 变现探索
echo ""
echo "🟢 P2 变现探索"
case $DAY_OF_WEEK in
    1) create_task "💰 小红书：分析 3 个 AI 工具博主的内容策略" && CREATED=$((CREATED + 1)) ;;
    2) create_task "💰 抖音：研究 AI 话题的变现路径" && CREATED=$((CREATED + 1)) ;;
    3) create_task "💰 YouTube：调研技术频道的广告收入模式" && CREATED=$((CREATED + 1)) ;;
    4) create_task "💰 B站：分析 UP 主的知识付费模式" && CREATED=$((CREATED + 1)) ;;
    5) create_task "💰 新平台：发现新兴变现机会" && CREATED=$((CREATED + 1)) ;;
    6) create_task "💰 整理本周发现的变现机会" && CREATED=$((CREATED + 1)) ;;
    7) create_task "💰 规划下周内容选题" && CREATED=$((CREATED + 1)) ;;
esac

create_task "💰 独立开发者案例研究" && CREATED=$((CREATED + 1))

# P3 自我优化
echo ""
echo "🔵 P3 自我优化"
create_task "📖 进化日记：记录系统上线" && CREATED=$((CREATED + 1))

echo ""
echo "📊 创建完成: $CREATED 个任务"

# 生成通知内容
echo ""
echo "=== 通知内容 ==="
echo "📋 今日计划 ($DATE)"
echo ""
echo "🔴 P1 项目任务"
echo "  □ iOS 应用 - 设计登录界面"
echo "  □ iOS 应用 - 研究 SwiftUI 组件"
echo ""
echo "🟢 P2 变现探索"
echo "  □ 平台调研任务"
echo "  □ 独立开发者案例研究"
echo ""
echo "🔵 P3 自我优化"
echo "  □ 进化日记记录"
echo ""
echo "总计: $CREATED 个任务"
