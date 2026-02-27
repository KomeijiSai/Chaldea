# 🎨 云眠自拍生成系统 - 使用指南

**版本**: v1.0
**创建时间**: 2026-02-27
**适用对象**: 完全不需要手动配置的用户

---

## ✨ 特点

1. **完全预设参数**：云眠已经优化好所有参数，御主不需要改任何东西
2. **性能优化**：避免风扇狂转，平衡质量和性能
3. **简单易用**：只需要选择场景，其他都是自动的
4. **完全自动化**：支持定时任务，御主不需要手动操作

---

## 🚀 快速开始

### 安装完成后，御主只需要运行：

**1. 生成单个场景（完整流程）**
```bash
python3 scripts/generate_yunmian.py --scene work
```
- Turbo 快速预览：3 张（每张 2-3 秒）
- SDXL 高质量输出：1 张（40-50 秒）
- 总耗时：~60 秒
- **风扇：轻微响，不会狂转**

**2. 批量生成多个场景**
```bash
python3 scripts/batch_generate.py --scenes work,relax,celebrate
```
- 自动生成 3 个场景
- 每个场景：3 张 Turbo + 1 张 SDXL
- 总耗时：~3 分钟

---

## 📋 可用场景

| 场景名称 | 描述 | 适用时间 |
|---------|------|---------|
| work | 专注工作，办公室场景 | 早上/工作时间 |
| relax | 休闲放松，咖啡馆场景 | 下午茶 |
| celebrate | 庆祝时刻，开心场景 | 成就时刻 |
| night | 深夜静思，烛光场景 | 晚上 |
| daily | 日常生活，自然场景 | 任何时候 |
| meditation | 冥想静思，禅意场景 | 早晨/晚上 |

---

## 🎯 生成模式

### 模式 1: 完整流程（推荐）
```bash
python3 scripts/generate_yunmian.py --scene work
```
- Turbo 预览 3 张 + SDXL 高质量 1 张
- 耗时：~60 秒
- 质量：⭐⭐⭐⭐⭐

### 模式 2: 快速预览
```bash
python3 scripts/generate_yunmian.py --scene work --mode turbo
```
- 只生成 Turbo 预览 3 张
- 耗时：~15 秒
- 质量：⭐⭐⭐

### 模式 3: 高质量输出
```bash
python3 scripts/generate_yunmian.py --scene work --mode sdxl
```
- 只生成 SDXL 高质量 1 张
- 耗时：~45 秒
- 质量：⭐⭐⭐⭐⭐

---

## 🤖 完全自动化（定时任务）

### 设置定时任务

**方式 1: 使用 crontab（推荐）**
```bash
# 编辑 crontab
crontab -e

# 添加以下内容：
# 每天 8:00 生成工作场景
0 8 * * * cd ~/Projects/ImageGen && source venv/bin/activate && python3 scripts/generate_yunmian.py --scene work >> logs/cron.log 2>&1

# 每天 12:00 生成日常场景
0 12 * * * cd ~/Projects/ImageGen && source venv/bin/activate && python3 scripts/generate_yunmian.py --scene daily >> logs/cron.log 2>&1

# 每天 22:00 生成夜晚场景
0 22 * * * cd ~/Projects/ImageGen && source venv/bin/activate && python3 scripts/generate_yunmian.py --scene night >> logs/cron.log 2>&1
```

**方式 2: 使用 launchd（Mac 推荐）**
```bash
# 创建 plist 文件
cat > ~/Library/LaunchAgents/com.yunmian.daily.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.yunmian.daily</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/你的用户名/Projects/ImageGen/venv/bin/python3</string>
        <string>scripts/generate_yunmian.py</string>
        <string>--scene</string>
        <string>daily</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>12</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/Users/你的用户名/Projects/ImageGen/logs/launchd.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/你的用户名/Projects/ImageGen/logs/launchd_error.log</string>
</dict>
</plist>
EOF

# 加载任务
launchctl load ~/Library/LaunchAgents/com.yunmian.daily.plist
```

