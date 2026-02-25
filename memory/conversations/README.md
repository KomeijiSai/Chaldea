# 对话记录系统设计

## 文件结构

```
memory/conversations/
├── pending/           # 未处理的对话需求
│   └── {message_id}.json
└── processed/         # 已处理的需求记录
    └── {message_id}.json
```

## JSON 格式（精简版）

**不保存原始对话，只保存提炼后的需求：**

```json
{
  "id": "om_xxx",
  "timestamp": "2026-02-24T10:30:00Z",
  "need": "用户需要什么（一句话概括）",
  "action": "采取的行动（已完成/待执行）",
  "result": "结果摘要",
  "status": "completed|pending|failed"
}
```

## 示例

```json
{
  "id": "om_100b56d",
  "timestamp": "2026-02-24T15:30:00Z",
  "need": "创建对话持久化系统，记录需求而非原始对话",
  "action": "创建 conversations/ 目录结构 + 更新 HEARTBEAT.md",
  "result": "系统已建立，支持重启恢复",
  "status": "completed"
}
```

## 工作流程

### 1. 接收消息时
- 理解用户需求
- 提炼为精简格式保存到 `pending/`
- 执行任务
- 更新 result 和 status，移动到 `processed/`

### 2. 重启时
- 扫描 `pending/` 中未完成的需求
- 继续执行并完成

### 3. 心跳检查
- 检查 `pending/` 目录
- 检查是否有 `status: "pending"` 的任务
