# 双人早睡挑战 - 技术架构

**设计日期**: 2026-02-25
**版本**: MVP v1.0

---

## 系统架构

```
┌─────────────┐
│  iOS App    │
│  (SwiftUI)  │
└──────┬──────┘
       │
       │ HTTPS
       │
┌──────▼──────┐
│   Backend   │
│  (Node.js)  │
└──────┬──────┘
       │
       ├──────► Firebase Auth
       │        (用户认证)
       │
       ├──────► Firestore
       │        (数据库)
       │
       └──────► FCM
                (推送通知)
```

---

## 技术选型

### 前端 (iOS)
• Swift 5.9
• SwiftUI
• iOS 16+
• Combine (响应式)
• URLSession (网络)

### 后端
• **方案 1**: Firebase (推荐)
  - 快速开发
  - 免费额度充足
  - 实时同步

• **方案 2**: Node.js + MongoDB
  - 更灵活
  - 可控性强
  - 需要服务器

### 推送通知
• Firebase Cloud Messaging (FCM)
• UserNotifications (iOS 本地)

---

## 数据库设计

### Users 集合
```json
{
  "id": "user_abc123",
  "nickname": "小红",
  "phone": "+86138****1234",
  "partnerId": "user_xyz789",
  "pairCode": "ABC123",
  "targetBedtime": "22:30",
  "createdAt": "2026-02-25T00:00:00Z"
}
```

### Challenges 集合
```json
{
  "id": "challenge_001",
  "date": "2026-02-25",
  "userId": "user_abc123",
  "bedtime": "2026-02-25T14:30:00Z",
  "success": true,
  "createdAt": "2026-02-25T14:30:00Z"
}
```

### Streaks 集合
```json
{
  "userId": "user_abc123",
  "currentStreak": 7,
  "longestStreak": 15,
  "lastSuccessDate": "2026-02-25"
}
```

---

## API 设计

### 用户相关
```
POST   /api/users/register      # 注册
POST   /api/users/login         # 登录
GET    /api/users/:id           # 获取用户信息
PUT    /api/users/:id           # 更新用户信息
POST   /api/users/pair          # 配对
```

### 挑战相关
```
POST   /api/challenges          # 创建今日挑战
GET    /api/challenges/today    # 获取今日挑战
GET    /api/challenges/history  # 获取历史记录
PUT    /api/challenges/:id      # 更新打卡状态
```

### 通知相关
```
POST   /api/notifications/token # 注册推送Token
POST   /api/notifications/send  # 发送通知
```

---

## Firebase 规则

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
    }
    
    match /challenges/{challengeId} {
      allow read, write: if request.auth.uid == resource.data.userId;
    }
  }
}
```

---

## 推送通知流程

```
1. 用户 A 点击"我已就寝"
2. App 调用 API 记录打卡时间
3. 后端检查是否双方都已打卡
4. 如果都打卡 → 发送成功通知
5. 如果超时 → 发送失败通知
```

### 通知内容
```json
{
  "title": "🌙 早睡挑战",
  "body": "小红已就寝，等你哦！",
  "data": {
    "type": "partner_checkin",
    "userId": "user_abc123"
  }
}
```

---

## 开发计划

### 第一周：核心功能
• 用户注册/登录
• 配对功能
• 今日挑战页面
• 打卡功能

### 第二周：完善功能
• 历史记录
• 成就系统
• 推送通知
• 设置页面

### 第三周：优化发布
• UI 美化
• 性能优化
• Bug 修复
• App Store 准备

---

## 成本估算

### Firebase 免费额度
• 认证: 10,000 次/月
• 数据库: 50,000 次读取/天
• 存储: 1GB
• 推送: 无限制

### MVP 阶段
• 完全免费
• 可支撑 1000+ 用户

---

*架构设计完成: 2026-02-25 00:20*
