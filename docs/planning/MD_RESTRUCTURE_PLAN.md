# 📂 MD 文件整理方案

## 一、当前状态

**总计**: 71 个 md 文件

**问题**：
1. 根目录太多非核心文档（11 个）
2. memory/ 目录文档杂乱（20+ 个）
3. 缺少清晰的分类
4. 有重复文件（EVOLUTION_DIARY.md）

## 二、整理原则

### 根目录（只保留核心配置）

**必须保留**（10 个）：
```
AGENTS.md          # Agent 工作规则 ⭐
HEARTBEAT.md       # 心跳配置 ⭐
MEMORY.md          # 长期记忆 ⭐
SOUL.md            # 人设 ⭐
USER.md            # 用户信息 ⭐
TOOLS.md           # 工具说明 ⭐
IDENTITY.md        # 身份 ⭐
README.md          # 仓库说明 ⭐
external-tasks.json # 外部任务队列 ⭐
EXTERNAL_TASKS_GUIDE.md # 外部任务指南
```

**需要移动**（2 个）：
```
EVOLUTION_DIARY.md → memory/evolution/（删除重复）
DIRECTORY_RESTRUCTURE_PLAN.md → docs/planning/
```

## 三、新目录结构

### 1. 根目录（核心配置）

只保留 10 个必需文件。

### 2. memory/ 重新分类

```
memory/
├── core/                      # 核心系统文档
│   ├── AUTO_WORK_SYSTEM.md
│   ├── SYSTEM_ROBUSTNESS.md
│   ├── TASK_GENERATION.md
│   ├── TODOIST_RULES.md
│   └── DIARY_SELFIE_SYSTEM.md
│
├── daily/                     # 每日记录（已整理）
│   └── YYYY-MM-DD.md
│
├── evolution/                 # 进化日记（新增）
│   ├── EVOLUTION_DIARY.md
│   └── session-tracking.md
│
├── research/                  # 调研文档（已整理）
│   └── ...
│
├── guides/                    # 指南文档（新增）
│   ├── recommended-skills.md
│   ├── software-dev-skills.md
│   └── daily-task-generator.md
│
├── system/                    # 系统状态（已整理）
│   └── ...
│
├── conversations/             # 对话记录（保持原位）
│   └── README.md
│
├── selfies/                   # 自拍相册（保持原位）
│   └── ...
│
└── opportunities/             # 商机库（保持原位）
    └── README.md
```

### 3. docs/ 目录（新增）

```
docs/
├── planning/                  # 规划文档
│   └── DIRECTORY_RESTRUCTURE_PLAN.md
│
└── guides/                    # 使用指南
    └── ...
```

## 四、移动清单

### 根目录 → memory/core/
```
memory/AUTO_WORK_SYSTEM.md → memory/core/
memory/SYSTEM_ROBUSTNESS.md → memory/core/
memory/TASK_GENERATION.md → memory/core/
memory/TODOIST_RULES.md → memory/core/
memory/DIARY_SELFIE_SYSTEM.md → memory/core/
```

### 根目录 → memory/evolution/
```
EVOLUTION_DIARY.md → memory/evolution/（删除重复）
memory/EVOLUTION_DIARY.md → memory/evolution/
memory/session-tracking.md → memory/evolution/
```

### 根目录 → memory/guides/
```
memory/recommended-skills.md → memory/guides/
memory/software-dev-skills.md → memory/guides/
memory/daily-task-generator.md → memory/guides/
```

### 根目录 → docs/planning/
```
DIRECTORY_RESTRUCTURE_PLAN.md → docs/planning/
```

## 五、需要更新的配置

### AGENTS.md
```markdown
## Every Session

1. Read `SOUL.md`
2. Read `USER.md`
3. Read `memory/daily/YYYY-MM-DD.md`
4. **If in MAIN SESSION**: Also read `MEMORY.md`
5. **检查未处理的对话** - `memory/conversations/pending/`
```

### HEARTBEAT.md
```markdown
### 3️⃣ 检查系统状态
```bash
cat /root/.openclaw/workspace/memory/system/health-status.json
cat /root/.openclaw/workspace/memory/system/kanban.json
```
```

### 其他引用
- 检查所有脚本中的路径引用
- 更新 MEMORY.md 中的路径说明

## 六、执行步骤

1. ✅ 创建新目录结构
2. ⏳ 移动文件
3. ⏳ 删除重复文件
4. ⏳ 更新配置文件
5. ⏳ 测试自主工作
6. ⏳ 提交到 Git

## 七、整理后统计

**根目录**: 10 个文件（核心配置）
**memory/**: 50+ 个文件（分类清晰）
**docs/**: 2+ 个文件（规划文档）
**其他**: 保持原位

**总计**: 仍然是 71 个文件，但结构清晰

---

*设计时间: 2026-02-26 12:20*
*设计者: 九公主秦云眠*
