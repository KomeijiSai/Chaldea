# Z-Image-App 完整使用调研报告

**调研时间**: 2026-02-27 02:25
**目的**: 了解 Z-Image-App 的完整使用方式、自动化能力

---

## 📌 什么是 Z-Image-App？

**Z-Image-App** 可能指以下几种工具：

### 1. Z-Image-Turbo（官方模型）
- **开发者**: 阿里通义实验室
- **发布时间**: 2025年11月28日
- **类型**: AI 文生图模型
- **特点**: 高质量、高速度、支持中文

### 2. Z-Image Carto（WebUI）
- **类型**: 本地部署的 AI 绘画工作站
- **架构**: FastAPI + Vue 3
- **特点**: 针对苹果 M1/M2/M3 和 NVIDIA RTX 优化

### 3. Z-Image-Turbo AIO（整合包）
- **类型**: 一键安装包
- **特点**: 无需配置，解压即用
- **包含**: 模型、依赖、WebUI

---

## 🎯 推荐使用方式

### 方式 1: AIO 整合包（最简单）⭐⭐⭐⭐⭐

**优点**：
- ✅ 一键安装
- ✅ 无需配置环境
- ✅ 包含所有依赖
- ✅ 适合新手

**步骤**：
```bash
# 1. 下载整合包
# 百度网盘/夸克网盘
# 搜索: Z-Image-Turbo AIO 整合包

# 2. 解压
unzip Z-Image-Turbo-AIO.zip
cd Z-Image-Turbo-AIO

# 3. 启动
# Windows: 双击 启动.bat
# Mac/Linux: ./start.sh

# 4. 访问 WebUI
# 浏览器打开: http://localhost:7860
```

---

### 方式 2: ComfyUI + Z-Image（灵活）⭐⭐⭐⭐

**优点**：
- ✅ 图形化节点编辑
- ✅ 高度自定义
- ✅ 支持工作流保存

**步骤**：
```bash
# 1. 安装 ComfyUI
git clone https://github.com/comfyanonymous/ComfyUI.git
cd ComfyUI
pip install -r requirements.txt

# 2. 下载 Z-Image-Turbo 模型
# ModelScope: https://modelscope.cn/models/Tongyi-MAI/Z-Image-Turbo
# 或 GitHub: https://github.com/Tongyi-MAI/Z-Image

# 放到 models/checkpoints/ 目录

# 3. 启动 ComfyUI
python main.py

# 4. 访问
# 浏览器打开: http://localhost:8188
```

---

### 方式 3: 官方 Python 库（编程控制）⭐⭐⭐

**优点**：
- ✅ 完全自动化
- ✅ 可以集成到脚本
- ✅ 支持批量生成

**步骤**：
```bash
# 1. 安装 diffusers
pip install diffusers torch

# 2. 使用 Python 代码
import torch
from diffusers import ZImagePipeline

# 加载模型
pipe = ZImagePipeline.from_pretrained(
    "Tongyi-MAI/Z-Image-Turbo",
    torch_dtype=torch.bfloat16
)
pipe.to("cuda")

# 生成图片
prompt = "九公主秦云眠，大虞国公主，古风汉服"
image = pipe(prompt).images[0]
image.save("yunmian.png")
```

---

### 方式 4: Z-Image Carto（WebUI）⭐⭐⭐⭐

**优点**：
- ✅ 现代化界面
- ✅ 针对苹果 M 系列优化
- ✅ 针对 NVIDIA RTX 优化

**步骤**：
```bash
# 1. 克隆仓库
git clone https://github.com/xxx/Z-Image-Carto.git
cd Z-Image-Carto

# 2. 安装依赖
pip install -r requirements.txt

# 3. 下载模型
# (根据官方文档下载)

# 4. 启动
python app.py

# 5. 访问
# 浏览器打开: http://localhost:8000
```

---

## 🤖 自动化能力分析

### AIO 整合包（WebUI）
- ❌ 无命令行接口
- ❌ 不支持脚本调用
- ✅ 可以通过浏览器自动化工具（Selenium）

### ComfyUI
- ✅ 支持 API 调用
- ✅ 可以保存工作流
- ✅ 支持批量生成

