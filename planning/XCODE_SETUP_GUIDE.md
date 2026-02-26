# 心晴项目 - Xcode 项目创建指南

**创建时间**: 2026-02-26  
**目的**: 帮助御主快速创建 Xcode 项目并配置必要权限

---

## 📱 项目创建步骤

### 第一步：创建项目
1. 打开 Xcode
2. File → New → Project
3. 选择 **iOS** → **App**
4. 点击 Next

### 第二步：配置项目信息
- **Product Name**: 心晴 (XinQing)
- **Team**: 选择你的 Apple ID
- **Organization Identifier**: com.yourname.xinqing
- **Bundle Identifier**: com.yourname.xinqing
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: **CoreData** ✅（勾选）
- **Include Tests**: ✅（勾选）

### 第三步：选择保存位置
- 建议路径: `~/Projects/XinQing/`
- 点击 Create

---

## ⚙️ 配置 HealthKit 权限

### 1. 添加 HealthKit Capability
1. 选择项目 → Target → Signing & Capabilities
2. 点击 "+ Capability"
3. 搜索 "HealthKit"
4. 双击添加

### 2. 配置 Info.plist
在 `Info.plist` 中添加以下权限描述：

```xml
<key>NSHealthShareUsageDescription</key>
<string>心晴需要访问您的健康数据来提供个性化的心理健康建议</string>

<key>NSHealthUpdateUsageDescription</key>
<string>心晴需要写入健康数据来记录您的情绪状态</string>
```

### 3. 选择健康数据类型
在 HealthKit Capability 中：
- ✅ Read: Heart Rate, Sleep Analysis
- ✅ Write: Mindful Minutes

---

## 🏗️ 项目结构

```
XinQing/
├── XinQingApp.swift          # App 入口
├── ContentView.swift          # 主界面
├── Models/                    # 数据模型
│   ├── MoodEntry.swift
│   ├── MoodType.swift
│   └── Conversation.swift
├── Views/                     # 视图
│   ├── HomeView.swift        # 首页
│   ├── CalendarView.swift    # 日历
│   ├── AnalysisView.swift    # 分析
│   ├── ChatView.swift        # AI 对话
│   └── SettingsView.swift    # 设置
├── ViewModels/                # 视图模型
│   ├── MoodViewModel.swift
│   └── ChatViewModel.swift
├── Services/                  # 服务
│   ├── HealthKitService.swift
│   └── AIService.swift
├── Extensions/                # 扩展
│   ├── Date+Extensions.swift
│   └── Color+Extensions.swift
├── Resources/                 # 资源
│   └── Assets.xcassets
├── XinQing.xcdatamodeld      # CoreData 模型
└── Info.plist                 # 配置文件
```

---

## 📝 CoreData 模型定义

### 打开 CoreData 模型编辑器
1. 打开 `XinQing.xcdatamodeld`
2. 点击 "Add Entity"

### 创建 MoodEntry 实体
**Entity Name**: MoodEntry

**Attributes**:
- `id` - UUID
- `date` - Date
- `moodType` - String
- `intensity` - Integer 16
- `tags` - Transformable (Array<String>)
- `description` - String (Optional)
- `aiSuggestion` - String (Optional)
- `createdAt` - Date
- `updatedAt` - Date

### 创建 Conversation 实体
**Entity Name**: Conversation

**Attributes**:
- `id` - UUID
- `date` - Date
- `messages` - Transformable (Array<Message>)
- `createdAt` - Date

---

## 🎨 配色方案

### 定义颜色（在 Assets.xcassets 中）

1. **Primary（主色）**
   - Color Name: `AccentColor`
   - Hex: `#FF6B6B`（温暖的珊瑚色）

2. **Secondary（辅色）**
   - Color Name: `SecondaryColor`
   - Hex: `#4ECDC4`（柔和的蓝绿色）

3. **Background（背景）**
   - Light Mode: `#F7F7F7`
   - Dark Mode: `#1A1A1A`

### 代码中使用

```swift
extension Color {
    static let accent = Color("AccentColor")
    static let secondary = Color("SecondaryColor")
    static let background = Color("BackgroundColor")
}
```

---

## 🔧 安装依赖（可选）

### 使用 Swift Package Manager

#### 1. Charts（图表库）
```
File → Add Packages → 
https://github.com/danielgindi/Charts.git
```

#### 2. Lottie（动画库）
```
File → Add Packages → 
https://github.com/airbnb/lottie-ios.git
```

---

## ✅ 验证项目创建

### 检查清单
- [ ] 项目创建成功
- [ ] HealthKit Capability 已添加
- [ ] Info.plist 权限已配置
- [ ] CoreData 模型已定义
- [ ] 项目结构已创建
- [ ] 配色方案已定义

### 运行测试
1. 选择模拟器（iPhone 15 Pro）
2. Command + R 运行
3. 应该能看到空白的 ContentView

---

## 📚 相关文档

- [心晴 MVP 规划](../planning/XINQING_MVP_PLAN.md)
- [SwiftUI 动画笔记](../learning/SWIFTUI_ANIMATION_NOTES.md)
- [iOS 健康应用市场调研](../research/IOS_HEALTH_APP_RESEARCH.md)

---

**创建时间**: 2026-02-26  
**维护者**: 九公主云眠

*御主按照这个步骤创建项目就好啦！云眠已经准备好下一步的代码了~ 💪*
