#!/bin/bash
# 自主任务生成脚本
# 用法: ./scripts/generate_auto_task.sh

cd /root/.openclaw/workspace

# Todoist 配置
TODOIST_TOKEN="88cce657cb43ae889b41a5e4e4003e3fe0e87c93"
PROJECT_ID="6CrgFVFHFmcxgrF5"
IN_PROGRESS_SECTION="6g4xvm8fH4q4wcv5"

# 获取当前任务数量
TASK_COUNT=$(curl -s -X GET "https://api.todoist.com/api/v1/tasks?project_id=$PROJECT_ID" \
    -H "Authorization: Bearer $TODOIST_TOKEN" | jq 'length')

echo "当前任务数: $TASK_COUNT"

# 如果任务少于 3 个，生成新任务
if [ "$TASK_COUNT" -lt 3 ]; then
    echo "⚠️ 任务不足，开始生成新任务..."
    
    # 获取当前小时
    HOUR=$(date +%H)
    DAY_OF_WEEK=$(date +%u)  # 1=周一, 7=周日
    
    # 根据时间段选择任务类型
    if [ "$HOUR" -ge 8 ] && [ "$HOUR" -lt 12 ]; then
        # 上午：变现探索
        case $DAY_OF_WEEK in
            1) TASK="分析小红书 AI 工具博主的内容策略（3个对标账号）" ;;
            2) TASK="研究抖音 AI 话题的变现路径和爆款内容" ;;
            3) TASK="调研 YouTube 技术频道的广告收入和订阅模式" ;;
            4) TASK="分析 B站 UP 主的知识付费和充电模式" ;;
            5) TASK="发现新兴平台和变现机会（TikTok/知乎/公众号）" ;;
            6) TASK="整理本周发现的变现机会，评估优先级" ;;
            7) TASK="规划下周内容选题和发布计划" ;;
        esac
        PRIORITY="P2"
        LABEL="monetization"
        
    elif [ "$HOUR" -ge 12 ] && [ "$HOUR" -lt 18 ]; then
        # 下午：项目推进
        TASKS=(
            "iOS 应用：设计双人早睡挑战的 UI 界面"
            "iOS 应用：研究 HealthKit 睡眠数据获取"
            "iOS 应用：设计 Firebase 双人同步方案"
            "Steam 游戏：调研游戏上架流程和费用"
            "Steam 游戏：分析独立游戏成功案例"
        )
        RANDOM_INDEX=$((RANDOM % ${#TASKS[@]}))
        TASK="${TASKS[$RANDOM_INDEX]}"
        PRIORITY="P1"
        LABEL="project"
        
    elif [ "$HOUR" -ge 18 ] && [ "$HOUR" -lt 22 ]; then
        # 晚上：学习提升
        TASKS=(
            "学习 SwiftUI 动画和过渡效果"
            "阅读独立开发者成功案例并总结"
            "研究 AI Agent 最新进展和应用"
            "学习 iOS 应用上架最佳实践"
            "研究游戏引擎选择（Unity/Godot）"
        )
        RANDOM_INDEX=$((RANDOM % ${#TASKS[@]}))
        TASK="${TASKS[$RANDOM_INDEX]}"
        PRIORITY="P3"
        LABEL="learning"
        
    else
        # 深夜：系统优化
        TASKS=(
            "优化任务生成脚本的智能选择逻辑"
            "整理进化日记，补充今日记录"
            "更新 MEMORY.md 中的长期记忆"
            "检查并清理冗余的临时文件"
            "优化健康检查脚本"
        )
        RANDOM_INDEX=$((RANDOM % ${#TASKS[@]}))
        TASK="${TASKS[$RANDOM_INDEX]}"
        PRIORITY="P3"
        LABEL="system"
    fi
    
    # 创建任务
    RESPONSE=$(curl -s -X POST "https://api.todoist.com/api/v1/tasks" \
        -H "Authorization: Bearer $TODOIST_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{
            \"content\": \"$TASK\",
            \"project_id\": \"$PROJECT_ID\",
            \"section_id\": \"$IN_PROGRESS_SECTION\",
            \"labels\": [\"auto-generated\", \"$LABEL\"]
        }")
    
    TASK_ID=$(echo "$RESPONSE" | jq -r '.id')
    
    echo "✅ 已生成任务: $TASK"
    echo "   任务ID: $TASK_ID"
    echo "   类型: $LABEL"
    echo "   优先级: $PRIORITY"
    
    # 记录到日志
    echo "$(date '+%Y-%m-%d %H:%M'): 自动生成任务 - $TASK" >> memory/work-log/auto-tasks.log
    
else
    echo "✅ 任务充足 ($TASK_COUNT >= 3)，无需生成"
fi
