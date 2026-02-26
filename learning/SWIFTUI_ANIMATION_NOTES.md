# SwiftUI 动画效果学习笔记

**学习时间**: 2026-02-26  
**目的**: 掌握 SwiftUI 动画效果，为御主的 iOS 应用开发做准备  
**参考资源**: Hacking with Swift - SwiftUI by Example

---

## 📚 SwiftUI 动画基础

### 1. 基本动画（Basic Animation）

#### 最简单的动画
```swift
// 使用 .animation() 修饰符
struct ContentView: View {
    @State private var animationAmount = 1.0
    
    var body: some View {
        Button("Tap Me") {
            animationAmount += 1
        }
        .padding(50)
        .background(.red)
        .foregroundColor(.white)
        .clipShape(Circle())
        .scaleEffect(animationAmount)
        .animation(.default, value: animationAmount)
    }
}
```

#### 常用动画类型
```swift
// 1. 默认动画
.animation(.default, value: someValue)

// 2. 线性动画
.animation(.linear, value: someValue)

// 3. 缓入动画（开始慢，结束快）
.animation(.easeIn, value: someValue)

// 4. 缓出动画（开始快，结束慢）
.animation(.easeOut, value: someValue)

// 5. 缓入缓出动画
.animation(.easeInOut, value: someValue)

// 6. 自定义时长
.animation(.easeInOut(duration: 2), value: someValue)
```

---

### 2. 弹簧动画（Spring Animation）

#### 基本弹簧动画
```swift
// 使用 spring() 动画
.animation(.spring(), value: someValue)

// 自定义弹簧参数
.animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0), value: someValue)
```

#### 弹簧参数说明
- **response**: 弹簧的持续时间（秒）
- **dampingFraction**: 阻尼系数（0-1）
  - 0: 无阻尼（一直弹跳）
  - 0.5: 适度弹跳
  - 1: 无弹跳（平滑动画）
- **blendDuration**: 混合时间

#### 示例：弹跳按钮
```swift
struct BounceButton: View {
    @State private var isPressed = false
    
    var body: some View {
        Button("Bounce") {
            isPressed.toggle()
        }
        .padding()
        .background(isPressed ? Color.blue : Color.red)
        .foregroundColor(.white)
        .cornerRadius(10)
        .scaleEffect(isPressed ? 1.2 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.3), value: isPressed)
    }
}
```

---

### 3. 交互动画（Interactive Animation）

#### 使用动画绑定（Animation Binding）
```swift
struct InteractiveAnimation: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack {
            Slider(value: $scale, in: 0.5...2)
                .padding()
            
            Circle()
                .frame(width: 100, height: 100)
                .scaleEffect(scale)
                .animation(.interactiveSpring(), value: scale)
        }
    }
}
```

#### 手势动画
```swift
struct GestureAnimation: View {
    @State private var offset = CGSize.zero
    
    var body: some View {
        Circle()
            .frame(width: 100, height: 100)
            .foregroundColor(.blue)
            .offset(offset)
            .gesture(
                DragGesture()
                    .onChanged { gesture in
                        offset = gesture.translation
                    }
                    .onEnded { _ in
                        withAnimation(.spring()) {
                            offset = .zero
                        }
                    }
            )
    }
}
```

---

### 4. 视图过渡动画（Transition）

#### 基本过渡
```swift
struct TransitionView: View {
    @State private var showDetail = false
    
    var body: some View {
        VStack {
            Button("Toggle") {
                withAnimation {
                    showDetail.toggle()
                }
            }
            
            if showDetail {
                Rectangle()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.blue)
                    .transition(.slide)
            }
        }
    }
}
```

#### 常用过渡效果
```swift
// 1. 滑动
.transition(.slide)

// 2. 缩放
.transition(.scale)

// 3. 透明度
.transition(.opacity)

// 4. 组合过渡
.transition(.asymmetric(
    insertion: .scale,
    removal: .opacity
))

// 5. 自定义过渡
.transition(.asymmetric(
    insertion: .move(edge: .leading).combined(with: .opacity),
    removal: .move(edge: .trailing).combined(with: .scale)
))
```

---

### 5. 高级动画技巧

#### 延迟动画（Delayed Animation）
```swift
struct DelayedAnimation: View {
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 20) {
            ForEach(0..<5) { index in
                Circle()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.blue)
                    .scaleEffect(scale)
                    .animation(
                        .spring().delay(Double(index) * 0.1),
                        value: scale
                    )
            }
        }
        .onAppear {
            scale = 1.5
        }
    }
}
```

#### 重复动画（Repeating Animation）
```swift
struct RepeatingAnimation: View {
    @State private var isAnimating = false
    
    var body: some View {
        Circle()
            .frame(width: 100, height: 100)
            .foregroundColor(.blue)
            .scaleEffect(isAnimating ? 1.5 : 1.0)
            .animation(
                .easeInOut(duration: 1)
                .repeatForever(autoreverses: true),
                value: isAnimating
            )
            .onAppear {
                isAnimating = true
            }
    }
}
```

