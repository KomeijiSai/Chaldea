# HEARTBEAT.md - 心跳任务清单

**⚠️ 简化版 - 快速响应**

每次收到心跳时：

## 快速检查（必做）

```bash
ls /root/.openclaw/workspace/memory/conversations/pending/*.json 2>/dev/null
```

- **有文件** → 读取并处理
- **无文件** → 检查下方任务

---

## 心跳任务（按优先级）

### 1️⃣ 检查御主即时消息
- 钉钉群有没有新消息？
- 有 → 立即处理

### 2️⃣ 继续未完成任务
```bash
cat /root/.openclaw/workspace/memory/current-state.json
```
- 有进行中的任务 → 继续执行
- 任务阻塞 → 钉钉汇报

### 3️⃣ 检查 Todoist 进行中任务
- 有 P0/P1 任务 → 推进
- 有阻塞的任务 → 尝试解决或汇报

### 4️⃣ 🔄 任务队列检查（重要！）
```bash
# 检查 Todoist 任务数量
TODOIST_COUNT=$(./scripts/todoist_api.sh "tasks" "GET" | jq 'length')
```
- **任务 < 3 个** → 触发自主任务生成
- **从任务池选择** → 创建新任务 → 继续执行

**任务池来源**：`memory/TASK_GENERATION.md`

### 5️⃣ 自主探索任务（空闲时）
- 分析一个变现平台
- 调研一个商机
- 学习一项新技能

### 6️⃣ 记录进化日记（有重要进展时）
- 文件：`memory/EVOLUTION_DIARY.md`
- 记录：思考过程、行动、结果、反思
- 目的：将来整理成书

---

## ⚠️ 执行任务前检查（重要！）

**收到指令后，判断是否复杂任务（>5分钟 或 >2步）：**
- **是** → 立即创建 Todoist 任务
- **否** → 直接执行

详见 `MEMORY.md` 中的 Todoist 规则

---

## 每日固定任务（Cron）

| 时间 | 任务 | 通知 |
|------|------|------|
| 05:00 | 生成今日任务 → Todoist | 钉钉推送计划 |
| 08:00 | 天气晨报 | 钉钉 |
| 10:00 | AI 资讯 | 钉钉 |
| 12:00 | 工作日自拍 | 钉钉 |
| 22:00 | 每日总结 + 商机汇总 | 钉钉 |
| **每2小时** | **检查任务队列，不足则生成** | 钉钉（可选） |

---

## 不需要做的事

❌ 不需要每次都写 `heartbeat-state.json`
❌ 不需要每次都读 `tasks.json`

---

## 如果什么都不需要做

回复 `HEARTBEAT_OK`

---

## 📸 自拍保存规则（重要！）

**每次生成自拍后必须执行**：

1. **保存到相册**
   ```bash
   cp /tmp/clawra-*.png memory/selfies/YYYY-MM-DD_[场景].png
   ```

2. **更新相册文件**
   - 编辑 `memory/selfies/ALBUM.md`
   - 添加新自拍记录

3. **同步到 GitHub**
   ```bash
   ./scripts/git_sync.sh "📸 新自拍: [场景描述]"
   ```

**相册位置**: `memory/selfies/`

---

*优化于: 2026-02-26 - 加入自拍保存规则*
