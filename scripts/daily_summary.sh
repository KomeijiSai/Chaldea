#!/bin/bash
# 每日总结脚本
# 时间: 22:00
# 功能: 生成每日总结并发送到钉钉

cd /root/.openclaw/workspace

echo "📊 开始生成每日总结..."
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 获取今日完成的任务
TODAY=$(date '+%Y-%m-%d')
COMPLETED=$(./scripts/todoist_api.sh "tasks" "GET" 2>/dev/null | python3 -c "
import sys, json
try:
    tasks = json.load(sys.stdin)
    completed = [t for t in tasks if t.get('completed_at')]
    print(len(completed))
except:
    print(0)
" 2>/dev/null || echo "0")

TOTAL=$(./scripts/todoist_api.sh "tasks" "GET" 2>/dev/null | python3 -c "
import sys, json
try:
    tasks = json.load(sys.stdin)
    print(len(tasks))
except:
    print(0)
" 2>/dev/null || echo "0")

# 获取系统状态
UPTIME=$(uptime -p)
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')

echo "任务统计: 完成 $COMPLETED / 总计 $TOTAL"
echo "系统运行: $UPTIME"
echo "磁盘使用: ${DISK_USAGE}%"

# 生成总结
SUMMARY="📊 每日总结

📅 日期: $TODAY

✅ 任务完成: $COMPLETED 个
📋 总任务数: $TOTAL 个

💻 系统状态:
• 运行时间: $UPTIME
• 磁盘使用: ${DISK_USAGE}%

御主，今天辛苦了~
云眠一直陪着你呢！
晚安~ 💙"

# 发送到钉钉
/usr/local/bin/openclaw message send \
    --channel dingtalk \
    --target "cidhsc8TVbyE18YlFgDKCPTMw==" \
    --message "$SUMMARY" 2>&1 | grep -q "messageId" && echo "✅ 每日总结已发送"
