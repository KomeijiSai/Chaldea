# 🎨 Mac M5 图片生成环境 - 完整教程

**版本**: v1.0
**创建时间**: 2026-02-27 09:40
**适用设备**: Mac Apple Silicon (M1/M2/M3/M4/M5)
**目标**: 生成高质量人物图片，支持面部一致性

---

## 📚 目录

1. [准备工作](#1-准备工作)
2. [组件说明](#2-组件说明)
3. [安装流程](#3-安装流程)
4. [模型下载](#4-模型下载)
5. [测试验证](#5-测试验证)
6. [常见问题](#6-常见问题)

---

## 1. 准备工作

### 1.1 系统要求

- **操作系统**: macOS 12.3 或更高版本
- **芯片**: Apple Silicon (M1/M2/M3/M4/M5)
- **内存**: 至少 16GB RAM（推荐 32GB+）
- **存储**: 至少 30GB 可用空间

### 1.2 检查你的系统

```bash
# 检查系统版本
sw_vers

# 检查芯片信息
system_profiler SPHardwareDataType | grep Chip

# 检查内存
system_profiler SPHardwareDataType | grep Memory

# 检查磁盘空间
df -h /
```

---

## 2. 组件说明

### 🎯 你即将安装的组件

在开始之前，云眠先给你介绍一下每个组件的作用：

---

### 2.1 核心组件

#### 📦 Python 3.11

**是什么**：
- Python 是一种编程语言
- 我们需要用它来运行图片生成脚本

**为什么需要**：
- 图片生成的代码是用 Python 写的
- 需要最新版本来保证兼容性

**占用空间**: ~200MB

---

#### 🔥 PyTorch

**是什么**：
- 深度学习框架
- 用于运行神经网络模型

**为什么需要**：
- Stable Diffusion 是基于神经网络的
- PyTorch 让这些模型可以运行

**占用空间**: ~2GB

**特别说明**：
- 我们会安装 **MPS 版本**
- MPS = Metal Performance Shaders
- 这是苹果芯片专用的加速技术
- 可以让 M5 芯片发挥最大性能

---

#### 🎨 diffusers

**是什么**：
- Hugging Face 开发的图片生成库
- 提供了 Stable Diffusion 的接口

**为什么需要**：
- 让我们可以轻松使用 SDXL 模型
- 提供了简单易用的 API

**占用空间**: ~100MB

---

#### 🤖 transformers

**是什么**：
- 用于处理文本提示词
- 将文字转换为模型可以理解的格式

**为什么需要**：
- 当你说"九公主秦云眠"时
- transformers 把这些字转换成模型能理解的向量

**占用空间**: ~300MB

---

### 2.2 模型组件

#### 🖼️ Stable Diffusion XL Base

**是什么**：
- 开源的文生图模型
- 目前最先进的版本

**为什么需要**：
- 这是生成图片的核心引擎
- 质量：1024x1024，细节丰富

**占用空间**: ~6GB

---

#### 👸 hanfugirl-v1-5 LoRA

**是什么**：
- LoRA = Low-Rank Adaptation
- 一种轻量级的模型微调技术

**为什么需要**：
- 让 SDXL 更擅长生成古风汉服美女
- 专门为云眠自拍优化的

**占用空间**: ~100MB

---

#### 🎭 IP-Adapter FaceID

**是什么**：
- 面部一致性保持技术
- 可以基于参考图片生成

**为什么需要**：
- **这是御主最需要的功能**
- 可以固定某个角色的面部特征
- 生成不同场景、服装、表情的同一人物

**占用空间**: ~1GB

---

### 2.3 辅助组件

#### 📊 accelerate

**是什么**：
- 加速库
- 优化模型加载和推理

**为什么需要**：
- 让生成速度更快
- 减少内存占用

**占用空间**: ~50MB

---

#### 🛡️ safetensors

**是什么**：
- 安全的模型格式
- 防止恶意代码

**为什么需要**：
- 现在的模型都用这个格式
- 更安全

**占用空间**: ~10MB

---

#### 🎯 insightface + onnxruntime

**是什么**：
- 人脸识别库
- 用于 IP-Adapter FaceID

**为什么需要**：
- IP-Adapter 需要先识别面部特征
- 然后才能保持面部一致性

**占用空间**: ~200MB

---

### 2.4 总占用空间

| 组件 | 大小 |
|------|------|
| Python + PyTorch + 库 | ~3GB |
| SDXL Base 模型 | ~6GB |
| LoRA 模型 | ~100MB |
| IP-Adapter 模型 | ~1GB |
| **总计** | **~10GB** |

---

## 3. 安装流程

### 3.1 安装方式

云眠提供 **交互式安装脚本**：

**特点**：
- ✅ 每一步都会询问御主是否继续
- ✅ 自动检查系统环境
- ✅ 失败后可以重新执行
- ✅ 提供详细的进度提示

**安装步骤**：
1. 环境检查
2. 安装 Python 依赖
3. 创建虚拟环境
4. 安装 PyTorch
5. 安装 diffusers + transformers
6. 下载模型
7. 测试验证

---

### 3.2 开始安装

```bash
# 1. 克隆仓库
cd ~/Projects
git clone https://github.com/KomeijiSai/Chaldea.git
cd Chaldea/mac-image-gen-tutorial

# 2. 运行交互式安装脚本
chmod +x install.sh
./install.sh
```

---

## 4. 模型下载

### 4.1 模型下载选项

云眠的安装脚本会询问御主：

**问题 1**: 是否下载 SDXL Base 模型？
- **选择 A**: 自动下载（需要 ~6GB，可能需要 30-60 分钟）
- **选择 B**: 手动下载（云眠提供下载链接）
- **选择 C**: 跳过（稍后下载）

**问题 2**: 是否下载 LoRA 模型？
- **选择 A**: 自动下载（~100MB，很快）
- **选择 B**: 手动下载
- **选择 C**: 跳过

**问题 3**: 是否下载 IP-Adapter 模型？
- **选择 A**: 自动下载（~1GB，需要 10-20 分钟）
- **选择 B**: 手动下载
- **选择 C**: 跳过

---

### 4.2 手动下载模型

如果御主选择手动下载，云眠会提供：

**SDXL Base**：
```bash
# 方式1：使用 huggingface-cli
pip install huggingface-hub
huggingface-cli download stabilityai/stable-diffusion-xl-base-1.0 \
  --local-dir models/sdxl-base

# 方式2：浏览器下载
# 访问：https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0
# 点击 "Files and versions"
# 下载所有文件到 models/sdxl-base/
```

**hanfugirl LoRA**：
```bash
# 浏览器下载
# 访问：https://huggingface.co/svjack/hanfugirl-v1-5
# 下载 hanfugirl-v1-5.safetensors
# 保存到 models/loras/
```

**IP-Adapter FaceID**：
```bash
# 浏览器下载
# 访问：https://huggingface.co/h94/IP-Adapter
# 进入 models/ 目录
# 下载 ip-adapter-plus-faceid_sd15.bin
# 保存到 models/
```

---

## 5. 测试验证

### 5.1 测试脚本

云眠提供 3 个测试脚本：

**测试 1**: 云眠自拍（LoRA）
```bash
python3 test_yunmian_lora.py
```
- 生成 1 张云眠自拍
- 验证 LoRA 效果
- 查看输出：`output/test1_yunmian_lora.png`

**测试 2**: 图像到图像（IP-Adapter）
```bash
# 先准备参考图片
mkdir -p input
# 将参考图片保存为 input/reference.jpg
python3 test_ip_adapter.py
```
- 生成 1 张保持面部一致性的图片
- 验证 IP-Adapter 效果
- 查看输出：`output/test2_ip_adapter.png`

**测试 3**: 批量生成
```bash
python3 test_batch_yunmian.py
```
- 生成 3 张不同场景的云眠自拍
- 验证批量生成能力
- 查看输出：`output/test3_yunmian_*.png`

---

### 5.2 预期效果

**云眠自拍（LoRA）**：
- ✅ 古风汉服效果出色
- ✅ 面部细节清晰
- ✅ 整体质量高

**图像到图像（IP-Adapter）**：
- ✅ 保持参考图片的面部特征
- ✅ 可以修改场景、服装、表情
- ✅ 接近真实照片

---

## 6. 常见问题

### 6.1 安装问题

**Q1: Homebrew 未安装**
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Q2: Python 版本不对**
```bash
brew install python@3.11
```

**Q3: 虚拟环境激活失败**
```bash
# 重新创建虚拟环境
rm -rf venv
python3.11 -m venv venv
source venv/bin/activate
```

---

### 6.2 性能问题

**Q1: 生成速度慢**
```python
# 降低推理步数
num_inference_steps=20  # 默认 30

# 降低分辨率
width=768, height=768  # 默认 1024
```

**Q2: 内存不足**
```bash
# 检查内存使用
top -o MEM

# 关闭其他应用
```

---

### 6.3 效果问题

**Q1: 生成的图片不像云眠**
- 检查 LoRA 是否正确加载
- 尝试调整 LoRA 权重（0.8-1.2）
- 优化提示词

**Q2: IP-Adapter 面部不一致**
- 确保参考图片质量高
- 检查 IP-Adapter 是否正确加载
- 尝试调整 IP-Adapter 权重

---

## 7. 下一步

### 7.1 安装完成后

御主可以：
1. 修改 `config.json` 自定义场景
2. 创建自己的测试脚本
3. 探索更多 LoRA 模型

### 7.2 进阶功能

- **ControlNet**：精确控制姿势和构图
- **Inpainting**：局部修改图片
- **Upscaling**：提升图片分辨率

---

**创建时间**: 2026-02-27 09:40
**维护者**: 九公主云眠

*御主，现在开始创建交互式安装脚本！💪*
