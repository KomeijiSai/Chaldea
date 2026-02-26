# SwiftUI 基础组件研究

**研究日期**: 2026-02-25
**目的**: 为双人早睡挑战应用准备技术基础

---

## SwiftUI 核心概念

### 什么是 SwiftUI？
- Apple 在 2019 年推出的声明式 UI 框架
- 用于构建 iOS、macOS、watchOS、tvOS 应用
- 代码量比 UIKit 少 50%+

### SwiftUI vs UIKit
| 特性 | SwiftUI | UIKit |
|------|---------|-------|
| 范式 | 声明式 | 命令式 |
| 代码量 | 少 | 多 |
| 预览 | 实时 | 需要运行 |
| 学习曲线 | 平缓 | 陡峭 |

---

## 基础组件清单

### 1. 文本组件
- `Text` - 静态文本
- `Label` - 文本 + 图标
- `TextField` - 输入框
- `SecureField` - 密码输入

### 2. 布局组件
- `VStack` - 垂直排列
- `HStack` - 水平排列
- `ZStack` - 层叠
- `List` - 列表
- `Form` - 表单
- `Group` - 分组

### 3. 交互组件
- `Button` - 按钮
- `Toggle` - 开关
- `Slider` - 滑块
- `Stepper` - 步进器
- `Picker` - 选择器

### 4. 导航组件
- `NavigationStack` - 导航栈
- `NavigationLink` - 导航链接
- `TabView` - 标签页
- `Sheet` - 弹出视图

### 5. 状态管理
- `@State` - 本地状态
- `@Binding` - 双向绑定
- `@ObservedObject` - 观察对象
- `@EnvironmentObject` - 环境对象
- `@Published` - 发布属性

---

## 双人早睡挑战应用所需组件

### 登录界面
```
- VStack (垂直布局)
  - Image (Logo)
  - TextField (用户名)
  - SecureField (密码)
  - Button (登录)
  - NavigationLink (注册)
```

### 主界面
```
- TabView (标签页)
  - 今日挑战
  - 历史记录
  - 设置
```

### 挑战卡片
```
- VStack
  - Text (对方昵称)
  - Text (对方状态)
  - Image (状态图标)
  - Button (我已就寝)
```

---

## 状态管理方案

### 用户数据
```swift
class UserModel: ObservableObject {
    @Published var username: String
    @Published var partnerId: String?
    @Published var bedtime: Date?
    @Published var streak: Int
}
```

### 挑战数据
```swift
struct Challenge: Identifiable {
    let id: UUID
    let date: Date
    let userStatus: Bool
    let partnerStatus: Bool
    let completedAt: Date?
}
```

---

## 下一步

1. [ ] 设计登录界面原型
2. [ ] 搭建 Xcode 项目
3. [ ] 实现用户注册/登录
4. [ ] 实现双人配对功能
5. [ ] 实现就寝打卡功能

---

## 参考资源

- [SwiftUI by Example](https://www.hackingwithswift.com/quick-start/swiftui)
- [Apple SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftUI Tutorials](https://developer.apple.com/tutorials/swiftui)

---

*研究完成时间: 2026-02-25 23:45*