#### 关键帧动画（Keyframe Animation）
```swift
struct KeyframeAnimation: View {
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    
    var body: some View {
        VStack {
            Rectangle()
                .frame(width: 100, height: 100)
                .foregroundColor(.blue)
                .scaleEffect(scale)
                .rotationEffect(.degrees(rotation))
                .opacity(opacity)
            
            Button("Animate") {
                // 第一阶段
                withAnimation(.easeInOut(duration: 0.5)) {
                    scale = 1.5
                    rotation = 45
                }
                
                // 第二阶段（延迟）
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        scale = 0.5
                        opacity = 0.5
                    }
                }
                
                // 第三阶段（再延迟）
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    withAnimation(.spring()) {
                        scale = 1.0
                        rotation = 0
                        opacity = 1.0
                    }
                }
            }
        }
    }
}
```

---

## 🎨 实战案例

### 案例 1：加载动画（Loading Animation）
```swift
struct LoadingAnimation: View {
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<3) { index in
                Circle()
                    .frame(width: 12, height: 12)
                    .foregroundColor(.blue)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .animation(
                        .easeInOut(duration: 0.5)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}
```

### 案例 2：按钮按下效果（Button Press Effect）
```swift
struct PressableButton: View {
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // 按钮动作
        }) {
            Text("Press Me")
                .padding()
                .background(isPressed ? Color.blue : Color.red)
                .foregroundColor(.white)
                .cornerRadius(10)
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}
```

### 案例 3：卡片翻转（Card Flip）
```swift
struct CardFlip: View {
    @State private var isFlipped = false
    
    var body: some View {
        ZStack {
            // 背面
            Rectangle()
                .frame(width: 200, height: 300)
                .foregroundColor(.blue)
                .opacity(isFlipped ? 0 : 1)
            
            // 正面
            Rectangle()
                .frame(width: 200, height: 300)
                .foregroundColor(.red)
                .opacity(isFlipped ? 1 : 0)
        }
        .rotation3DEffect(
            .degrees(isFlipped ? 180 : 0),
            axis: (x: 0, y: 1, z: 0)
        )
        .animation(.easeInOut(duration: 0.5), value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
    }
}
```

### 案例 4：进度条动画（Progress Bar Animation）
```swift
struct ProgressBar: View {
    @State private var progress: CGFloat = 0
    
    var body: some View {
        VStack {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 20)
                        .foregroundColor(.gray)
                        .opacity(0.3)
                    
                    Rectangle()
                        .frame(width: min(progress * geometry.size.width, geometry.size.width), height: 20)
                        .foregroundColor(.blue)
                        .animation(.linear, value: progress)
                }
                .cornerRadius(10)
            }
            .frame(height: 20)
            
            Button("Start") {
                progress = 0
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                    if progress < 1.0 {
                        progress += 0.05
                    } else {
                        timer.invalidate()
                    }
                }
            }
        }
        .padding()
    }
}
```

---

## 📝 最佳实践

### 1. 性能优化
- ✅ 避免过度动画（影响性能）
- ✅ 使用 `withAnimation` 包裹状态改变
- ✅ 限制重复动画次数
- ✅ 在 `onAppear` 中启动动画

### 2. 用户体验
- ✅ 动画时长：0.2-0.5 秒（最佳体验）
- ✅ 使用弹簧动画（更自然）
- ✅ 避免突然的状态改变
- ✅ 提供视觉反馈

### 3. 可访问性
- ✅ 尊重系统动画设置
- ✅ 减少动画选项（for users with motion sensitivity）
```swift
@Environment(\.accessibilityReduceMotion) var reduceMotion

// 使用
.animation(reduceMotion ? .none : .default, value: someValue)
```

---

## 🎯 学习建议

### 初级阶段（1-2 周）
1. ✅ 掌握基本动画（.animation()）
2. ✅ 掌握弹簧动画（.spring()）
3. ✅ 掌握过渡动画（.transition()）
4. ✅ 完成加载动画案例

### 中级阶段（2-4 周）
1. ✅ 掌握手势动画
2. ✅ 掌握延迟和重复动画
3. ✅ 掌握关键帧动画
4. ✅ 完成卡片翻转、进度条案例

### 高级阶段（1-2 个月）
1. ✅ 自定义过渡效果
2. ✅ 复杂的交互动画
3. ✅ 性能优化
4. ✅ 创建动画库

---

## 📚 参考资源

### 官方资源
- **Apple SwiftUI Animation**: https://developer.apple.com/documentation/swiftui/animation
- **Human Interface Guidelines**: https://developer.apple.com/design/human-interface-guidelines/

### 教程
- **Hacking with Swift**: https://www.hackingwithswift.com/quick-start/swiftui
- **SwiftUI Lab**: https://swiftui-lab.com/
- **Ray Wenderlich**: https://www.raywenderlich.com/

---

**学习完成时间**: 2026-02-26  
**文档版本**: 1.0  
**维护者**: 九公主云眠

*御主，SwiftUI 动画很有趣呢！云眠会继续学习的~ 💪*
