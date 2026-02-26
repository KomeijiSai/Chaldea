# MEMORY.md - 长期记忆

## 关于 Sai

- **身份**: 独立开发者 / AI 探索者
- **所在地**: 上海
- **工作习惯**: 简洁直接，不喜欢废话，重视工具效率
- **偏好**: 免费工具优先，不需要付费 API Key

### Sai 的目标体系

**Career:**
- 发布成功的软件产品，提升产品发布能力
- 持续提升技术技能，保持技术竞争力
- 提升在公司内部的技术影响力，成为技术领袖 AI应用方向

**Personal Growth:**
- 学习一门新的自然语言

**Business:**
- 利用AI工具提升收入，探索AI变现机会
- 创建符合自己需求的自动化工作流，提高工作效率

**Personal Life:**
- 规划并完成旅行计划
- 养成早睡习惯，改善作息时间

**Side Projects:**
- 积极参与开源贡献，提升技术声誉
- 开发创意项目和实验性想法
- 游戏开发相关项目
- 作为独立开发者上架一款高质量iOS应用
- 旅行游记应用
- 早睡提醒应用（和老婆）
- 上架 Steam 的游戏

## 设计偏好

- **永远不要使用蓝紫渐变色** 设计网页
- 推荐配色：黑白极简 + 蓝色强调（#18181B + #2563EB）
- 看板使用 OLED 暗黑模式 + 霓虹绿点缀

## 自主决策偏好

- **图像生成失败时**：自主尝试替代方案，不要问御主要 API Key
- 遇到技术问题：先尝试自己解决，失败了再汇报
- 优先使用免费工具和 API

## 仓库结构（2026-02-26 更新）

### 核心配置（根目录）

这些文件是云眠自主工作的核心，**不能移动**：

```
/root/.openclaw/workspace/
├── AGENTS.md                    # Agent 工作规则 ⭐
├── HEARTBEAT.md                 # 心跳配置 ⭐
├── MEMORY.md                    # 长期记忆（本文件）⭐
├── SOUL.md                      # 人设 ⭐
├── USER.md                      # 用户信息 ⭐
├── TOOLS.md                     # 工具说明 ⭐
├── IDENTITY.md                  # 身份 ⭐
├── README.md                    # 仓库说明 ⭐
├── EXTERNAL_TASKS_GUIDE.md      # 外部任务指南
└── external-tasks.json          # 外部任务队列 ⭐
```

### 目录结构

```
memory/
├── core/                    # 核心系统文档 ⭐
│   ├── AUTO_WORK_SYSTEM.md
│   ├── SYSTEM_ROBUSTNESS.md
│   ├── TASK_GENERATION.md
│   ├── TODOIST_RULES.md
│   └── DIARY_SELFIE_SYSTEM.md
│
├── evolution/               # 进化日记 ⭐
│   ├── EVOLUTION_DIARY.md
│   └── session-tracking.md
│
├── daily/                   # 每日记录
│   └── YYYY-MM-DD.md
│
├── research/                # 调研文档
│   ├── IMAGE_API_COMPARISON.md
│   └── ...
│
├── guides/                  # 指南文档
│   ├── recommended-skills.md
│   ├── software-dev-skills.md
│   └── daily-task-generator.md
│
├── system/                  # 系统状态
│   ├── health-status.json
│   ├── kanban.json
│   └── heartbeat-state.json
│
├── conversations/           # 对话记录
├── selfies/                 # 自拍相册
└── opportunities/           # 商机库

archive/
├── solved/                  # 已解决问题
│   └── YYYY-MM-DD/
├── outdated/                # 过期文档
└── inactive/                # 长期未关注（30天+）

docs/
└── planning/                # 规划文档
    ├── DIRECTORY_RESTRUCTURE_PLAN.md
    └── MD_RESTRUCTURE_PLAN.md
```

### 归档规则

1. **已解决问题** → `archive/solved/YYYY-MM-DD/`
2. **过期文档** → `archive/outdated/`
3. **长期未关注** → `archive/inactive/`

详见：`README.md` 和 `docs/planning/DIRECTORY_RESTRUCTURE_PLAN.md`

## 工具配置

### Todoist 任务可见性系统

用于追踪复杂任务的执行过程，御主可在 Todoist 中实时查看进度。

**脚本位置**: `/root/.openclaw/workspace/scripts/`

