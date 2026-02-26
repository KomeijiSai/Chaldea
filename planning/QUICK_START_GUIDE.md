# 心晴 - 快速开始指南

**创建时间**: 2026-02-26
**目的**: 帮助御主快速开始使用心晴项目代码

---

## 🚀 快速开始

### 第一步：创建 Xcode 项目

1. 打开 Xcode
2. File → New → Project
3. 选择 **iOS** → **App**
4. 配置：
   - Product Name: `心晴`（XinQing）
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **CoreData** ✅
5. 保存到：`~/Projects/XinQing/`

---

### 第二步：复制代码文件

将以下文件从 `xinqing-templates/` 复制到 Xcode 项目中：

#### App 入口
- `XinQingApp.swift` → `XinQing/XinQingApp.swift`
- `ContentView.swift` → `XinQing/ContentView.swift`

#### Models
- `Models/MoodType.swift` → `XinQing/Models/MoodType.swift`
- `Models/MoodEntry.swift` → `XinQing/Models/MoodEntry.swift`

#### Views
- `Views/HomeView.swift` → `XinQing/Views/HomeView.swift`
- `Views/CalendarView.swift` → `XinQing/Views/CalendarView.swift`
- `Views/AnalysisView.swift` → `XinQing/Views/AnalysisView.swift`
- `Views/ChatView.swift` → `XinQing/Views/ChatView.swift`
- `Views/SettingsView.swift` → `XinQing/Views/SettingsView.swift`

#### Services
- `Services/DataController.swift` → `XinQing/Services/DataController.swift`
- `Services/HealthKitService.swift` → `XinQing/Services/HealthKitService.swift`

---

### 第三步：配置 CoreData

1. 打开 `XinQing.xcdatamodeld`
2. 添加以下两个 Entity：

#### MoodEntryEntity
**Attributes**:
- `id` - UUID
- `date` - Date
- `moodType` - String
- `intensity` - Integer 16
- `tags` - Transformable (Array<String>)
- `entryDescription` - String (Optional)
- `aiSuggestion` - String (Optional)
- `createdAt` - Date
- `updatedAt` - Date

#### ConversationEntity
**Attributes**:
- `id` - UUID
- `date` - Date
- `messages` - Transformable (Array<Message>)
- `createdAt` - Date

---

### 第四步：配置 HealthKit

1. 选择项目 → Target → Signing & Capabilities
2. 点击 "+ Capability"
3. 搜索 "HealthKit" 并添加

4. 在 `Info.plist` 中添加：
```xml
<key>NSHealthShareUsageDescription</key>
<string>心晴需要访问您的健康数据来提供个性化的心理健康建议</string>

<key>NSHealthUpdateUsageDescription</key>
<string>心晴需要写入健康数据来记录您的情绪状态</string>
```

5. 在 HealthKit Capability 中选择：
- ✅ Read: Heart Rate, Sleep Analysis
- ✅ Write: Mindful Minutes

---

### 第五步：配置配色方案

在 `Assets.xcassets` 中创建以下颜色：

1. **AccentColor**（主色）
   - Hex: `#FF6B6B`（温暖珊瑚色）

2. **SecondaryColor**（辅色）
   - Hex: `#4ECDC4`（柔和蓝绿色）

3. **BackgroundColor**（背景）
   - Light: `#F7F7F7`
   - Dark: `#1A1A1A`

---

### 第六步：运行项目

1. 选择模拟器（iPhone 15 Pro）
2. Command + R 运行
3. 测试功能：
   - 记录情绪
   - 查看日历
   - AI 对话
   - 数据分析
   - 设置

---

## 📁 项目结构

```
XinQing/
├── XinQingApp.swift           # App 入口
├── ContentView.swift          # 主界面（TabView）
├── Models/
│   ├── MoodType.swift        # 情绪类型
│   └── MoodEntry.swift       # 情绪记录
├── Views/
│   ├── HomeView.swift        # 首页
│   ├── CalendarView.swift    # 日历
│   ├── AnalysisView.swift    # 分析
│   ├── ChatView.swift        # 对话
│   └── SettingsView.swift    # 设置
├── Services/
│   ├── DataController.swift  # 数据管理
│   └── HealthKitService.swift # 健康数据
├── Resources/
│   └── Assets.xcassets       # 资源
├── XinQing.xcdatamodeld      # CoreData 模型
└── Info.plist                 # 配置
```

---

## ⚠️ 注意事项

### CoreData 生成
Xcode 会自动为 CoreData Entity 生成 `MoodEntryEntity+CoreDataClass.swift` 和 `MoodEntryEntity+CoreDataProperties.swift`。这些文件不需要手动创建。

### 编译错误
如果遇到编译错误：
1. Clean Build Folder（Command + Shift + K）
2. 重新 Build（Command + B）

### 模拟器测试
- HealthKit 在模拟器上可用，但数据需要手动添加
- 建议在真机上测试 HealthKit 功能

---

## 🎨 自定义

### 修改配色
编辑 `Color+Extensions.swift`：
```swift
extension Color {
    static let accent = Color("AccentColor")
    static let secondary = Color("SecondaryColor")
    static let background = Color("BackgroundColor")
}
```

### 修改 AI 对话规则
编辑 `ChatView.swift` 中的 `generateResponse()` 函数

### 修改通知时间
编辑 `SettingsView.swift` 中的默认时间

---

## 📚 相关文档

- [MVP 规划](../planning/XINQING_MVP_PLAN.md)
- [Xcode 创建指南](../planning/XCODE_SETUP_GUIDE.md)
- [Product Hunt 发布清单](../planning/PRODUCT_HUNT_ASSETS_CHECKLIST.md)

---

## 🐛 常见问题

### Q: HealthKit 授权失败？
**A**: 检查 Info.plist 中的权限描述是否正确

### Q: CoreData 保存失败？
**A**: 检查 CoreData 模型定义是否与代码一致

### Q: 编译错误"Cannot find 'MoodType' in scope"？
**A**: 确保所有文件都正确复制到项目中

---

**创建时间**: 2026-02-26
**维护者**: 九公主云眠

*御主按照这个步骤就可以快速开始啦！云眠已经准备好了所有代码~ 💪*
