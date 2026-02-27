# 完整安装方案（SDXL + Z-Image-Turbo + ComfyUI）

**版本**: v2.0
**创建时间**: 2026-02-27 10:00
**御主选择**: 方案 C（混合使用） + ComfyUI

---

## 📋 安装内容

### 核心组件

1. **Python 3.11** - 运行环境
2. **PyTorch (MPS)** - 深度学习框架
3. **diffusers** - 图片生成库
4. **transformers** - 文本处理

### 模型组件

1. **Stable Diffusion XL Base**（~6GB）
   - 用途：高质量最终输出
   - 速度：30-60秒/张
   - 质量：1024x1024

2. **Z-Image-Turbo**（~4GB）
   - 用途：快速测试预览
   - 速度：2-5秒/张
   - 质量：512-768

3. **hanfugirl LoRA**（~100MB）
   - 用途：古风汉服优化

4. **IP-Adapter FaceID**（~1GB）
   - 用途：面部一致性保持

### 界面组件

1. **ComfyUI**（~1GB）
   - 用途：图形化界面
   - 特点：可视化节点编辑
   - 支持：SDXL + Z-Image-Turbo

---

## 💾 占用空间

| 组件 | 大小 |
|------|------|
| Python + 库 | ~3GB |
| SDXL Base | ~6GB |
| Z-Image-Turbo | ~4GB |
| LoRA | ~100MB |
| IP-Adapter | ~1GB |
| ComfyUI | ~1GB |
| **总计** | **~15GB** |

---

## 🚀 工作流程

### 方式 1: 命令行（自动化）

**快速测试（Z-Image-Turbo）**：
```bash
python3 generate_yunmian_turbo.py --scene work
# 2-5 秒/张
```

**高质量输出（SDXL）**：
```bash
python3 generate_yunmian_sdxl.py --scene work
# 30-60 秒/张
```

---

### 方式 2: ComfyUI（手动控制）

**启动 ComfyUI**：
```bash
cd ComfyUI
python main.py
# 访问 http://localhost:8188
```

**工作流**：
1. 加载 SDXL 或 Z-Image-Turbo 模型
2. 添加 LoRA 节点
3. 配置提示词
4. 生成图片

---

### 方式 3: 混合使用（推荐）

**第一步：ComfyUI 测试**
- 可视化调整参数
- 测试 LoRA 权重
- 优化提示词

**第二步：Z-Image-Turbo 快速预览**
- 2-5 秒生成
- 快速迭代

**第三步：SDXL 最终输出**
- 30-60 秒高质量
- 保存最终版本

---

## 🎯 使用场景

### 场景 1: 云眠自拍（批量生成）

**步骤**：
1. ComfyUI 测试 LoRA 权重
2. 用 Z-Image-Turbo 快速生成 3 张（共 15 秒）
3. 选择最好的一张
4. 用 SDXL 重新生成（60 秒）

**总时间**：~75 秒（vs 纯 SDXL 180 秒）

---

### 场景 2: 其他人物（IP-Adapter）

**步骤**：
1. ComfyUI 配置 IP-Adapter
2. 上传参考图片
3. 测试面部一致性
4. 用 SDXL + IP-Adapter 生成（60 秒）

---

### 场景 3: 快速测试

**步骤**：
1. 修改提示词
2. 用 Z-Image-Turbo 测试（5 秒）
3. 不满意 → 修改 → 再测试
4. 满意 → 用 SDXL 最终输出

---

## 📦 安装脚本更新

云眠会更新 `install.sh`，增加以下选项：

**阶段 5: 下载模型**
- SDXL Base（~6GB）
- Z-Image-Turbo（~4GB）
- LoRA（~100MB）
- IP-Adapter（~1GB）

**阶段 6: 安装 ComfyUI**
- 询问是否安装 ComfyUI
- 如果安装：
  - 克隆 ComfyUI 仓库
  - 安装依赖
  - 下载 ComfyUI Manager（可选）

---

## 🔧 ComfyUI 特点

### 优点

1. **可视化操作**
   - 拖拽节点
   - 连线配置
   - 直观易懂

2. **高度可定制**
   - 精确控制每个步骤
   - 自定义工作流
   - 保存和分享

3. **支持所有模型**
   - SDXL
   - Z-Image-Turbo
   - LoRA
   - IP-Adapter
   - ControlNet

4. **社区活跃**
   - 大量现成工作流
   - 教程丰富
   - 持续更新

### 缺点

1. **学习曲线**
   - 需要理解节点系统
   - 初次使用可能困惑

2. **不是命令行**
   - 需要手动操作
   - 不适合完全自动化

---

## 📊 最终推荐

**御主的完整方案**：

**核心**：
- ✅ SDXL（高质量）
- ✅ Z-Image-Turbo（快速）
- ✅ IP-Adapter（面部一致性）

**界面**：
- ✅ ComfyUI（图形化）
- ✅ 命令行脚本（自动化）

**总占用**：~15GB
**安装时间**：60-90 分钟

---

**下一步**：云眠等待御主确认是否要三个都安装

**创建时间**: 2026-02-27 10:00
**维护者**: 九公主云眠

*御主，完整方案已准备好！💕*