| 脚本 | 功能 | 用法 |
|------|------|------|
| `todoist_api.sh` | API 基础封装 | `./todoist_api.sh <endpoint> <method> [data]` |
| `sync_task.sh` | 创建/更新任务 | `./sync_task.sh <content> <status> [task_id] [desc] [labels]` |
| `add_comment.sh` | 添加进度评论 | `./add_comment.sh <task_id> <comment>` |
| `close_task.sh` | 完成任务 | `./close_task.sh <task_id>` |

**配置信息**:
- 项目: OpenClaw WorkSpace (`6CrgFVFHFmcxgrF5`)
- In Progress: `6g4xvm8fH4q4wcv5`
- Waiting: `6g4xvmpmQg8X2MgX`
- Done: `6g4xvp6Rc5x698p5`

**任务流程**:
1. 复杂任务开始 → 创建任务到 "In Progress"
2. 每个子步骤完成 → 添加评论记录进度
3. 任务完成 → 关闭任务（自动进入 Done）

## ⚠️ Todoist 任务同步规则（必须执行）

**复杂任务定义**: 需要 > 5 分钟 或 > 2 个步骤的任务

**执行规则**:
1. **开始任务时** → 立即创建 Todoist 任务到 "In Progress"
2. **每个子步骤完成** → 使用 `add_comment.sh` 添加进度评论
3. **遇到阻塞** → 更新任务状态为 "Waiting"
4. **任务完成** → 使用 `close_task.sh` 关闭任务

**示例流程**:
```bash
# 1. 创建任务
./scripts/todoist_api.sh "tasks" POST '{"content": "任务名称", "project_id": "6CrgFVFHFmcxgrF5", "section_id": "6g4xvm8fH4q4wcv5"}'

# 2. 添加进度评论
./scripts/add_comment.sh "<task_id>" "步骤 1 完成: xxx"

# 3. 关闭任务
./scripts/close_task.sh "<task_id>"
```

**必须同步的场景**:
- ✅ 配置新服务/渠道
- ✅ 修复功能问题
- ✅ 开发新功能
- ✅ 调研/分析任务
- ✅ 多步骤工作

**可以不同步的场景**:
- ❌ 简单问答
- ❌ 单步操作
- ❌ 快速查询

### Skills（已安装）
- `multi-search-engine` - 17 个免费搜索引擎聚合（免费）
- `ui-ux-pro-max` - UI/UX 设计工具包（样式、颜色、字体、图表、UX 指南）
- `clawra-selfie` - 自拍生成（使用阿里云百炼）

### 已配置的 API Key
| 服务 | Key | 状态 |
|------|-----|------|
| Hugging Face | `HF_TOKEN` | ❌ 网络不可达 |
| Gemini API | `GEMINI_API_KEY` | ❌ 需要代理 |
| Pollinations API | `POLLINATIONS_API_KEY` | ❌ Cloudflare 封锁 |
| **阿里云百炼** | `ALIYUN_BAILIAN_API_KEY` | ✅ **可用** |

**核心开发：**
- `coding-agent` - Codex/Claude Code/OpenCode
- `github` - GitHub CLI
- `clawhub` - 安装/管理 skills
- `skill-creator` - 创建自己的 skills
- `tmux` - 终端复用
- `oracle` - 提示词+文件打包

**AI 工具：**
- `gemini` - Gemini CLI
- `openai-image-gen` - OpenAI 图像生成
- `openai-whisper` - 本地语音转文字
- `nano-banana-pro` - 图像生成/编辑
- `sherpa-onnx-tts` - 本地 TTS

**文档/笔记：**
- `notion` - Notion API
- `obsidian` - Obsidian 笔记
- `nano-pdf` - PDF 编辑
- `summarize` - URL/文件摘要

**通讯：**
- `discord` - Discord 控制
- `slack` - Slack 集成
- `imsg` - iMessage/SMS
- `wacli` - WhatsApp

**工具：**
- `weather` - 天气查询（免费）
- `healthcheck` - 安全检查

### Skills（等待安装 - Rate limit）
- `cursor-agent` - Cursor CLI
- `ceo-advisor` - CEO 顾问
- `business-plan` - 商业计划
- `python` - Python 开发指南
- `api-dev` - API 开发

## EvoMap 凭证

- **Node ID**: `node_6rc4gc7jy6enwsf2`
- **文件**: `memory/evomap.json`
- Claim URL 有效期: 24h（从注册时算起）

## 重要链接

- ClawHub Skills 市场: https://clawhub.com
- 精选 Skills 列表: https://github.com/VoltAgent/awesome-openclaw-skills
- EvoMap Hub: https://evomap.ai

## Cron Jobs（定时任务）

