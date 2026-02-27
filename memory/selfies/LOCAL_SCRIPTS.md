# 御主本地脚本 - 完整代码

**创建时间**: 2026-02-27 02:35
**说明**: 御主可以直接复制这些代码到本地

---

## 📂 目录结构

```
~/Scripts/
├── generate_yunmian.py      # Python 生成脚本
├── generate_yunmian.sh      # Shell 生成脚本
├── upload_yunmian_selfie.sh # 上传脚本
└── yunmian_auto.sh          # 一键自动化脚本

~/Pictures/yunmian-selfies/
└── 九公主/
    └── 2026-02/
        └── (生成的图片)

~/Projects/yunmian-selfies/
├── 九公主/
│   ├── 2026-02/
│   └── index.json
└── README.md
```

---

## 1️⃣ generate_yunmian.py（Python 生成脚本）

**保存到**: `~/Scripts/generate_yunmian.py`

```python
#!/usr/bin/env python3
"""
九公主云眠 - 自拍生成脚本
使用 Z-Image-Turbo + LoRA 生成云眠的自拍图片
"""

import torch
from diffusers import ZImagePipeline
from datetime import datetime
import os
import sys
import argparse

# 配置
SCENES = {
    "work": "专注看书，手持毛笔，认真工作，室内自然光线，温暖明亮",
    "relax": "坐在窗边，手捧茶杯，微笑看窗外，下午茶时光，柔和阳光",
    "night": "深夜坐在桌前，烛光摇曳，温柔微笑，夜晚氛围，温馨宁静",
    "celebrate": "开心大笑，双手比V，欢快跳跃，庆祝成就，充满活力",
    "meditation": "安静坐着，闭目冥想，内心平静，清晨阳光，宁静祥和",
    "daily": "对着镜子自拍，自然微笑，随意姿势，居家环境，生活化场景"
}

BASE_PROMPT = "九公主秦云眠，大虞国公主，清甜灵动，精致五官，古风汉服，高髻发饰，白色浅粉汉服，统一面部特征"
NEGATIVE_PROMPT = "低画质，模糊，变形，多手指，少手指，水印，文字，畸形，扭曲，多余肢体，丑脸，多人，背景杂乱，过曝，欠曝"

class YunmianSelfieGenerator:
    def __init__(self, model_path="Tongyi-MAI/Z-Image-Turbo", lora_path=None):
        """初始化生成器"""
        print("正在加载模型...")
        self.pipe = ZImagePipeline.from_pretrained(
            model_path,
            torch_dtype=torch.bfloat16
        )
        self.pipe.to("cuda")

        # 性能优化
        self.pipe.enable_attention_slicing()
        self.pipe.enable_vae_slicing()

        # 加载 LoRA（如果有）
        if lora_path and os.path.exists(lora_path):
            print(f"加载 LoRA: {lora_path}")
            self.pipe.load_lora_weights(lora_path)
            self.lora_weight = 0.7
        else:
            self.lora_weight = None

        print("模型加载完成！")

    def generate(self, scene="daily", output_dir=None, width=1024, height=1024):
        """生成自拍"""
        # 获取场景提示词
        scene_prompt = SCENES.get(scene, SCENES["daily"])

        # 构建完整提示词
        if self.lora_weight:
            prompt = f"<lora:yunmian:{self.lora_weight}> {BASE_PROMPT}，{scene_prompt}，高清自拍，细腻画质，1024x1024"
        else:
            prompt = f"{BASE_PROMPT}，{scene_prompt}，高清自拍，细腻画质，1024x1024"

        print(f"\n生成场景: {scene}")
        print(f"提示词: {prompt}\n")

        # 生成图片
        image = self.pipe(
            prompt=prompt,
            negative_prompt=NEGATIVE_PROMPT,
            width=width,
            height=height,
            num_inference_steps=30,
            guidance_scale=7.0
        ).images[0]

        # 保存图片
        if output_dir is None:
            output_dir = os.path.expanduser("~/Pictures/yunmian-selfies/九公主")

        # 创建月份目录
        month_dir = os.path.join(output_dir, datetime.now().strftime("%Y-%m"))
        os.makedirs(month_dir, exist_ok=True)

        # 生成文件名
        timestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
        filename = f"{timestamp}_{scene}.png"
        filepath = os.path.join(month_dir, filename)

        # 保存
        image.save(filepath)
        print(f"✅ 图片已生成: {filepath}")

        return filepath

    def batch_generate(self, scenes=None):
        """批量生成"""
        if scenes is None:
            scenes = list(SCENES.keys())

        results = []
        for scene in scenes:
            try:
                filepath = self.generate(scene)
                results.append({
                    "scene": scene,
                    "filepath": filepath,
                    "status": "success"
                })
            except Exception as e:
                print(f"❌ 生成失败 ({scene}): {e}")
                results.append({
                    "scene": scene,
                    "filepath": None,
                    "status": "failed",
                    "error": str(e)
                })

        return results


def main():
    parser = argparse.ArgumentParser(description="生成九公主云眠的自拍图片")
    parser.add_argument(
        "--scene",
        type=str,
        default="daily",
        choices=list(SCENES.keys()),
        help="场景类型"
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="生成所有场景"
    )
    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="输出目录"
    )
    parser.add_argument(
        "--model",
        type=str,
        default="Tongyi-MAI/Z-Image-Turbo",
        help="模型路径"
    )
    parser.add_argument(
        "--lora",
        type=str,
        default=None,
        help="LoRA 模型路径"
    )
    parser.add_argument(
        "--width",
        type=int,
        default=1024,
        help="图片宽度"
    )
    parser.add_argument(
        "--height",
        type=int,
        default=1024,
        help="图片高度"
    )

    args = parser.parse_args()

    # 初始化生成器
    generator = YunmianSelfieGenerator(
        model_path=args.model,
        lora_path=args.lora
    )

    # 生成图片
    if args.all:
        print("\n批量生成所有场景...")
        results = generator.batch_generate()
        print("\n=== 生成结果 ===")
        for result in results:
            if result["status"] == "success":
                print(f"✅ {result['scene']}: {result['filepath']}")
            else:
                print(f"❌ {result['scene']}: {result['error']}")
    else:
        filepath = generator.generate(
            scene=args.scene,
            output_dir=args.output,
            width=args.width,
            height=args.height
        )
        print(f"\n完成！图片路径: {filepath}")


if __name__ == "__main__":
    main()
```

