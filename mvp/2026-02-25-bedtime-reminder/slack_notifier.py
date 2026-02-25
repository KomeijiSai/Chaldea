#!/usr/bin/env python3
"""
Slack 通知模块
用于发送早睡提醒到 Slack
"""

import json
import subprocess
from datetime import datetime

class SlackNotifier:
    def __init__(self, channel="#random"):
        self.channel = channel
    
    def send_message(self, message, blocks=None):
        """发送消息到 Slack (使用 OpenClaw 的 message 工具)"""
        # 这个脚本会被 OpenClaw 调用，所以可以直接使用 message 工具
        # 在独立运行时，可以使用 Slack CLI 或 webhook
        print(f"Sending to {self.channel}: {message}")
        if blocks:
            print(f"Blocks: {json.dumps(blocks, indent=2)}")
        return True
    
    def send_bedtime_reminder(self, minutes_before, target_time):
        """发送早睡提醒"""
        messages = {
            30: "🌙 还有30分钟就到睡觉时间啦！开始准备收尾工作吧~",
            15: "⚠️ 还有15分钟！保存工作，准备洗漱！",
            5: "🚨 最后5分钟！快去洗漱，准备睡觉！"
        }
        
        message = messages.get(minutes_before, f"还有 {minutes_before} 分钟就要睡觉啦！")
        
        blocks = [
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*🌙 早睡提醒*\n{message}\n\n目标睡觉时间: `{target_time}`"
                }
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "mrkdwn",
                        "text": f"发送时间: {datetime.now().strftime('%H:%M')} | 由 Clawra 早睡助手生成"
                    }
                ]
            }
        ]
        
        return self.send_message(message, blocks)
    
    def send_daily_report(self, stats):
        """发送每日报告"""
        blocks = [
            {
                "type": "header",
                "text": {
                    "type": "plain_text",
                    "text": "🌙 早睡提醒 - 本周报告"
                }
            },
            {
                "type": "section",
                "fields": [
                    {
                        "type": "mrkdwn",
                        "text": f"*统计周期:*\n{stats['period']}"
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*准时睡觉率:*\n{stats['on_time_rate']}"
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*平均睡觉时间:*\n{stats['average_bedtime']}"
                    },
                    {
                        "type": "mrkdwn",
                        "text": f"*目标时间:*\n{stats['target_bedtime']}"
                    }
                ]
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": "💡 *温馨提示:*\n早睡早起身体好！保持规律作息，精力更充沛 ✨"
                }
            },
            {
                "type": "divider"
            },
            {
                "type": "context",
                "elements": [
                    {
                        "type": "mrkdwn",
                        "text": "由 Clawra 早睡助手生成 ❤️ | 今天: 2026-02-25"
                    }
                ]
            }
        ]
        
        return self.send_message("本周早睡报告", blocks)

def main():
    """测试发送"""
    notifier = SlackNotifier()
    
    # 测试提醒
    print("测试早睡提醒...")
    notifier.send_bedtime_reminder(30, "23:00")
    
    # 测试报告
    print("\n测试每日报告...")
    stats = {
        "period": "最近 7 天",
        "on_time_rate": "85.7%",
        "average_bedtime": "22:45",
        "target_bedtime": "23:00"
    }
    notifier.send_daily_report(stats)

if __name__ == "__main__":
    main()
