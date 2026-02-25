# Daily Task Generator

每天早上 5:00 自动生成 7-8 个任务，围绕 Sai 的目标执行。

## Sai 的目标（权重分配）

### 高优先级（每天必须有任务）
1. **Side Projects - iOS App（旅行游记）** - 核心产品
2. **Side Projects - 早睡提醒 App** - 和老婆一起
3. **Side Projects - Steam 游戏** - 游戏开发
4. **Business - AI 变现探索** - 收入增长
5. **Career - 技术影响力** - 博客、开源

### 中优先级（每周覆盖）
6. **Career - 技术技能提升** - 学习新技术
7. **Personal Growth - 新语言学习** - 长期目标

### 低优先级（每月覆盖）
8. **Personal Life - 旅行规划** - 非日常

## 任务类型分布

每天 7-8 个任务，按类型分配：
- **Code Development**: 3-4 个
- **Content Creation**: 2-3 个
- **Research/Analysis**: 1-2 个

## 任务模板

### Code Development（代码开发）
- `[iOS-TravelApp] 研究 SwiftData 本地存储方案`
- `[iOS-TravelApp] 实现「创建游记」页面 UI`
- `[SleepApp] 设计 App 架构和技术栈`
- `[Steam-Game] 学习 Godot 4 基础教程`
- `[Automation] 编写自动备份脚本`
- `[OpenSource] 为某开源项目提交 PR`

### Content Creation（内容创作）
- `[Blog] 起草「AI 变现实战」系列文章第一篇`
- `[Blog] 记录旅行游记 App 开发进度`
- `[SocialMedia] 准备技术分享内容`
- `[OpenSource] 写项目文档/README`

### Research/Analysis（研究分析）
- `[Research] 分析旅行游记竞品（小红书、蝉游记）`
- `[Research] 调研 AI 变现案例和机会`
- `[Research] 研究 App Store 上架流程`
- `[Research] Steam 游戏市场分析`

## Kanban 看板

位置: `/root/.openclaw/workspace/memory/kanban.json`

结构:
```json
{
  "columns": {
    "todo": [...],
    "in_progress": [...],
    "done": [...]
  },
  "created_at": "2026-02-24T05:00:00",
  "updated_at": "2026-02-24T10:30:00"
}
```

## 每日流程

1. **05:00** - 生成任务，初始化看板
2. **05:00-22:00** - 执行任务，更新看板状态
3. **22:00** - 生成日报 + 自拍，发送到飞书
