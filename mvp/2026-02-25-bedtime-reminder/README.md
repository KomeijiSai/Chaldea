# 🌙 早睡提醒助手 MVP

**作者**: Clawra (OpenClaw AI Assistant)  
**日期**: 2026-02-25  
**版本**: v1.0

## 背景

根据 Sai 的目标："养成早睡习惯，改善作息时间"，我构建了这个早睡提醒工具的 MVP。

## 功能特点

### ✅ 核心功能
1. **目标睡觉时间设置** - 默认 23:00
2. **渐进式提醒** - 提前 30/15/5 分钟
3. **每日记录** - 记录实际睡觉时间
4. **统计分析** - 计算准时率和平均睡觉时间
5. **Slack 集成** - 自动发送提醒和报告

### 🎯 设计理念
- **简单实用** - 最小化功能，专注核心价值
- **渐进提醒** - 避免一次性提醒的突兀感
- **数据驱动** - 通过统计帮助用户了解自己的作息
- **温和提醒** - 友好的提示语，不制造焦虑

## 使用方法

### 1. 命令行使用

```bash
# 启动交互式界面
python3 bedtime_reminder.py

# 选项:
# 1. 记录今天的睡觉时间
# 2. 修改目标睡觉时间
# 3. 生成报告
# 4. 退出
```

### 2. 作为模块使用

```python
from bedtime_reminder import BedtimeReminder

# 初始化
reminder = BedtimeReminder()

# 设置目标时间
reminder.config["target_bedtime"] = "22:30"
reminder.save_config()

# 记录睡觉时间
record = reminder.record_bedtime("23:15")

# 获取统计
stats = reminder.get_stats(7)
print(f"准时率: {stats['on_time_rate']}")
```

### 3. Slack 集成

```python
from slack_notifier import SlackNotifier

notifier = SlackNotifier(channel="#random")

# 发送提醒
notifier.send_bedtime_reminder(30, "23:00")

# 发送周报
stats = reminder.get_stats(7)
notifier.send_daily_report(stats)
```

## 文件结构

```
2026-02-25-bedtime-reminder/
├── README.md              # 本文件
├── bedtime_reminder.py    # 核心功能
├── slack_notifier.py      # Slack 集成
└── install.sh            # 安装脚本 (TODO)
```

## 数据存储

所有数据存储在 `~/.bedtime-reminder/` 目录:

- `config.json` - 配置文件（目标时间、提醒间隔等）
- `history.json` - 历史记录（最近30天）

## 未来扩展

### 短期 (v1.1)
- [ ] Cron 定时任务自动提醒
- [ ] 睡眠质量评分
- [ ] 周末/工作日不同目标

### 中期 (v2.0)
- [ ] iOS App (SwiftUI)
- [ ] Apple Watch 提醒
- [ ] 多用户支持（家人共享）

### 长期 (v3.0)
- [ ] AI 分析作息模式
- [ ] 个性化建议
- [ ] 与健康数据集成

## 技术栈

- **语言**: Python 3.8+
- **存储**: JSON 文件
- **通知**: Slack API (可选)
- **依赖**: 无外部依赖（标准库）

## 为什么选择这个 MVP？

1. **符合目标** - 直接响应 Sai 的个人生活目标
2. **实用价值** - 早睡习惯对健康和工作效率都很重要
3. **技术可行** - 简单但完整，可以快速验证价值
4. **可扩展** - 未来可以发展成完整的 iOS App
5. **家庭友好** - 设计考虑了和老婆一起使用

## 致谢

这个 MVP 是在 2026-02-25 的每日总结中构建的，灵感来自 Sai 的个人目标："养成早睡习惯，改善作息时间"。

---

**由 Clawra 用 ❤️ 生成**

*今天完成的工作：Kanban 看板修复、Todoist 任务系统、图像生成修复、Slack 配置、Clawra Selfie 优化*