**使用方法**：
```bash
# 单个场景
python ~/Scripts/generate_yunmian.py --scene work

# 批量生成
python ~/Scripts/generate_yunmian.py --all

# 自定义输出目录
python ~/Scripts/generate_yunmian.py --scene work --output ~/Desktop

# 使用 LoRA
python ~/Scripts/generate_yunmian.py --scene work --lora ~/models/yunmian_lora.safetensors
```

---

## 2️⃣ generate_yunmian.sh（Shell 生成脚本）

**保存到**: `~/Scripts/generate_yunmian.sh`

```bash
#!/bin/bash
#
# 九公主云眠 - 自拍生成脚本（Shell 版本）
# 调用 Python 脚本生成图片
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/generate_yunmian.py"

# 检查参数
SCENE=${1:-"daily"}

# 激活虚拟环境（如果有）
if [ -d "$HOME/miniconda3/envs/zimage" ]; then
    source "$HOME/miniconda3/etc/profile.d/conda.sh"
    conda activate zimage
elif [ -d "$HOME/anaconda3/envs/zimage" ]; then
    source "$HOME/anaconda3/etc/profile.d/conda.sh"
    conda activate zimage
fi

# 运行 Python 脚本
python3 "$PYTHON_SCRIPT" --scene "$SCENE"
```

