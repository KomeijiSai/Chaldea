# 📂 仓库目录结构设计方案

## 一、设计原则

1. **核心文件在根目录**（自主工作必需）
2. **清晰的功能分类**（按用途组织）
3. **归档机制**（已解决/过期的移走）
4. **不破坏自主工作流程**（路径更新到配置）

## 二、新目录结构

```
/root/.openclaw/workspace/
│
├── 📋 核心配置（根目录 - 自主工作必需）
│   ├── README.md                    # 仓库说明
│   ├── AGENTS.md                    # Agent 工作规则 ⭐
│   ├── HEARTBEAT.md                 # 心跳配置 ⭐
│   ├── MEMORY.md                    # 长期记忆 ⭐
│   ├── SOUL.md                      # 人设 ⭐
│   ├── USER.md                      # 用户信息 ⭐
│   ├── TOOLS.md                     # 工具说明 ⭐
│   ├── IDENTITY.md                  # 身份 ⭐
│   ├── EXTERNAL_TASKS_GUIDE.md      # 外部任务指南
│   └── external-tasks.json          # 外部任务队列 ⭐
│
├── 🧠 memory/                       # 记忆系统
│   ├── current-state.json           # 当前状态 ⭐
│   ├── AUTO_WORK_SYSTEM.md          # 工作系统文档 ⭐
│   ├── EVOLUTION_DIARY.md           # 进化日记 ⭐
│   ├── TASK_GENERATION.md           # 任务生成规则 ⭐
│   ├── TODOIST_RULES.md             # Todoist 规则 ⭐
│   ├── SYSTEM_ROBUSTNESS.md         # 系统健壮性
│   │
│   ├── daily/                       # 每日记录
│   │   ├── 2026-02-24.md
│   │   ├── 2026-02-25.md
│   │   └── 2026-02-26.md
│   │
│   ├── research/                    # 调研记录
│   │   ├── IMAGE_API_COMPARISON.md  # API 对比
│   │   ├── API_STATUS.md
│   │   ├── proxy-status-2026-02-26.md
│   │   └── bilibili_analysis_*.md
│   │
│   ├── system/                      # 系统状态
│   │   ├── health-status.json
│   │   ├── kanban.json
│   │   └── heartbeat-state.json
│   │
│   ├── conversations/               # 对话记录（保持原位）
│   ├── selfies/                     # 自拍相册（保持原位）
│   └── opportunities/               # 商机（保持原位）
│
├── 📦 archive/                      # 归档目录（新增）
│   ├── solved/                      # 已解决问题
│   │   └── 2026-02-26/
│   │       ├── RESET_COMPLETE.md
│   │       └── proxy-status-2026-02-26.md
│   │
│   └── outdated/                    # 过期文档
│       └── API_REGISTRATION_GUIDE_old.md
│
├── 🔧 scripts/                      # 脚本（保持原位）
│   ├── sync_external_tasks.sh       # 外部任务同步 ⭐
│   ├── complete_external_task.sh    # 完成外部任务 ⭐
│   ├── todoist_api.sh               # Todoist API ⭐
│   ├── add_comment.sh
│   ├── close_task.sh
│   └── ... (其他脚本)
│
├── 🚀 projects/                     # 项目（保持原位）
│   ├── SleepApp/
│   ├── TravelApp/
│   └── SteamGame/
│
├── 🧪 mvp/                          # MVP（保持原位）
│   └── ios-app-research/
│
├── 📚 research/                     # 研究文档（保持原位）
│   ├── indie-hackers/
│   ├── ios-swiftui/
│   └── youtube-monetization/
│
└── 📁 其他目录（保持原位）
    ├── clawra-modelscope/
    ├── media/
    ├── secrets/
    └── skills/
```

## 三、归档规则

### 需要归档的内容

1. **已解决的问题** → `archive/solved/YYYY-MM-DD/`
   - 问题已解决，不再需要关注的文档
   - 示例：`RESET_COMPLETE.md`（系统重置已完成）

2. **过期的文档** → `archive/outdated/`
   - 已被新文档替代的旧版本
   - 示例：`API_REGISTRATION_GUIDE_old.md`

3. **长期未关注（30天+）** → `archive/inactive/`
   - 超过 30 天未更新的调研或问题
   - 定期检查（每月一次）

### 保留在当前目录的内容

1. **核心配置文件**（根目录）
   - 自主工作系统必需的文件
   - 不能移动

2. **活跃的文档**（30天内有更新）
   - 最近还在使用的记录
   - 定期访问的文档

3. **系统运行必需**
   - 脚本文件
   - 状态文件
   - 外部任务队列

## 四、文件移动清单

### 移动到 `memory/daily/`
```
memory/2026-02-24.md
memory/2026-02-25.md
memory/2026-02-25-summary.md
memory/2026-02-26.md
```

### 移动到 `memory/research/`
```
memory/IMAGE_API_COMPARISON.md
memory/IMAGE_API_RESEARCH.md
memory/FREE_APIS_ONLY.md
memory/FREE_IMAGE_API.md
memory/API_STATUS.md
memory/API_VERIFICATION_STATUS.md
memory/LEONARDO_SETUP.md
memory/NOTIFICATION_PREFERENCE.md
memory/当前方案.md
memory/bilibili_analysis_2026-02-26.md
memory/selfie-alternatives-research-2026-02-26.md
```

### 移动到 `memory/system/`
```
memory/health-status.json
memory/health-log-20260226.json
memory/kanban.json
memory/heartbeat-state.json
memory/tasks.json
```

### 移动到 `archive/solved/2026-02-26/`
```
memory/RESET_COMPLETE.md
memory/proxy-status-2026-02-26.md
```

### 移动到 `archive/outdated/`
```
memory/API_REGISTRATION_GUIDE_old.md
```

## 五、需要更新的配置

### 1. AGENTS.md
- 更新每日记录路径：`memory/YYYY-MM-DD.md` → `memory/daily/YYYY-MM-DD.md`

### 2. HEARTBEAT.md
- 更新状态文件路径：`memory/current-state.json`（不变）
- 更新心跳状态路径：`memory/heartbeat-state.json` → `memory/system/heartbeat-state.json`

### 3. 脚本文件
- 检查所有脚本中的路径引用
- 更新为新路径

## 六、执行步骤

1. ✅ 创建新目录结构
2. ⏳ 移动文件到新位置
3. ⏳ 更新配置文件（AGENTS.md, HEARTBEAT.md 等）
4. ⏳ 更新脚本中的路径
5. ⏳ 测试自主工作流程
6. ⏳ 提交到 Git

## 七、归档维护计划

### 每周检查（周日 22:00）
- 扫描 `memory/` 目录
- 识别 30 天未更新的文件
- 评估是否需要归档

### 每月清理（每月 1 日）
- 检查 `archive/` 目录
- 删除过期的归档（超过 90 天）
- 更新归档索引

### 自动归档规则
```bash
# 识别 30 天未更新的文件
find memory/ -name "*.md" -mtime +30 -type f

# 自动移动到 archive/inactive/
# （需要云眠审核后执行）
```

---

*设计时间: 2026-02-26 12:10*
*设计者: 九公主秦云眠*
