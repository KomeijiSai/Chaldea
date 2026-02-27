# Mac M5 图片生成环境

**快速开始**: 高质量人物图片生成，支持面部一致性

---

## 📋 目录结构

```
mac-image-gen-tutorial/
├── README.md                    # 完整教程
├── test_yunmian_lora.py        # 测试1：云眠自拍（LoRA）
├── test_ip_adapter.py          # 测试2：图像到图像（IP-Adapter）
├── test_batch_yunmian.py       # 测试3：批量生成（3张）
├── config.json                 # 配置文件
└── models/                     # 模型目录（需下载）
    ├── sdxl-base/             # SDXL Base 模型（~6GB）
    ├── ip-adapter-plus-faceid_sd15.bin  # IP-Adapter（~1GB）
    └── loras/
        └── hanfugirl-v1-5.safetensors  # 云眠 LoRA（~100MB）
```

---

## 🚀 快速开始

### 1. 克隆仓库

```bash
cd ~/Projects
git clone https://github.com/KomeijiSai/Chaldea.git
cd Chaldea/mac-image-gen-tutorial
```

### 2. 创建虚拟环境

```bash
python3.11 -m venv venv
source venv/bin/activate
pip install --upgrade pip
```

### 3. 安装依赖

```bash
# PyTorch（MPS 加速）
pip install torch torchvision torchaudio

# 图片生成核心库
pip install diffusers[torch] transformers accelerate safetensors pillow

# IP-Adapter 支持
pip install insightface onnxruntime
```

### 4. 下载模型

```bash
# 创建模型目录
mkdir -p models/loras

# 下载 SDXL Base（~6GB）
python3 -c "from diffusers import StableDiffusionXLPipeline; StableDiffusionXLPipeline.from_pretrained('stabilityai/stable-diffusion-xl-base-1.0', torch_dtype='auto')"

# 下载云眠 LoRA（~100MB）
python3 << 'EOF'
from diffusers.utils import hf_hub_download
hf_hub_download(
    repo_id="svjack/hanfugirl-v1-5",
    filename="hanfugirl-v1-5.safetensors",
    local_dir="models/loras"
)
EOF
```

### 5. 运行测试

```bash
# 测试1：云眠自拍
python3 test_yunmian_lora.py

# 测试2：图像到图像（需要准备参考图片）
mkdir -p input
# 将参考图片保存为 input/reference.jpg
python3 test_ip_adapter.py

# 测试3：批量生成（3张）
python3 test_batch_yunmian.py
```

---

## 📚 详细教程

完整教程请查看: [README.md](README.md)

---

## 🎯 两种生成方式

### 方式1：文本 + LoRA（云眠专用）

**适用场景**：生成云眠自拍

**特点**：
- ✅ 使用 hanfugirl LoRA 模型
- ✅ 固定随机种子保持一致性
- ✅ 可以批量生成不同场景

**示例**：
```python
prompt = "九公主秦云眠，专注工作，现代办公室背景"
seed = 42  # 固定种子
```

### 方式2：图像到图像（IP-Adapter）

**适用场景**：基于参考图片生成，保持面部一致性

**特点**：
- ✅ 使用参考图片作为条件
- ✅ 保持面部特征一致
- ✅ 可以修改场景、服装、表情

**示例**：
```python
reference_image = Image.open("input/reference.jpg")
# 生成时会保持参考图片的面部特征
```

---

## ⚙️ 配置说明

编辑 `config.json` 自定义生成参数：

```json
{
  "quality": {
    "high": {
      "num_inference_steps": 40,  // 推理步数（越多越精细）
      "width": 1024,              // 分辨率
      "height": 1024
    }
  }
}
```

---

## 💡 使用建议

### 性能优化（M5 芯片）

**高质量**（推荐）：
- 推理步数：30-40
- 分辨率：1024x1024
- 生成时间：~30-60秒/张

**快速预览**：
- 推理步数：15-20
- 分辨率：768x768
- 生成时间：~10-20秒/张

### 保持一致性

**方法1：固定种子**
```python
seed = 42  # 所有图片使用相同种子
```

**方法2：使用 IP-Adapter**
```python
ip_adapter_image = reference_image  # 基于参考图片
```

---

## 🔧 常见问题

### Q1: MPS 不可用？

**A**: 确保系统版本 >= macOS 12.3

```bash
sw_vers  # 检查系统版本
```

### Q2: 内存不足？

**A**: 降低分辨率或推理步数

```python
width=768, height=768  # 降低分辨率
num_inference_steps=20  # 减少步数
```

### Q3: 模型下载慢？

**A**: 使用镜像

```bash
export HF_ENDPOINT=https://hf-mirror.com
```

---

## 📦 输出文件

生成的图片保存在 `output/` 目录：

```
output/
├── test1_yunmian_lora.png      # 测试1 输出
├── test2_ip_adapter.png        # 测试2 输出
├── test3_yunmian_work.png      # 测试3 - 工作场景
├── test3_yunmian_relax.png     # 测试3 - 休闲场景
└── test3_yunmian_celebrate.png # 测试3 - 庆祝场景
```

---

## 🎨 自定义场景

在 `config.json` 中添加新场景：

```json
"scenes": {
  "custom": "你的场景描述，例如：海边度假，阳光沙滩，轻松愉快"
}
```

然后修改 `test_batch_yunmian.py` 添加场景配置。

---

## 📞 需要帮助？

遇到问题请查看完整教程: [README.md](README.md)

---

**创建时间**: 2026-02-27 09:10
**维护者**: 九公主云眠

*御主，按照这个流程一步步来就可以啦！💕*
