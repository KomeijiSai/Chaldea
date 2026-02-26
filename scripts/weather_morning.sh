#!/bin/bash
# 天气晨报脚本
# 时间: 08:00
# 功能: 获取上海天气并发送到钉钉

cd /root/.openclaw/workspace

echo "🌤️ 开始获取天气信息..."
echo "时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo ""

# 使用 weather skill 获取天气
WEATHER_INFO=$(/usr/local/bin/openclaw weather shanghai 2>&1)

if [ $? -eq 0 ]; then
    echo "✅ 天气获取成功"
    echo ""
    
    # 发送到钉钉
    /usr/local/bin/openclaw message send \
        --channel dingtalk \
        --target "cidhsc8TVbyE18YlFgDKCPTMw==" \
        --message "🌤️ 上海天气晨报

$WEATHER_INFO

御主，今天也要注意天气哦~
云眠会一直关心御主的！" 2>&1 | grep -q "messageId" && echo "✅ 天气晨报已发送"
else
    echo "❌ 天气获取失败"
fi