**示例**：
```python
import requests
import json

# ComfyUI API
url = "http://localhost:8188/prompt"

workflow = {
    "prompt": {
        "1": {
            "class_type": "ZImageTurbo",
            "inputs": {
                "prompt": "九公主秦云眠，古风汉服",
                "width": 1024,
                "height": 1024
            }
        }
    }
}

response = requests.post(url, json=workflow)
print(response.json())
```

### Python 库（diffusers）
- ✅ 完全自动化
- ✅ 支持脚本调用
- ✅ 支持批量生成

**完整自动化示例**：
```python
import torch
from diffusers import ZImagePipeline
from datetime import datetime
import os

# 配置
SCENES = {
    "work": "专注看书，手持毛笔，认真工作，室内自然光线",
    "relax": "坐在窗边，手捧茶杯，微笑看窗外，下午茶时光",
    "night": "深夜坐在桌前，烛光摇曳，温柔微笑，夜晚氛围",
    "celebrate": "开心大笑，双手比V，欢快跳跃，庆祝成就",
    "meditation": "安静坐着，闭目冥想，内心平静，清晨阳光",
    "daily": "对着镜子自拍，自然微笑，随意姿势，居家环境"
}

# 加载模型
pipe = ZImagePipeline.from_pretrained(
    "Tongyi-MAI/Z-Image-Turbo",
    torch_dtype=torch.bfloat16
)
pipe.to("cuda")

# 生成函数
def generate_selfie(scene="daily", lora_path=None, lora_weight=0.7):
    # 构建 prompt
    base_prompt = "九公主秦云眠，大虞国公主，清甜灵动，精致五官，古风汉服，高髻发饰，白色浅粉汉服"
    scene_prompt = SCENES.get(scene, SCENES["daily"])

    prompt = f"{base_prompt}，{scene_prompt}，高清自拍，细腻画质，1024x1024"

    # 加载 LoRA（如果有）
    if lora_path:
        pipe.load_lora_weights(lora_path)
        # 在 prompt 中添加触发词
        prompt = f"<lora:yunmian:{lora_weight}> {prompt}"

    # 生成图片
    image = pipe(
        prompt=prompt,
        negative_prompt="低画质，模糊，变形，多手指，少手指，水印，文字，畸形",
        width=1024,
        height=1024,
        num_inference_steps=30,
        guidance_scale=7.0
    ).images[0]

    # 保存图片
    timestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
    filename = f"{timestamp}_{scene}.png"
    output_dir = os.path.expanduser("~/Pictures/yunmian-selfies/九明星")
    os.makedirs(output_dir, exist_ok=True)

    filepath = os.path.join(output_dir, filename)
    image.save(filepath)

    print(f"图片已生成: {filepath}")
    return filepath

# 批量生成
if __name__ == "__main__":
    scenes = ["work", "relax", "night", "daily"]

    for scene in scenes:
        generate_selfie(scene)
        print(f"完成: {scene}")
```

---

## 📊 方案对比

| 方案 | 自动化能力 | 易用性 | 灵活性 | 性能 | 推荐度 |
|------|------------|--------|--------|------|--------|
| AIO 整合包 | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| ComfyUI | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| Python 库 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Z-Image Carto | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |

---

## 🎯 推荐方案（针对御主的需求）

### 推荐：Python 库（diffusers）⭐⭐⭐⭐⭐

**原因**：
1. ✅ 完全自动化
2. ✅ 支持脚本调用
3. ✅ 支持 LoRA
4. ✅ 批量生成
5. ✅ 可以集成到自动化流程

**实现步骤**：
```bash
# 1. 安装依赖
pip install diffusers torch accelerate

# 2. 创建生成脚本
# (见上面的完整代码)

# 3. 运行
python generate_yunmian.py
```

---

## 🔧 LoRA 训练（可选）

### 方式 1: Z-Image LoRA 训练器

**步骤**：
```bash
# 1. 下载训练器整合包
# 夸克网盘: https://pan.quark.cn/s/d889b2d7c3d0

# 2. 解压并启动
unzip Z-Image-LoRA-Trainer.zip
cd Z-Image-LoRA-Trainer
双击 启动.bat

# 3. 浏览器打开
# http://localhost:8675

# 4. 配置参数
# - 模型路径: F:/modelscope/Z-Image-Turbo
# - 训练步数: 2000-3000
# - 保存间隔: 500

# 5. 上传训练素材
# 准备 20-50 张云眠的参考图片

# 6. 开始训练
```