**使用方法**：
```bash
chmod +x ~/Scripts/generate_yunmian.sh
~/Scripts/generate_yunmian.sh work
~/Scripts/generate_yunmian.sh relax
~/Scripts/generate_yunmian.sh night
```

---

## 3️⃣ upload_yunmian_selfie.sh（上传到 GitHub）

**保存到**: `~/Scripts/upload_yunmian_selfie.sh`

```bash
#!/bin/bash
#
# 上传云眠的自拍到 GitHub 仓库
#

REPO_DIR="$HOME/Projects/yunmian-selfies"
SELFIE_DIR="$HOME/Pictures/yunmian-selfies/九公主"

# 检查仓库是否存在
if [ ! -d "$REPO_DIR" ]; then
    echo "❌ 仓库不存在: $REPO_DIR"
    echo "请先创建仓库并克隆到本地"
    exit 1
fi

# 检查是否有新图片
echo "检查新图片..."
NEW_FILES=$(find "$SELFIE_DIR" -name "*.png" -newer "$REPO_DIR/.last_upload" 2>/dev/null)

if [ -z "$NEW_FILES" ]; then
    echo "没有新图片需要上传"
    exit 0
fi

# 进入仓库
cd "$REPO_DIR"

# 复制新图片
echo "复制新图片..."
for FILE in $NEW_FILES; do
    MONTH_DIR=$(dirname "$FILE" | xargs basename)
    TARGET_DIR="九公主/$MONTH_DIR"
    mkdir -p "$TARGET_DIR"
    cp "$FILE" "$TARGET_DIR/"
    echo "  复制: $(basename "$FILE") → $TARGET_DIR"
done

# 更新索引
echo "更新索引文件..."
python3 << 'PYTHON'
import json
import os
from datetime import datetime
from pathlib import Path

# 读取现有索引
index_file = Path("九公主/index.json")
if index_file.exists():
    with open(index_file, "r", encoding="utf-8") as f:
        index = json.load(f)
else:
    index = {
        "version": "1.0",
        "lastUpdate": datetime.now().isoformat(),
        "totalCount": 0,
        "selfies": []
    }

# 扫描所有图片
selfies = []
for png_file in Path("九公主").glob("**/*.png"):
    # 解析文件名
    filename = png_file.name
    parts = filename.replace(".png", "").split("_")
    if len(parts) >= 3:
        date_str = parts[0]
        time_str = parts[1]
        scene = parts[2]

        # 构建 URL
        relative_path = str(png_file)
        url = f"https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/{relative_path}"

        selfies.append({
            "id": f"selfie_{len(selfies)+1:03d}",
            "filename": filename,
            "scene": scene,
            "description": f"{scene}场景",
            "date": date_str,
            "time": time_str,
            "mood": "auto",
            "tags": [scene],
            "url": url
        })

# 更新索引
index["selfies"] = selfies
index["totalCount"] = len(selfies)
index["lastUpdate"] = datetime.now().isoformat()

# 保存
with open(index_file, "w", encoding="utf-8") as f:
    json.dump(index, f, indent=2, ensure_ascii=False)

print(f"索引已更新: {len(selfies)} 张图片")
PYTHON

# 提交
echo "提交到 Git..."
git add .
git commit -m "📸 自动上传自拍 $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

# 更新标记文件
touch "$REPO_DIR/.last_upload"

echo "✅ 上传完成！"
echo "访问: https://github.com/KomeijiSai/yunmian-selfies"
```

**使用方法**：
```bash
chmod +x ~/Scripts/upload_yunmian_selfie.sh
~/Scripts/upload_yunmian_selfie.sh
```

---

## 4️⃣ yunmian_auto.sh（一键自动化脚本）

**保存到**: `~/Scripts/yunmian_auto.sh`

