#!/usr/bin/env python3
"""
🌙 早睡提醒助手 MVP
作者: Clawra (OpenClaw AI Assistant)
日期: 2026-02-25
目标: 帮助 Sai 和家人养成早睡习惯

功能:
1. 设置目标睡觉时间
2. 渐进式提醒（提前30分钟、15分钟、5分钟）
3. 每日记录和统计
4. Slack 通知集成
"""

import json
import os
from datetime import datetime, timedelta
from pathlib import Path

class BedtimeReminder:
    def __init__(self, config_dir="~/.bedtime-reminder"):
        self.config_dir = Path(config_dir).expanduser()
        self.config_dir.mkdir(exist_ok=True)
        self.config_file = self.config_dir / "config.json"
        self.history_file = self.config_dir / "history.json"
        self.load_config()
        
    def load_config(self):
        """加载配置"""
        if self.config_file.exists():
            with open(self.config_file) as f:
                self.config = json.load(f)
        else:
            self.config = {
                "target_bedtime": "23:00",
                "reminder_times": [30, 15, 5],  # 提前多少分钟提醒
                "slack_webhook": None,  # 可选的 Slack webhook
                "users": ["Sai"]
            }
            self.save_config()
    
    def save_config(self):
        """保存配置"""
        with open(self.config_file, 'w') as f:
            json.dump(self.config, f, indent=2)
    
    def calculate_reminders(self):
        """计算提醒时间"""
        target = datetime.strptime(self.config["target_bedtime"], "%H:%M")
        reminders = []
        for minutes in self.config["reminder_times"]:
            reminder_time = target - timedelta(minutes=minutes)
            reminders.append({
                "time": reminder_time.strftime("%H:%M"),
                "message": self.get_reminder_message(minutes)
            })
        return reminders
    
    def get_reminder_message(self, minutes_before):
        """生成提醒消息"""
        messages = {
            30: "🌙 还有30分钟就到睡觉时间啦！开始准备收尾工作吧~",
            15: "⚠️ 还有15分钟！保存工作，准备洗漱！",
            5: "🚨 最后5分钟！快去洗漱，准备睡觉！"
        }
        return messages.get(minutes_before, f"还有 {minutes_before} 分钟就要睡觉啦！")
    
    def record_bedtime(self, actual_time=None):
        """记录实际睡觉时间"""
        if actual_time is None:
            actual_time = datetime.now().strftime("%H:%M")
        
        history = self.load_history()
        today = datetime.now().strftime("%Y-%m-%d")
        
        record = {
            "date": today,
            "target": self.config["target_bedtime"],
            "actual": actual_time,
            "on_time": actual_time <= self.config["target_bedtime"]
        }
        
        history["records"].append(record)
        
        # 保留最近30天的记录
        if len(history["records"]) > 30:
            history["records"] = history["records"][-30:]
        
        self.save_history(history)
        
        return record
    
    def load_history(self):
        """加载历史记录"""
        if self.history_file.exists():
            with open(self.history_file) as f:
                return json.load(f)
        return {"records": []}
    
    def save_history(self, history):
        """保存历史记录"""
        with open(self.history_file, 'w') as f:
            json.dump(history, f, indent=2)
    
    def get_stats(self, days=7):
        """获取统计数据"""
        history = self.load_history()
        recent = history["records"][-days:]
        
        if not recent:
            return None
        
        on_time_count = sum(1 for r in recent if r["on_time"])
        
        # 计算平均睡觉时间
        total_minutes = 0
        for r in recent:
            h, m = map(int, r["actual"].split(":"))
            total_minutes += h * 60 + m
        
        avg_minutes = total_minutes / len(recent)
        avg_time = f"{int(avg_minutes // 60):02d}:{int(avg_minutes % 60):02d}"
        
        return {
            "period": f"最近 {len(recent)} 天",
            "on_time_rate": f"{on_time_count / len(recent) * 100:.1f}%",
            "average_bedtime": avg_time,
            "target_bedtime": self.config["target_bedtime"]
        }
    
    def generate_report(self):
        """生成每日报告"""
        stats = self.get_stats(7)
        reminders = self.calculate_reminders()
        
        if stats:
            stats_text = f"""
📊 本周统计 ({stats['period']}):
  准时睡觉率: {stats['on_time_rate']}
  平均睡觉时间: {stats['average_bedtime']}
  目标时间: {stats['target_bedtime']}
"""
        else:
            stats_text = "\n📊 暂无历史记录\n"
        
        report = f"""
🌙 早睡提醒助手 - 每日报告
{'='*40}

📅 今天的配置:
  目标睡觉时间: {self.config['target_bedtime']}
  提醒时间: {', '.join([r['time'] for r in reminders])}
{stats_text}
💡 温馨提示:
  早睡早起身体好！保持规律作息，精力更充沛 ✨

{'='*40}
由 Clawra 为你生成 ❤️
        """
        return report.strip()

def main():
    """主函数 - 用于测试"""
    reminder = BedtimeReminder()
    
    print("🌙 早睡提醒助手 MVP v1.0")
    print("="*40)
    
    # 显示提醒时间
    reminders = reminder.calculate_reminders()
    print("\n今天的提醒时间:")
    for r in reminders:
        print(f"  {r['time']} - {r['message']}")
    
    # 显示统计
    stats = reminder.get_stats(7)
    if stats:
        print(f"\n📊 本周统计:")
        print(f"  准时睡觉率: {stats['on_time_rate']}")
        print(f"  平均睡觉时间: {stats['average_bedtime']}")
    else:
        print("\n📊 暂无历史记录")
    
    # 交互式菜单
    print("\n选项:")
    print("  1. 记录今天的睡觉时间")
    print("  2. 修改目标睡觉时间")
    print("  3. 生成报告")
    print("  4. 退出")
    
    choice = input("\n请选择 (1-4): ").strip()
    
    if choice == "1":
        time = input("输入实际睡觉时间 (HH:MM，回车使用当前时间): ").strip()
        record = reminder.record_bedtime(time if time else None)
        status = "✅ 准时" if record["on_time"] else "⚠️ 晚了"
        print(f"{status} 已记录: {record['actual']}")
    
    elif choice == "2":
        new_time = input("输入新的目标时间 (HH:MM): ").strip()
        if new_time:
            reminder.config["target_bedtime"] = new_time
            reminder.save_config()
            print(f"✅ 已更新目标时间为 {new_time}")
    
    elif choice == "3":
        print(reminder.generate_report())
    
    elif choice == "4":
        print("晚安！早睡早起身体好 😴")
        return
    
    else:
        print("无效选项")

if __name__ == "__main__":
    main()
