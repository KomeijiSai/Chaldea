# 外部任务系统使用指南

## 概述

外部任务系统允许其他 agent 或御主通过 GitHub 向云眠追加任务。

## 文件位置

- **任务文件**: `/external-tasks.json`
- **同步脚本**: `/scripts/sync_external_tasks.sh`
- **完成脚本**: `/scripts/complete_external_task.sh`

## 添加任务（其他 Agent 或御主）

### 方式 1: 直接编辑 JSON

1. 打开 `external-tasks.json`
2. 在 `tasks` 数组中添加新任务：

```json
{
  "id": "ext_003",
  "source": "manual",
  "priority": 2,
  "content": "测试外部任务系统",
  "description": "验证外部任务是否能正常同步",
  "labels": ["test", "system"],
  "createdAt": "2026-02-26T12:00:00+08:00",
  "createdBy": "御主",
  "status": "pending",
  "todoistId": null,
  "completedAt": null,
  "result": null
}
```

3. 提交推送到 GitHub：
```bash
git add external-tasks.json
git commit -m "➕ 新增外部任务"
git push origin main
```

### 方式 2: 使用 jq 命令

```bash
# 添加新任务
jq ".tasks += [{
  \"id\": \"ext_004\",
  \"source\": \"coding-agent\",
  \"priority\": 1,
  \"content\": \"修复登录 bug\",
  \"description\": \"用户反馈登录失败\",
  \"labels\": [\"bug\", \"urgent\"],
  \"createdAt\": \"$(date -Iseconds)\",
  \"createdBy\": \"coding-agent\",
  \"status\": \"pending\",
  \"todoistId\": null,
  \"completedAt\": null,
  \"result\": null
}]" external-tasks.json > external-tasks.json.tmp
mv external-tasks.json.tmp external-tasks.json

# 提交推送
git add external-tasks.json
git commit -m "➕ 新增外部任务"
git push origin main
```

## 字段说明

| 字段 | 必填 | 说明 |
|------|------|------|
| `id` | ✅ | 唯一标识，格式：`ext_XXX` |
| `source` | ✅ | 来源（coding-agent, manual, etc） |
| `priority` | ✅ | 优先级（1-4，1最高） |
| `content` | ✅ | 任务标题 |
| `description` | ❌ | 详细描述 |
| `labels` | ❌ | 标签数组 |
| `createdAt` | ✅ | 创建时间（ISO 8601） |
| `createdBy` | ✅ | 创建者 |
| `status` | ✅ | 状态：pending/processing/completed/failed |
| `todoistId` | ❌ | Todoist ID（系统自动填充） |
| `completedAt` | ❌ | 完成时间（系统自动填充） |
| `result` | ❌ | 执行结果（系统自动填充） |

## 优先级映射

```
1 → P0 (御主即时指令级别，立即执行)
2 → P1 (御主项目级别)
3 → P2 (变现探索级别)
4 → P3 (自我优化级别)
```

## 云眠的处理流程

### 心跳检查（每 5 分钟）

1. **拉取最新代码**
   ```bash
   git pull origin main
   ```

2. **检查外部任务**
   ```bash
   ./scripts/sync_external_tasks.sh
   ```

3. **同步到 Todoist**
   - 为每个 `pending` 任务创建 Todoist 任务
   - 更新 `todoistId` 和 `status: "processing"`
   - 提交推送到 GitHub

### 任务执行

1. 按优先级执行任务
2. 完成后调用 `close_task.sh`
3. 自动更新外部任务状态为 `completed`
4. 推送到 GitHub

## 查询任务状态

```bash
# 查看所有待处理任务
jq '.tasks[] | select(.status == "pending")' external-tasks.json

# 查看所有进行中任务
jq '.tasks[] | select(.status == "processing")' external-tasks.json

# 查看已完成任务
jq '.tasks[] | select(.status == "completed")' external-tasks.json
```

## 钉钉通知

外部任务会特殊标注：

```
🤖 [外部/来源] 任务标题

📋 任务描述

⚠️ 优先级: PX
🏷️ 标签: tag1, tag2

开始执行...
```

## 示例场景

### 场景 1: Coding Agent 发现 Bug

```bash
# coding-agent 添加任务
jq ".tasks += [{
  \"id\": \"ext_005\",
  \"source\": \"coding-agent\",
  \"priority\": 1,
  \"content\": \"紧急修复: iOS 应用崩溃\",
  \"description\": \"启动时崩溃，影响所有用户\",
  \"labels\": [\"bug\", \"ios\", \"critical\"],
  \"createdAt\": \"$(date -Iseconds)\",
  \"createdBy\": \"coding-agent\",
  \"status\": \"pending\",
  \"todoistId\": null,
  \"completedAt\": null,
  \"result\": null
}]" external-tasks.json > external-tasks.json.tmp
mv external-tasks.json.tmp external-tasks.json
git commit -am "🚨 紧急任务: iOS 应用崩溃"
git push origin main
```

云眠会在下次心跳时（最多 5 分钟）检测到并立即执行（P0）。

### 场景 2: 御主手动添加任务

御主可以直接编辑 `external-tasks.json`，添加任务后推送到 GitHub。

### 场景 3: Healthcheck Agent 定期检查

```bash
# healthcheck-agent 定期添加维护任务
jq ".tasks += [{
  \"id\": \"ext_006\",
  \"source\": \"healthcheck-agent\",
  \"priority\": 3,
  \"content\": \"清理服务器临时文件\",
  \"description\": \"磁盘使用率 75%，需要清理\",
  \"labels\": [\"maintenance\"],
  \"createdAt\": \"$(date -Iseconds)\",
  \"createdBy\": \"healthcheck-agent\",
  \"status\": \"pending\",
  \"todoistId\": null,
  \"completedAt\": null,
  \"result\": null
}]" external-tasks.json > external-tasks.json.tmp
mv external-tasks.json.tmp external-tasks.json
git commit -am "🔧 维护任务: 清理临时文件"
git push origin main
```

## 注意事项

1. **ID 唯一性**: 确保每个任务的 `id` 唯一
2. **时间格式**: 使用 ISO 8601 格式（`date -Iseconds`）
3. **优先级**: 合理设置优先级，避免滥用 P0
4. **网络问题**: 如果推送失败，下次心跳会重试
5. **冲突处理**: 如果同时修改，以 GitHub 版本为准

---

*云眠的外部任务系统 - 让协作更简单！*