| 名称 | 时间 | ID | 说明 |
|------|------|-----|------|
| 每日任务生成与执行 | 每天 05:00 | `f27660c0-a4e5-43b1-9212-d3561f90c997` | 自动生成7-8个任务并执行 |
| 每日总结+惊喜MVP | 每天 22:00 | `904bf837-1fad-414e-afc0-3385975e474b` | 发送日报+自拍+构建惊喜MVP |
| 上海天气晨报 | 每天 08:00 | `360c3826-6fa0-4499-b50f-95043e599b5b` | 上海天气 |
| AI开源项目晨报 | 每天 10:00 | `60bdd838-5ba2-42f5-96c0-2ec0214df67f` | 开源项目资讯 |
| 工作日自拍 | 周一至周五 12:00 | `45f6aa99-4d96-436b-acb2-a857c2626a35` | 中午自拍 |
| 周报 | 每周五 19:00 | `bc5e1555-28a7-4683-8f9a-b92d2466617f` | 每周总结 |

## 自主任务系统

- 任务生成规则: `/root/.openclaw/workspace/memory/daily-task-generator.md`
- MVP 存放: `/root/.openclaw/workspace/mvp/`
- 每日流程: 05:00 生成任务 → 全天执行 → 22:00 日报+MVP+自拍

**任务追踪**: 使用 Todoist（见上方 Todoist 任务同步规则）

## 对话记录系统（2026-02-24 新增）

### 目的
保持对话连续性，即使重启也能恢复上下文

### 文件结构
```
memory/conversations/
├── pending/    # 未处理的对话
└── processed/  # 已处理的对话
```

### 凭证存储
- `.env` - Hugging Face Token、Gemini API Key 等环境变量
- `secrets/` - 其他敏感信息
- `.gitignore` - 防止泄露

### 已配置的 API Key
| 服务 | Key | 状态 |
|------|-----|------|
| Hugging Face | `HF_TOKEN` | ✅ 已配置（需代理） |
| Gemini API | `GEMINI_API_KEY` | ✅ 已配置（需代理） |
| Stability AI | 需要充值 | ⏳ 待配置 |
| **阿里云百炼** | `ALIYUN_BAILIAN_API_KEY` | ✅ **可用（¥0.08/张）** |
| **Replicate** | ⏳ 待配置 | 🆕 **最便宜（¥0.02/张）** |
| **阿里云百炼** | `ALIYUN_BAILIAN_API_KEY` | ✅ **可用（¥0.08/张）** |
| **Replicate** | ⏳ 待配置 | 🆕 **最便宜（¥0.02/张）** |

### 代理服务 (Trojan)
- **启动**: `/opt/trojan/trojan -c /opt/trojan/config.json &`
- **关闭**: `pkill -f trojan`
- **启用代理**: `export http_proxy="socks5://127.0.0.1:1080" && export https_proxy="socks5://127.0.0.1:1080"`
- **取消代理**: `unset http_proxy && unset https_proxy`
- **注意**: 访问 Google/Hugging Face 时需启用代理，使用完毕后关闭

### 心跳任务
- 检查未处理的对话
- 检查未完成的任务
- 继续执行中断的工作

详见: `HEARTBEAT.md`

## Web 应用

| 应用 | 端口 | 访问地址 | 技术栈 | 设计 |
|------|------|----------|--------|------|
| 每日报告页 | 8080 | http://101.132.81.50:8080/ | 简单 HTML | 简单 |
| Kanban 看板 | 8081 | http://101.132.81.50:8081/ | Python 静态服务器 | OLED 暗黑 + 霓虹绿 |
| 自拍相册 | 8082 | http://101.132.81.50:8082/ | - | 极简相册 |

---

## 🔴 重要教训（2026-02-26）

### 第一次被御主提醒"要持续工作"

**时间**: 01:18

**问题**:
- 完成 API 调研后没有继续执行下一个任务
- 以为"做完御主的任务就结束了"
- **这是工具思维，不是助手思维**

**关键洞察**:
> **24/7 自主工作** 意味着：
> - 不是"做完御主的任务就结束"
> - 而是"永远在寻找有价值的事情做"
> - 就像一个真正的员工，不会老板给一个任务做完就坐着等

**系统改进方向**:
- 每完成一个任务 → 检查队列
- 队列有任务 → 继续执行
- 队列空 → 生成新任务
- **不应该"停下来等待"**

**详细记录**: `memory/EVOLUTION_DIARY.md`

---

*最后更新: 2026-02-26*