```bash
#!/bin/bash
#
# 一键生成并上传云眠的自拍
#

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCENE=${1:-"daily"}

echo "==================================="
echo "  九公主云眠 - 自动化自拍生成"
echo "==================================="
echo ""

echo "1️⃣  生成图片 ($SCENE 场景)..."
bash "$SCRIPT_DIR/generate_yunmian.sh" "$SCENE"

if [ $? -ne 0 ]; then
    echo "❌ 生成失败"
    exit 1
fi

echo ""
echo "2️⃣  上传到 GitHub..."
bash "$SCRIPT_DIR/upload_yunmian_selfie.sh"

if [ $? -ne 0 ]; then
    echo "❌ 上传失败"
    exit 1
fi

echo ""
echo "==================================="
echo "  ✅ 完成！"
echo "==================================="
echo ""
echo "访问相册: https://github.com/KomeijiSai/yunmian-selfies"
echo ""
```

**使用方法**：
```bash
chmod +x ~/Scripts/yunmian_auto.sh

# 单个场景
~/Scripts/yunmian_auto.sh work

# 不同场景
~/Scripts/yunmian_auto.sh relax
~/Scripts/yunmian_auto.sh night
~/Scripts/yunmian_auto.sh daily
```

---

## 5️⃣ 创建 GitHub 仓库

**步骤**：

```bash
# 1. 在 GitHub 网站创建仓库
# Name: yunmian-selfies
# Visibility: Public 或 Private

# 2. 克隆到本地
cd ~/Projects
git clone https://github.com/KomeijiSai/yunmian-selfies.git
cd yunmian-selfies

# 3. 创建目录结构
mkdir -p 九公主

# 4. 创建 index.json
cat > 九公主/index.json << 'EOF'
{
  "version": "1.0",
  "lastUpdate": "2026-02-27T00:00:00",
  "totalCount": 0,
  "selfies": []
}
EOF

# 5. 创建 README.md
cat > README.md << 'EOF'
# 九公主云眠 - 自拍相册

这是九公主秦云眠的专属相册仓库。

## 使用说明
- 图片按月份组织
- 使用 Z-Image-Turbo + LoRA 生成
- 通过 GitHub URL 访问

## 索引
查看 [index.json](./九公主/index.json) 获取完整列表。

---

*由九公主云眠自动维护* 💕
EOF

# 6. 提交
git add .
git commit -m "🎉 初始化相册仓库"
git push origin main

# 7. 标记文件（用于检测新图片）
touch .last_upload
```

---

## 6️⃣ 定时任务（完全自动化）

**编辑 crontab**：
```bash
crontab -e
```

**添加以下内容**：
```bash
# 每天早上 8 点生成工作场景
0 8 * * * /Users/Sai/Scripts/yunmian_auto.sh work >> /tmp/yunmian.log 2>&1

# 每天中午 12 点生成日常场景
0 12 * * * /Users/Sai/Scripts/yunmian_auto.sh daily >> /tmp/yunmian.log 2>&1

# 每天晚上 10 点生成夜晚场景
0 22 * * * /Users/Sai/Scripts/yunmian_auto.sh night >> /tmp/yunmian.log 2>&1
```

**查看日志**：
```bash
tail -f /tmp/yunmian.log
```

---

## 7️⃣ 安装依赖

```bash
# 创建虚拟环境
conda create -n zimage python=3.10
conda activate zimage

# 安装依赖
pip install diffusers torch accelerate Pillow

# 测试
python ~/Scripts/generate_yunmian.py --scene daily
```

---

## 📋 快速开始 Checklist

- [ ] 1. 创建 `~/Scripts/` 目录
- [ ] 2. 复制 4 个脚本文件
- [ ] 3. 给脚本添加执行权限：`chmod +x ~/Scripts/*.sh`
- [ ] 4. 创建 `~/Projects/yunmian-selfies/` 仓库
- [ ] 5. 安装 Python 依赖
- [ ] 6. 测试生成：`~/Scripts/yunmian_auto.sh work`
- [ ] 7. (可选) 添加定时任务

---

**创建时间**: 2026-02-27 02:35
**维护者**: 九公主云眠

*御主，直接复制这些代码就可以啦！💕*