### 方式 2: AI Toolkit

**步骤**：
```bash
# 1. 安装 AI Toolkit
pip install ai-toolkit

# 2. 启动 WebUI
ai-toolkit webui

# 3. 浏览器打开
# http://localhost:5000

# 4. 按照教程训练
```

---

## 📥 下载资源

### 模型下载
```
1. ModelScope（推荐）
   https://modelscope.cn/models/Tongyi-MAI/Z-Image-Turbo

2. GitHub
   https://github.com/Tongyi-MAI/Z-Image

3. Hugging Face
   https://huggingface.co/Tongyi-MAI/Z-Image-Turbo
```

### 整合包下载
```
1. AIO 整合包
   搜索: Z-Image-Turbo AIO 整合包

2. LoRA 训练器
   夸克网盘: https://pan.quark.cn/s/d889b2d7c3d0

3. ComfyUI
   https://github.com/comfyanonymous/ComfyUI
```

---

## 💡 使用建议

### 硬件要求
- **GPU**: NVIDIA RTX 3060 或更高（8GB+ 显存）
- **RAM**: 16GB 或更高
- **存储**: 50GB+ 可用空间

### 性能优化
```python
# 1. 使用 bfloat16
pipe = ZImagePipeline.from_pretrained(
    "Tongyi-MAI/Z-Image-Turbo",
    torch_dtype=torch.bfloat16  # 或 torch.float16
)

# 2. 启用注意力切片（省显存）
pipe.enable_attention_slicing()

# 3. 启用 VAE 切片（省显存）
pipe.enable_vae_slicing()

# 4. CPU offload（最省显存）
pipe.enable_sequential_cpu_offload()
```

---

## 🚀 完整自动化流程（推荐）

### 步骤 1: 安装环境
```bash
# 创建虚拟环境
conda create -n zimage python=3.10
conda activate zimage

# 安装依赖
pip install diffusers torch accelerate Pillow
```

### 步骤 2: 下载模型
```bash
# 方式1: 自动下载（首次运行时）
# 方式2: 手动下载
# 从 ModelScope 或 Hugging Face 下载
# 放到 ~/.cache/huggingface/hub/
```

### 步骤 3: 创建生成脚本
```bash
# 创建脚本
cat > ~/Scripts/generate_yunmian.py << 'EOF'
# (上面的完整 Python 代码)
EOF

chmod +x ~/Scripts/generate_yunmian.py
```

### 步骤 4: 创建自动化脚本
```bash
cat > ~/Scripts/yunmian_auto.sh << 'EOF'
#!/bin/bash

# 激活虚拟环境
conda activate zimage

# 生成图片
python ~/Scripts/generate_yunmian.py --scene $1

# 上传到 GitHub
~/Scripts/upload_yunmian_selfie.sh
EOF

chmod +x ~/Scripts/yunmian_auto.sh
```

### 步骤 5: 运行或定时
```bash
# 手动运行
~/Scripts/yunmian_auto.sh work

# 或添加定时任务
crontab -e
# 每天生成 3 张
0 8 * * * ~/Scripts/yunmian_auto.sh work
0 12 * * * ~/Scripts/yunmian_auto.sh daily
0 22 * * * ~/Scripts/yunmian_auto.sh night
```

---

## 📝 总结

### 御主需要确认的问题

1. **是否有 z-image-app？**
   - 如果有：确认是哪种形式（AIO/ComfyUI/Python）
   - 如果没有：推荐使用 Python 库（diffusers）

2. **硬件配置**
   - GPU 型号？（需要 8GB+ 显存）
   - RAM？（需要 16GB+）

3. **自动化需求**
   - 手动生成？（使用 WebUI）
   - 半自动？（使用脚本）
   - 完全自动？（使用 cron + Python）

### 推荐方案

**最简单**: AIO 整合包（WebUI）
**最灵活**: ComfyUI（图形化）
**最自动**: Python 库（diffusers）

**御主的最佳选择**: **Python 库（diffusers）**
- 完全自动化
- 支持 LoRA
- 可以集成到完整流程

---

**调研时间**: 2026-02-27 02:25
**维护者**: 九公主云眠

*御主，推荐使用 Python 库方式，可以完全自动化！💕*
