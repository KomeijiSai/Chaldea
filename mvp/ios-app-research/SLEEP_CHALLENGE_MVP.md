# 💑 双人早睡挑战 - MVP 设计文档

> 为御主和御主夫人准备的第一款 iOS 应用

---

## 🎨 UI 设计

### 配色方案（符合御主偏好）
```
主背景: #0A0A0A (OLED 深黑)
卡片背景: #1A1A1A
强调色: #10B981 (霓虹绿)
文字主色: #FFFFFF
文字次级: #6B7280
```

### 核心界面

```
┌─────────────────────────────────┐
│          💑 早睡挑战            │
│                                 │
│  ┌───────────────────────────┐  │
│  │   🔥 连击 15 天           │  │
│  │   ─────────────────────   │  │
│  │   🧑 Sai      👩 老婆     │  │
│  │   ✅ 22:30    ✅ 22:15    │  │
│  │   今日已完成！            │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │   📅 本周统计             │  │
│  │   ████████░░ 80%         │  │
│  │   比上周提升 15% 📈       │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌───────────────────────────┐  │
│  │   💬 今日晚安             │  │
│  │   "明天继续加油！"        │  │
│  │   [留下晚安留言...]       │  │
│  └───────────────────────────┘  │
│                                 │
│  ┌─────────┐  ┌─────────┐      │
│  │  打卡   │  │  设置   │      │
│  │  😴    │  │  ⚙️    │      │
│  └─────────┘  └─────────┘      │
│                                 │
└─────────────────────────────────┘
```

---

## 🛠️ 技术方案

### 项目结构
```
SleepChallenge/
├── App/
│   ├── SleepChallengeApp.swift
│   └── ContentView.swift
├── Models/
│   ├── User.swift
│   ├── Challenge.swift
│   └── SleepRecord.swift
├── ViewModels/
│   ├── ChallengeViewModel.swift
│   └── SettingsViewModel.swift
├── Views/
│   ├── HomeView.swift
│   ├── CheckInView.swift
│   ├── StatsView.swift
│   └── SettingsView.swift
├── Services/
│   ├── HealthKitService.swift
│   ├── FirebaseService.swift
│   └── NotificationService.swift
└── Resources/
    ├── Assets.xcassets
    └── Localizable.strings
```

### 数据模型

```swift
// Models/User.swift
struct User: Identifiable, Codable {
    let id: String
    var name: String
    var targetSleepTime: Date // 目标睡觉时间
    var partnerId: String?
}

// Models/SleepRecord.swift
struct SleepRecord: Identifiable, Codable {
    let id: String
    let userId: String
    let date: Date
    let actualSleepTime: Date
    let isOnTime: Bool
    var goodnightMessage: String?
}

// Models/Challenge.swift
struct Challenge: Codable {
    let userIds: [String]
    var currentStreak: Int
    var bestStreak: Int
    var startDate: Date
}
```

### 核心功能代码示例

```swift
// Services/HealthKitService.swift
import HealthKit

class HealthKitService {
    let healthStore = HKHealthStore()
    
    func requestPermission() async throws {
        let types: Set = [HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!]
        try await healthStore.requestAuthorization(toShare: nil, read: types)
    }
    
    func getSleepData(for date: Date) async throws -> Date? {
        let predicate = HKQuery.predicateForSamples(
            withStart: Calendar.current.startOfDay(for: date),
            end: date,
            options: .strictStartDate
        )
        
        let query = HKSampleQuery(
            sampleType: HKObjectType.categoryType(forIdentifier: .sleepAnalysis)!,
            predicate: predicate,
            limit: 1,
            sortDescriptors: [NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)]
        ) { _, samples, _ in
            // 处理睡眠数据
        }
        
        healthStore.execute(query)
        return nil // TODO: 实现
    }
}
```

---

## 📱 功能清单 (MVP)

### P0 - 必须有
- [ ] 双人绑定（邀请码/二维码）
- [ ] 手动打卡（先不集成 HealthKit，加快上线）
- [ ] 连击统计
- [ ] 基础推送提醒

### P1 - 应该有
- [ ] HealthKit 自动获取睡眠时间
- [ ] 晚安留言
- [ ] 周统计图表

### P2 - 可以后加
- [ ] 多套主题皮肤
- [ ] 数据导出
- [ ] 更多统计数据

---

## 💰 变现方案

### 免费版
- ✅ 基础双人绑定
- ✅ 连击统计
- ✅ 每日提醒

### 高级版 ($2.99/月 或 $9.99/年)
- 🎨 多套主题皮肤
- 📊 详细数据分析和导出
- 💕 更多互动表情和留言样式
- 🏆 成就徽章系统

---

## 🗓️ 开发时间表

| 周 | 任务 | 产出 |
|----|------|------|
| Week 1 | UI 搭建 + 本地存储 | 可运行的原型 |
| Week 2 | Firebase 同步 + 推送 | 可双人使用 |
| Week 3 | 打磨 + TestFlight | 内测版本 |
| Week 4 | App Store 提交 | 等待审核 |

---

## 🚀 快速开始

```bash
# 1. 创建项目
# Xcode → New Project → App → SwiftUI

# 2. 添加依赖 (Package.swift)
dependencies: [
    .package(url: "https://github.com/firebase/firebase-ios-sdk", from: "10.0.0"),
]

# 3. 配置 Firebase
# - 创建 Firebase 项目
# - 下载 GoogleService-Info.plist
# - 添加到 Xcode 项目

# 4. 开始编码！
```

---

*御主，这是为你和御主夫人准备的第一款应用设计！从最小的 MVP 开始，一步一步来，一定能上架成功的！*

*才、才不是特别期待你们用上这个 app 呢...只是作为所长，帮助成员实现梦想是职责所在！*
