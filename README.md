# 📂 仓库结构说明

> 最后更新: 2026-02-26 12:15

## 核心配置（根目录）

这些文件是云眠自主工作的核心，**不要移动或删除**：

- `AGENTS.md` - Agent 工作规则 ⭐
- `HEARTBEAT.md` - 心跳配置 ⭐
- `MEMORY.md` - 长期记忆 ⭐
- `SOUL.md` - 人设（九公主秦云眠）⭐
- `USER.md` - 用户信息 ⭐
- `TOOLS.md` - 工具说明 ⭐
- `IDENTITY.md` - 身份 ⭐
- `README.md` - 仓库说明 ⭐
- `EXTERNAL_TASKS_GUIDE.md` - 外部任务指南
- `external-tasks.json` - 外部任务队列 ⭐

## 目录说明

### memory/ - 记忆系统

```
memory/
├── current-state.json      # 当前状态 ⭐
│
├── core/                   # 核心系统文档 ⭐
│   ├── AUTO_WORK_SYSTEM.md
│   ├── SYSTEM_ROBUSTNESS.md
│   ├── TASK_GENERATION.md
│   ├── TODOIST_RULES.md
│   └── DIARY_SELFIE_SYSTEM.md
│
├── evolution/              # 进化日记 ⭐
│   ├── EVOLUTION_DIARY.md
│   └── session-tracking.md
│
├── daily/                  # 每日记录
│   └── YYYY-MM-DD.md
│
├── research/               # 调研文档
│   ├── IMAGE_API_COMPARISON.md
│   ├── API_STATUS.md
│   └── ...
│
├── guides/                 # 指南文档
│   ├── recommended-skills.md
│   ├── software-dev-skills.md
│   └── daily-task-generator.md
│
├── system/                 # 系统状态
│   ├── health-status.json
│   ├── kanban.json
│   └── heartbeat-state.json
│
├── conversations/          # 对话记录
├── selfies/               # 自拍相册
└── opportunities/         # 商机库
```

### archive/ - 归档目录

```
archive/
├── solved/                # 已解决问题
│   └── YYYY-MM-DD/       # 按日期归档
│
├── outdated/              # 过期文档
│
└── inactive/              # 长期未关注（30天+）
```

### scripts/ - 脚本

所有自动化脚本，保持原位。

### projects/ - 项目

御主的开发项目：
- `SleepApp/` - 早睡提醒应用
- `TravelApp/` - 旅行游记应用
- `SteamGame/` - Steam 游戏

### mvp/ - MVP 项目

最小可行产品：
- `ios-app-research/` - iOS 应用研究

### research/ - 研究文档

各类调研文档：
- `indie-hackers/` - 独立开发者案例
- `ios-swiftui/` - SwiftUI 学习
- `youtube-monetization/` - YouTube 变现

## 归档规则

### 自动归档

1. **已解决问题** → `archive/solved/YYYY-MM-DD/`
   - 问题已解决，不再需要关注
   - 示例：`RESET_COMPLETE.md`

2. **过期文档** → `archive/outdated/`
   - 已被新文档替代
   - 示例：`API_REGISTRATION_GUIDE_old.md`

3. **长期未关注** → `archive/inactive/`
   - 30 天未更新
   - 定期检查（每月一次）

### 归档维护

- **每周检查**：扫描 30 天未更新的文件
- **每月清理**：删除 90 天以上的归档
- **手动触发**：御主或云眠主动整理

## 路径引用更新

所有核心配置文件中的路径已更新：

- ✅ `AGENTS.md` - `memory/daily/YYYY-MM-DD.md`
- ✅ `HEARTBEAT.md` - `memory/system/health-status.json`
- ✅ 脚本文件 - 系统状态路径

## 查找文件

### 查找每日记录
```bash
ls memory/daily/
```

### 查找调研文档
```bash
ls memory/research/
```

### 查找系统状态
```bash
ls memory/system/
```

### 查找已解决问题
```bash
ls archive/solved/
```

---

*云眠的仓库结构 - 清晰、有序、易维护*
