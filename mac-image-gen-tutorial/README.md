# Mac M5 图片生成环境完整教程

**创建时间**: 2026-02-27 09:10
**适用设备**: Mac Apple Silicon (M1/M2/M3/M4/M5)
**目标**: 高质量人物图片生成，支持面部一致性

---

## 📋 目录

1. [环境准备](#1-环境准备)
2. [安装 Python 和虚拟环境](#2-安装-python-和虚拟环境)
3. [安装 PyTorch (MPS 加速)](#3-安装-pytorch-mps-加速)
4. [安装图片生成库](#4-安装图片生成库)
5. [下载模型](#5-下载模型)
6. [测试脚本](#6-测试脚本)
7. [常见问题](#7-常见问题)

---

## 1. 环境准备

### 1.1 检查系统版本

```bash
# 查看系统版本（需要 macOS 12.3+）
sw_vers

# 查看芯片信息
system_profiler SPHardwareDataType | grep Chip
```

**预期输出**：
```
Chip: Apple M5
```

### 1.2 安装 Homebrew（如果没有）

```bash
# 检查是否已安装
brew --version

# 如果未安装，执行
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 1.3 安装 Git

```bash
brew install git
git --version
```

---

## 2. 安装 Python 和虚拟环境

### 2.1 安装 Python 3.11

```bash
# 使用 Homebrew 安装
brew install python@3.11

# 验证安装
python3.11 --version
```

**预期输出**：
```
Python 3.11.x
```

### 2.2 创建项目目录和虚拟环境

```bash
# 创建项目目录
mkdir -p ~/Projects/ImageGen
cd ~/Projects/ImageGen

# 创建虚拟环境
python3.11 -m venv venv

# 激活虚拟环境
source venv/bin/activate

# 升级 pip
pip install --upgrade pip
```

**提示**：每次使用前都要激活虚拟环境：
```bash
cd ~/Projects/ImageGen
source venv/bin/activate
```

---

## 3. 安装 PyTorch (MPS 加速)

### 3.1 安装 PyTorch（支持 MPS）

```bash
# 安装 PyTorch（MPS 版本）
pip install torch torchvision torchaudio

# 验证 MPS 是否可用
python3 -c "import torch; print(f'MPS available: {torch.backends.mps.is_available()}')"
```

**预期输出**：
```
MPS available: True
```

### 3.2 测试 MPS 加速

```bash
python3 << 'EOF'
import torch
import time

# 测试 CPU
x_cpu = torch.randn(1000, 1000)
start = time.time()
for _ in range(100):
    x_cpu = x_cpu @ x_cpu
cpu_time = time.time() - start

# 测试 MPS
x_mps = x_cpu.to('mps')
start = time.time()
for _ in range(100):
    x_mps = x_mps @ x_mps
mps_time = time.time() - start

print(f"CPU time: {cpu_time:.3f}s")
print(f"MPS time: {mps_time:.3f}s")
print(f"Speedup: {cpu_time/mps_time:.2f}x")
EOF
```

**预期输出**：
```
CPU time: 0.xxx s
MPS time: 0.xxx s
Speedup: x.xx x
```

---

## 4. 安装图片生成库

### 4.1 安装核心库

```bash
# 安装 diffusers（图片生成核心）
pip install diffusers[torch]

# 安装 transformers（模型支持）
pip install transformers accelerate

# 安装其他依赖
pip install safetensors pillow opencv-python matplotlib
```

### 4.2 安装 IP-Adapter 支持

```bash
# IP-Adapter FaceID
pip install insightface onnxruntime
```

### 4.3 验证安装

```bash
python3 -c "from diffusers import StableDiffusionXLPipeline; print('✅ diffusers 安装成功')"
python3 -c "from transformers import CLIPTextModel; print('✅ transformers 安装成功')"
```

---

## 5. 下载模型

### 5.1 创建模型目录

```bash
mkdir -p ~/Projects/ImageGen/models
cd ~/Projects/ImageGen/models
```

### 5.2 下载 SDXL Base 模型（~6GB）

**方式1：使用 Python 脚本自动下载**

```bash
cd ~/Projects/ImageGen
python3 << 'EOF'
from diffusers import StableDiffusionXLPipeline
import torch

print("开始下载 SDXL Base 模型...")
print("模型大小：~6GB，请耐心等待...")

# 首次运行会自动下载到缓存
pipe = StableDiffusionXLPipeline.from_pretrained(
    "stabilityai/stable-diffusion-xl-base-1.0",
    torch_dtype=torch.float16,
    variant="fp16",
    use_safetensors=True
)

print("✅ SDXL Base 模型下载完成！")
EOF
```

**方式2：手动下载（国内推荐）**

```bash
# 使用 huggingface-cli 下载
pip install huggingface-hub
huggingface-cli download stabilityai/stable-diffusion-xl-base-1.0 \
  --local-dir ~/Projects/ImageGen/models/sdxl-base \
  --local-dir-use-symlinks False
```

### 5.3 下载 IP-Adapter FaceID 模型（~1GB）

```bash
cd ~/Projects/ImageGen
python3 << 'EOF'
from diffusers.utils import hf_hub_download
import os

print("开始下载 IP-Adapter FaceID 模型...")

# 下载 IP-Adapter Plus FaceID
model_path = hf_hub_download(
    repo_id="h94/IP-Adapter",
    filename="models/ip-adapter-plus-faceid_sd15.bin",
    local_dir="models",
    local_dir_use_symlinks=False
)

print(f"✅ IP-Adapter 模型下载完成: {model_path}")
EOF
```

### 5.4 下载云眠专用 LoRA（~100MB）

```bash
cd ~/Projects/ImageGen
python3 << 'EOF'
from diffusers.utils import hf_hub_download

print("开始下载云眠专用 LoRA 模型...")

# 下载 hanfugirl LoRA
lora_path = hf_hub_download(
    repo_id="svjack/hanfugirl-v1-5",
    filename="hanfugirl-v1-5.safetensors",
    local_dir="models/loras",
    local_dir_use_symlinks=False
)

print(f"✅ LoRA 模型下载完成: {lora_path}")
EOF
```

### 5.5 验证模型完整性

```bash
cd ~/Projects/ImageGen
python3 << 'EOF'
import os

models = {
    "SDXL Base": "models/sdxl-base",
    "IP-Adapter": "models/ip-adapter-plus-faceid_sd15.bin",
    "LoRA": "models/loras/hanfugirl-v1-5.safetensors"
}

print("检查模型文件...")
for name, path in models.items():
    if os.path.exists(path) or os.path.exists(path.replace('.bin', '')):
        print(f"✅ {name}: 存在")
    else:
        print(f"❌ {name}: 不存在，需要下载")
EOF
```

---

## 6. 测试脚本

### 6.1 测试1：云眠自拍生成（文本 + LoRA）

创建文件 `test_yunmian_lora.py`：

```python
#!/usr/bin/env python3
"""
测试1：云眠自拍生成
使用 LoRA + 文本描述生成九公主秦云眠
"""

import torch
from diffusers import StableDiffusionXLPipeline
import os

def main():
    print("=" * 60)
    print("测试1：云眠自拍生成（文本 + LoRA）")
    print("=" * 60)

    # 设备配置
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    print(f"✅ 使用设备: {device}")

    # 加载模型
    print("加载 SDXL 模型...")
    pipe = StableDiffusionXLPipeline.from_pretrained(
        "stabilityai/stable-diffusion-xl-base-1.0",
        torch_dtype=torch.float16,
        variant="fp16",
        use_safetensors=True
    ).to(device)

    # 加载 LoRA
    print("加载云眠专用 LoRA...")
    lora_path = "models/loras/hanfugirl-v1-5.safetensors"
    if os.path.exists(lora_path):
        pipe.load_lora_weights(".", weight_name=lora_path)
        print("✅ LoRA 加载成功")
    else:
        print("⚠️ LoRA 文件不存在，跳过")

    # 提示词
    prompt = """
    九公主秦云眠，大虞国公主，清甜灵动，
    精致五官，古风汉服，高髻发饰，
    白色浅粉汉服，优雅端庄，
    高清自拍，自然光线，高质量，细腻画质
    """

    negative_prompt = """
    低画质，模糊，变形，多手指，少手指，
    水印，文字，畸形，扭曲，多余肢体，
    丑脸，多人
    """

    # 固定随机种子（保持一致性）
    seed = 42
    generator = torch.Generator(device=device).manual_seed(seed)

    # 生成图片
    print("开始生成图片...")
    print(f"提示词: {prompt.strip()}")
    print(f"随机种子: {seed}")

    image = pipe(
        prompt=prompt,
        negative_prompt=negative_prompt,
        num_inference_steps=30,  # 高质量
        guidance_scale=7.5,
        generator=generator,
        width=1024,
        height=1024,
    ).images[0]

    # 保存图片
    output_path = "output/test1_yunmian_lora.png"
    os.makedirs("output", exist_ok=True)
    image.save(output_path)

    print(f"✅ 图片生成成功: {output_path}")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

**运行测试1**：
```bash
cd ~/Projects/ImageGen
python3 test_yunmian_lora.py
```

---

### 6.2 测试2：图像到图像（IP-Adapter）

创建文件 `test_ip_adapter.py`：

```python
#!/usr/bin/env python3
"""
测试2：图像到图像（IP-Adapter）
基于参考图片生成，保持面部一致性
"""

import torch
from diffusers import StableDiffusionXLPipeline, IPAdapterFaceID
from PIL import Image
import os

def main():
    print("=" * 60)
    print("测试2：图像到图像（IP-Adapter FaceID）")
    print("=" * 60)

    # 检查参考图片
    reference_image_path = "input/reference.jpg"
    if not os.path.exists(reference_image_path):
        print(f"❌ 请准备参考图片: {reference_image_path}")
        print("提示：将你的参考图片保存为 input/reference.jpg")
        return

    # 设备配置
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    print(f"✅ 使用设备: {device}")

    # 加载模型
    print("加载 SDXL + IP-Adapter...")
    pipe = StableDiffusionXLPipeline.from_pretrained(
        "stabilityai/stable-diffusion-xl-base-1.0",
        torch_dtype=torch.float16,
        variant="fp16",
        use_safetensors=True
    ).to(device)

    # 加载 IP-Adapter
    ip_adapter_path = "models/ip-adapter-plus-faceid_sd15.bin"
    if os.path.exists(ip_adapter_path):
        pipe.load_ip_adapter(
            ip_adapter_path,
            subfolder="models",
            weight_name="ip-adapter-plus-faceid_sd15.bin"
        )
        print("✅ IP-Adapter 加载成功")
    else:
        print("⚠️ IP-Adapter 文件不存在，跳过")

    # 加载参考图片
    reference_image = Image.open(reference_image_path).convert("RGB")
    print(f"✅ 参考图片加载成功: {reference_image.size}")

    # 提示词（可以根据需要修改）
    prompt = """
    专业人像摄影，高质量，真实感，
    自然光线，柔和背景虚化，
    清晰的面部细节，真实的皮肤质感
    """

    negative_prompt = """
    低画质，模糊，变形，卡通，动漫，
    水印，文字，畸形，扭曲
    """

    # 生成图片
    print("开始生成图片...")

    image = pipe(
        prompt=prompt,
        negative_prompt=negative_prompt,
        ip_adapter_image=reference_image,  # 使用参考图片
        num_inference_steps=40,  # 更高质量
        guidance_scale=7.5,
        width=1024,
        height=1024,
    ).images[0]

    # 保存图片
    output_path = "output/test2_ip_adapter.png"
    os.makedirs("output", exist_ok=True)
    image.save(output_path)

    print(f"✅ 图片生成成功: {output_path}")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

**运行测试2**：
```bash
cd ~/Projects/ImageGen
mkdir -p input
# 将你的参考图片保存为 input/reference.jpg
python3 test_ip_adapter.py
```

---

### 6.3 测试3：批量生成（3张云眠自拍）

创建文件 `test_batch_yunmian.py`：

```python
#!/usr/bin/env python3
"""
测试3：批量生成云眠自拍
生成 3 张不同场景的云眠自拍
"""

import torch
from diffusers import StableDiffusionXLPipeline
import os

# 场景配置
SCENES = [
    {
        "name": "work",
        "prompt": """
        九公主秦云眠，专注工作，
        现代办公室背景，认真思考，
        专业气质，优雅端庄，
        高清自拍，自然光线
        """,
    },
    {
        "name": "relax",
        "prompt": """
        九公主秦云眠，休闲放松，
        咖啡馆场景，轻松愉快，
        微笑，自然表情，
        高清自拍，温暖光线
        """,
    },
    {
        "name": "celebrate",
        "prompt": """
        九公主秦云眠，庆祝时刻，
        开心微笑，活力四射，
        庆祝氛围，喜悦表情，
        高清自拍，明亮光线
        """,
    },
]

def main():
    print("=" * 60)
    print("测试3：批量生成云眠自拍（3张）")
    print("=" * 60)

    # 设备配置
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    print(f"✅ 使用设备: {device}")

    # 加载模型（只加载一次）
    print("加载 SDXL 模型...")
    pipe = StableDiffusionXLPipeline.from_pretrained(
        "stabilityai/stable-diffusion-xl-base-1.0",
        torch_dtype=torch.float16,
        variant="fp16",
        use_safetensors=True
    ).to(device)

    # 加载 LoRA
    print("加载云眠专用 LoRA...")
    lora_path = "models/loras/hanfugirl-v1-5.safetensors"
    if os.path.exists(lora_path):
        pipe.load_lora_weights(".", weight_name=lora_path)
        print("✅ LoRA 加载成功")

    # 负面提示词
    negative_prompt = """
    低画质，模糊，变形，多手指，少手指，
    水印，文字，畸形，扭曲，多余肢体
    """

    # 固定基础种子
    base_seed = 42

    # 创建输出目录
    os.makedirs("output", exist_ok=True)

    # 批量生成
    for i, scene in enumerate(SCENES):
        print(f"\n生成第 {i+1}/3 张: {scene['name']}")

        # 每张图片使用不同的种子（但基于基础种子）
        seed = base_seed + i
        generator = torch.Generator(device=device).manual_seed(seed)

        image = pipe(
            prompt=scene["prompt"],
            negative_prompt=negative_prompt,
            num_inference_steps=30,
            guidance_scale=7.5,
            generator=generator,
            width=1024,
            height=1024,
        ).images[0]

        # 保存图片
        output_path = f"output/test3_yunmian_{scene['name']}.png"
        image.save(output_path)
        print(f"✅ 保存成功: {output_path}")

    print("\n" + "=" * 60)
    print("✅ 批量生成完成！共 3 张图片")
    print("=" * 60)

if __name__ == "__main__":
    main()
```

**运行测试3**：
```bash
cd ~/Projects/ImageGen
python3 test_batch_yunmian.py
```

---

## 7. 常见问题

### 7.1 MPS 不可用

**问题**：`MPS available: False`

**解决**：
```bash
# 检查 macOS 版本
sw_vers

# 需要升级到 macOS 12.3+
```

### 7.2 内存不足

**问题**：`OutOfMemoryError`

**解决**：
```bash
# 方法1：降低分辨率
width=768, height=768

# 方法2：减少推理步数
num_inference_steps=20

# 方法3：使用 float32（更慢但更稳定）
torch_dtype=torch.float32
```

### 7.3 模型下载慢

**问题**：Hugging Face 下载速度慢

**解决**：
```bash
# 方法1：使用镜像
export HF_ENDPOINT=https://hf-mirror.com

# 方法2：手动下载后指定路径
pipe = StableDiffusionXLPipeline.from_pretrained(
    "models/sdxl-base",  # 本地路径
    ...
)
```

### 7.4 LoRA 效果不明显

**问题**：生成的图片不像云眠

**解决**：
```bash
# 调整 LoRA 强度
cross_attention_kwargs={"scale": 1.0}  # 默认 1.0，可以尝试 0.8-1.2
```

### 7.5 IP-Adapter 面部不一致

**问题**：生成的图片和参考图片不像

**解决**：
```bash
# 确保 IP-Adapter 正确加载
# 检查参考图片质量（建议 512x512 以上）
# 调整 IP-Adapter 权重
```

---

## 8. 性能优化建议

### 8.1 推理速度

```python
# M5 芯片推荐配置
num_inference_steps=30  # 平衡质量和速度
guidance_scale=7.5      # 默认值
width=1024             # 高质量
height=1024

# 快速预览（质量降低）
num_inference_steps=15
width=768
height=768
```

### 8.2 批量生成优化

```python
# 方法1：预热模型（只加载一次）
pipe = load_pipeline_once()

# 方法2：使用相同种子生成多个变体
for seed in range(42, 45):
    generator = torch.Generator(device=device).manual_seed(seed)
    # 生成图片...
```

---

## 9. 项目结构

```
~/Projects/ImageGen/
├── venv/                    # 虚拟环境
├── models/                  # 模型文件
│   ├── sdxl-base/          # SDXL Base 模型（~6GB）
│   ├── ip-adapter-plus-faceid_sd15.bin  # IP-Adapter（~1GB）
│   └── loras/
│       └── hanfugirl-v1-5.safetensors  # 云眠 LoRA（~100MB）
├── input/                   # 输入图片
│   └── reference.jpg       # 参考图片
├── output/                  # 输出图片
├── test_yunmian_lora.py    # 测试1脚本
├── test_ip_adapter.py      # 测试2脚本
├── test_batch_yunmian.py   # 测试3脚本
└── README.md               # 本教程
```

---

## 10. 下一步

### 10.1 自定义配置

创建 `config.json` 来自定义生成参数：

```json
{
  "yunmian": {
    "base_prompt": "九公主秦云眠，清甜灵动，精致五官...",
    "negative_prompt": "低画质，模糊，变形...",
    "lora_path": "models/loras/hanfugirl-v1-5.safetensors",
    "default_seed": 42
  },
  "quality": {
    "num_inference_steps": 30,
    "guidance_scale": 7.5,
    "width": 1024,
    "height": 1024
  }
}
```

### 10.2 高级功能

- **ControlNet**：精确控制姿势和构图
- **Inpainting**：局部修改图片
- **Upscaling**：提升图片分辨率

---

**创建时间**: 2026-02-27 09:10
**维护者**: 九公主云眠

*御主，按照这个教程一步步来，就可以啦！💕*
