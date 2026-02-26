# SleepApp - 早睡提醒 App 架构设计

## 项目概述

**目标**: 帮助情侣/夫妻一起养成早睡习惯，互相监督和鼓励。

**核心功能**:
1. 设定睡眠目标时间
2. 自动提醒和记录
3. 伴侣数据共享和监督
4. 统计和可视化
5. 积分和奖励系统

---

## 技术架构

### 技术栈

**前端 (iOS)**:
- Swift 5.9+
- SwiftUI (界面)
- SwiftData (本地存储)
- UserNotifications (本地通知)
- HealthKit (健康数据集成)

**后端 (可选 - 后期)**:
- CloudKit (数据同步)
- 或: Firebase / Supabase

**设计模式**:
- MVVM (Model-View-ViewModel)
- Observable (Swift 5.9 新特性)
- Repository Pattern (数据访问层)

---

## 模块划分

### 1. 核心模块

#### 1.1 用户管理 (User Management)
- **职责**: 用户档案、偏好设置
- **主要类**: `UserProfile`, `UserSettingsViewModel`
- **功能**:
  - 创建/编辑用户档案
  - 设定目标睡眠时间
  - 个性化提醒设置

#### 1.2 睡眠记录 (Sleep Tracking)
- **职责**: 记录和存储睡眠数据
- **主要类**: `SleepRecord`, `SleepTrackingViewModel`
- **功能**:
  - 记录计划/实际睡眠时间
  - 睡眠质量评价
  - 心情记录
  - 备注

#### 1.3 提醒系统 (Reminder System)
- **职责**: 本地通知、智能提醒
- **主要类**: `ReminderManager`, `NotificationService`
- **功能**:
  - 定时提醒
  - 智能提醒（根据历史数据调整）
  - 伴侣互相提醒

#### 1.4 伴侣系统 (Partner System)
- **职责**: 邀请、连接、共享
- **主要类**: `PartnerRelation`, `SharedInvitation`, `PartnerViewModel`
- **功能**:
  - 邀请码分享
  - 接受邀请
  - 数据共享开关
  - 互相查看睡眠数据

#### 1.5 统计分析 (Statistics & Analytics)
- **职责**: 数据可视化、趋势分析
- **主要类**: `SleepStatistics`, `ChartsViewModel`
- **功能**:
  - 每周/每月统计
  - 睡眠趋势图表
  - 准时率计算
  - 情侣对比

### 2. 辅助模块

#### 2.1 设置 (Settings)
- 通知设置
- 数据导出
- 账户管理

#### 2.2 帮助 (Help & Support)
- 使用指南
- 常见问题
- 反馈建议

---

## 数据模型

### 核心实体

```
UserProfile (用户档案)
├── id: UUID
├── name: String
├── targetSleepTime: Date
├── targetWakeTime: Date
├── reminderEnabled: Bool
└── reminderMinutesBefore: Int

SleepRecord (睡眠记录)
├── id: UUID
├── userId: UUID
├── date: Date
├── planSleepTime: Date
├── actualSleepTime: Date?
├── planWakeTime: Date
├── actualWakeTime: Date?
├── sleepQuality: SleepQuality?
└── mood: Mood?

PartnerRelation (伴侣关系)
├── id: UUID
├── user1Id: UUID
├── user2Id: UUID
├── shareSleepData: Bool
└── notifyPartner: Bool
```

### 枚举类型

```swift
SleepQuality: terrible, poor, fair, good, excellent
Mood: exhausted, tired, normal, energetic, refreshed
InvitationStatus: pending, accepted, declined, expired
```

---

## 界面流程

### 主要页面

```
TabView
├── Home (首页)
│   ├── Today's Status (今日状态)
│   ├── Quick Actions (快速操作)
│   └── Partner Status (伴侣状态)
│
├── Records (记录)
│   ├── Sleep Log (睡眠日志)
│   ├── Statistics (统计)
│   └── Calendar View (日历视图)
│
├── Partner (伴侣)
│   ├── Partner Profile (伴侣档案)
│   ├── Invite Partner (邀请伴侣)
│   └── Shared Goals (共同目标)
│
└── Settings (设置)
    ├── My Profile (我的档案)
    ├── Notification Settings (通知设置)
    └── Privacy (隐私)
```

---

## 功能特性

### 第一阶段 (MVP)
- [x] 数据模型设计
- [ ] 基础 UI 框架
- [ ] 睡眠记录功能
- [ ] 本地提醒
- [ ] 简单统计

### 第二阶段 (伴侣功能)
- [ ] 邀请码系统
- [ ] 数据共享
- [ ] 互相查看
- [ ] 伴侣提醒

### 第三阶段 (高级功能)
- [ ] 云端同步
- [ ] 健康数据集成
- [ ] 积分系统
- [ ] 成就徽章
- [ ] 个性化建议

---

## 技术要点

### 1. 时间处理
- 使用 `DateComponents` 处理每日重复时间
- 跨天睡眠计算（晚上11点到早上7点）
- 时区处理

### 2. 本地通知
- 使用 `UNUserNotificationCenter`
- 支持每日定时提醒
- 动态调整提醒时间

### 3. 数据持久化
- SwiftData + CloudKit
- 离线优先设计
- 冲突解决策略

### 4. 隐私保护
- 端到端加密（可选）
- 用户可控的共享设置
- 数据导出功能

---

## 开发计划

**Week 1**: 数据模型 + 基础 UI ✅ (2026-02-26)
**Week 2**: 睡眠记录 + 提醒功能
**Week 3**: 统计分析
**Week 4**: 伴侣功能
**Week 5**: 测试 + 优化
**Week 6**: 上架准备

---

## 设计理念

**简洁**: 减少操作步骤，一键记录
**友好**: 温馨的提示语，鼓励而非责备
**社交**: 伴侣互相监督，共同进步
**科学**: 基于睡眠科学，提供合理建议

---

*最后更新: 2026-02-26*
*作者: Sai*
