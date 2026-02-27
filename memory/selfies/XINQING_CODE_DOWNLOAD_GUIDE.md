# 心晴项目代码下载指南

**创建时间**: 2026-02-27 02:45
**目的**: 帮助御主获取心晴项目的所有代码

---

## 📂 代码位置

**服务器路径**: `/root/.openclaw/workspace/xinqing-templates/`

**GitHub 仓库**: https://github.com/KomeijiSai/Chaldea

**分支**: main

---

## 📥 获取代码的 3 种方式

### 方式 1: 从 GitHub 下载（推荐）⭐⭐⭐⭐⭐

```bash
# 1. 克隆仓库
cd ~/Projects
git clone https://github.com/KomeijiSai/Chaldea.git
cd Chaldea

# 2. 代码位置
# xinqing-templates/ 目录下
```

**或者直接下载 ZIP**：
```
https://github.com/KomeijiSai/Chaldea/archive/refs/heads/main.zip
```

---

### 方式 2: 从服务器下载

```bash
# 1. 下载整个目录
scp -r root@101.132.81.50:/root/.openclaw/workspace/xinqing-templates ~/Desktop/

# 2. 或者只下载代码文件
rsync -avz root@101.132.81.50:/root/.openclaw/workspace/xinqing-templates/ ~/Desktop/xinqing-templates/
```

---

### 方式 3: 云眠打包发送

云眠可以打包成 ZIP 文件，御主通过浏览器下载。

---

## 📋 文件清单

### App 入口（2 个文件）
```
xinqing-templates/
├── XinQingApp.swift         # App 入口
└── ContentView.swift        # 主界面（TabView）
```

### Models（2 个文件）
```
├── Models/
│   ├── MoodType.swift       # 情绪类型枚举
│   └── MoodEntry.swift      # 情绪记录模型
```

### Views（5 个文件）
```
├── Views/
│   ├── HomeView.swift       # 首页（情绪记录）
│   ├── CalendarView.swift   # 日历视图
│   ├── AnalysisView.swift   # 数据分析
│   ├── ChatView.swift       # AI 对话
│   └── SettingsView.swift   # 设置界面
```

### Services（2 个文件）
```
└── Services/
    ├── DataController.swift      # CoreData 管理
    └── HealthKitService.swift    # HealthKit 服务
```

**总计**: 11 个 Swift 文件，~3000 行代码

---

## 📚 文档位置

### 规划文档
```
planning/
├── XINQING_MVP_PLAN.md          # MVP 规划
├── XCODE_SETUP_GUIDE.md         # Xcode 创建指南
├── QUICK_START_GUIDE.md         # 快速开始
└── PRODUCT_HUNT_ASSETS_CHECKLIST.md  # Product Hunt 清单
```

### 下载方式
```bash
# 这些文档也在 GitHub 仓库中
# 克隆仓库后会自动包含

cd ~/Projects/Chaldea
ls planning/XINQING*.md
ls planning/XCODE*.md
ls planning/QUICK*.md
```

---

## 🚀 快速开始

### 第一步：下载代码
```bash
# 方式1: Git 克隆
cd ~/Projects
git clone https://github.com/KomeijiSai/Chaldea.git
cd Chaldea/xinqing-templates

# 方式2: 下载 ZIP
# 浏览器打开：https://github.com/KomeijiSai/Chaldea
# 点击 "Code" → "Download ZIP"
# 解压后找到 xinqing-templates/ 目录
```

### 第二步：创建 Xcode 项目
```bash
# 1. 打开 Xcode
# 2. File → New → Project
# 3. 选择 iOS → App
# 4. 配置：
#    - Product Name: 心晴 (XinQing)
#    - Interface: SwiftUI
#    - Language: Swift
#    - Storage: CoreData ✅
# 5. 保存到: ~/Projects/XinQing/
```

### 第三步：复制代码
```bash
# 复制文件到 Xcode 项目
cp -r ~/Projects/Chaldea/xinqing-templates/* ~/Projects/XinQing/XinQing/

# 或者手动拖拽到 Xcode 项目中
```

### 第四步：配置 CoreData
```
1. 打开 XinQing.xcdatamodeld
2. 添加 Entity（见 XCODE_SETUP_GUIDE.md）
3. 配置属性
```

### 第五步：运行
```bash
# Command + R
# 测试功能
```

---

## 📦 打包下载（云眠准备）

云眠可以创建一个打包文件，包含所有代码和文档：

```bash
# 在服务器上执行
cd /root/.openclaw/workspace
tar -czf xinqing-complete.tar.gz \
  xinqing-templates/ \
  planning/XINQING*.md \
  planning/XCODE*.md \
  planning/QUICK*.md \
  planning/PRODUCT_HUNT*.md

# 御主下载
scp root@101.132.81.50:/root/.openclaw/workspace/xinqing-complete.tar.gz ~/Desktop/
```

---

## 🔍 关于 Travel App

云眠没有创建过 Travel App 的代码。

可能的情况：
1. 之前讨论过但未实现
2. 御主记错了项目名称
3. 在其他地方

如果御主需要 Travel App，云眠可以：
- 根据御主的需求创建
- 参考心晴项目的结构

---

## ✅ 推荐流程

**最简单**：
1. 浏览器打开：https://github.com/KomeijiSai/Chaldea
2. 点击 "Code" → "Download ZIP"
3. 解压
4. 找到 xinqing-templates/ 目录
5. 按照 QUICK_START_GUIDE.md 操作

**或者**：
1. Git 克隆整个仓库
2. 找到需要的文件
3. 复制到 Xcode 项目

---

## 🆘 需要帮助？

如果御主需要：
1. 云眠打包代码并下载
2. 云眠通过其他方式发送代码
3. 云眠重新整理代码格式
4. 云眠创建其他项目的代码

随时告诉云眠！

---

**创建时间**: 2026-02-27 02:45
**维护者**: 九公主云眠

*御主，代码都在 GitHub 仓库里，可以直接下载！💕*
