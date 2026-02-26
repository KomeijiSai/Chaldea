# 双人早睡挑战 - 登录界面设计

**设计日期**: 2026-02-25
**版本**: MVP v1.0

---

## 设计原则

• 简洁 - 最少输入项
• 快速 - 一键开始
• 温馨 - 传达"一起早睡"的陪伴感

---

## 界面布局

### 启动页
```
┌─────────────────┐
│                 │
│    🌙           │
│                 │
│   早睡挑战      │
│                 │
│  一起养成好习惯  │
│                 │
│  [开始挑战] 按钮 │
│                 │
└─────────────────┘
```

### 登录页
```
┌─────────────────┐
│      ← 返回     │
│                 │
│      🌙         │
│                 │
│   输入昵称      │
│  ┌───────────┐  │
│  │ 你的名字  │  │
│  └───────────┘  │
│                 │
│   手机号(可选)  │
│  ┌───────────┐  │
│  │ +86       │  │
│  └───────────┘  │
│                 │
│  [开始] 按钮    │
│                 │
│  微信登录 按钮  │
│                 │
└─────────────────┘
```

### 配对页
```
┌─────────────────┐
│                 │
│   邀请你的伙伴  │
│                 │
│  ┌───────────┐  │
│  │ 配对码    │  │
│  │  ABC123   │  │
│  └───────────┘  │
│                 │
│  [复制] [分享]  │
│                 │
│      或者       │
│                 │
│  输入对方配对码 │
│  ┌───────────┐  │
│  │           │  │
│  └───────────┘  │
│                 │
│  [确认配对]     │
│                 │
└─────────────────┘
```

---

## 颜色方案

• 主色：深蓝色 #1E3A5F（夜晚）
• 强调色：金色 #FFD700（星星）
• 背景：渐变 #0F1C2E → #1E3A5F
• 文字：白色 #FFFFFF

---

## SwiftUI 代码片段

### 启动页
```swift
struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🌙")
                .font(.system(size: 80))
            
            Text("早睡挑战")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("一起养成好习惯")
                .foregroundColor(.gray)
            
            Button("开始挑战") {
                // 跳转到登录
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
```

### 登录页
```swift
struct LoginView: View {
    @State private var nickname = ""
    @State private var phone = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("🌙")
                .font(.system(size: 60))
            
            TextField("你的名字", text: $nickname)
                .textFieldStyle(.roundedBorder)
            
            TextField("手机号(可选)", text: $phone)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.phonePad)
            
            Button("开始") {
                // 保存用户信息
            }
            .buttonStyle(.borderedProminent)
            
            Button("微信登录") {
                // 微信授权
            }
        }
        .padding()
    }
}
```

---

## 下一步开发

1. [ ] 创建 Xcode 项目
2. [ ] 实现启动页
3. [ ] 实现登录逻辑
4. [ ] 实现配对功能
5. [ ] 连接后端 API

---

*设计完成: 2026-02-25 00:10*