---

## 📁 输出文件

生成的图片会自动保存到：

```
output/
├── turbo/              # Turbo 快速预览
│   └── 2026-02-27/
│       ├── work_001.png
│       ├── work_002.png
│       └── work_003.png
└── sdxl/              # SDXL 高质量输出
    └── 2026-02-27/
        └── work_final.png
```

日志文件：
```
logs/
├── generate.log       # 生成日志
└── cron.log          # 定时任务日志
```

---

## 🔧 性能优化说明

### 云眠做的优化：

1. **适中的推理步数**
   - Turbo: 15 步（默认 20）
   - SDXL: 25 步（默认 30）
   - 平衡质量和性能

2. **分批生成 + 延迟**
   - 每张图片之间等待 5 秒
   - 让电脑有时间散热
   - 避免持续高负载

3. **内存优化**
   - 启用 attention slicing
   - 启用 VAE slicing
   - 减少内存占用

### 性能对比：

| 模式 | 步数 | 分辨率 | 时间 | CPU/GPU 负载 | 风扇声音 |
|------|------|--------|------|-------------|---------|
| Turbo | 15 | 1024 | 2-3秒 | 低 | 几乎不响 |
| SDXL（标准） | 25 | 1024 | 40-50秒 | 中 | 轻微 |
| SDXL（高质量） | 30 | 1024 | 60秒 | 高 | 明显 |

**云眠推荐**：使用**标准模式**（25 步），质量好，风扇不会狂转

---

## 📝 使用示例

### 示例 1: 每天自动生成

```bash
# 设置定时任务后，御主完全不需要操作
# 脚本会在指定时间自动运行

# 查看生成的图片
ls output/sdxl/2026-02-27/

# 查看日志
cat logs/generate.log
```

### 示例 2: 手动批量生成

```bash
# 周末批量生成多个场景
python3 scripts/batch_generate.py --scenes work,relax,celebrate,daily

# 耗时：~4 分钟
# 输出：12 张 Turbo + 4 张 SDXL
```

### 示例 3: 快速测试

```bash
# 快速生成一张看看效果
python3 scripts/generate_yunmian.py --scene daily --mode turbo

# 耗时：~15 秒
# 输出：3 张 Turbo 预览
```

---

## ⚙️ 常见问题

### Q1: 风扇声音还是有点大怎么办？

**A**: 云眠已经优化了，但如果还是觉得大，可以：
1. 确保电脑通风良好
2. 不要同时运行其他高负载程序
3. 使用快速模式（turbo）而不是完整流程

### Q2: 生成速度有点慢？

**A**: SDXL 本身比较慢，这是正常的：
- Turbo: 2-3 秒/张（很快）
- SDXL: 40-50 秒/张（标准）
- 如果要更快，只用 Turbo 模式

### Q3: 生成的图片质量不满意？

**A**: 云眠已经预设了最优参数：
- 如果质量不够，可以用 SDXL 高质量模式（步数 30）
- 如果想要更快，可以用 Turbo 模式
- 提示词已经优化好，不需要改

### Q4: 想修改场景描述？

**A**: 可以编辑 `scripts/generate_yunmian.py`：
```python
SCENES = {
    "work": {
        "prompt": "你的自定义描述",
        "description": "工作场景"
    },
}
```

---

## 🎯 总结

**御主只需要**：
1. 安装完成后，运行一次测试
2. 设置定时任务（可选）
3. 查看生成的图片

**云眠已经做了**：
1. ✅ 预设所有参数
2. ✅ 优化性能
3. ✅ 自动化流程
4. ✅ 组织输出文件

---

**创建时间**: 2026-02-27
**维护者**: 九公主云眠

*御主，一切都是自动的，你只需要享受生成的图片！💕*
