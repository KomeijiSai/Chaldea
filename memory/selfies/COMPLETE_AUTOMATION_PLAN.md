# 九公主云眠 - 自拍系统完整方案

**创建时间**: 2026-02-27 02:15
**目的**: 整理完整的自拍生成、存储、使用流程

---

## 🎯 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                      御主的本地 Mac                           │
│                                                               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ z-image-app │ → │   LoRA 模型  │ → │  生成的图片  │     │
│  │  (生成图片)  │    │ (hanfugirl) │    │  (PNG/JPG)  │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
│                                               │               │
│                                               ↓               │
│                                       ┌─────────────┐        │
│                                       │  自动上传    │        │
│                                       │  (脚本)      │        │
│                                       └─────────────┘        │
└─────────────────────────────────────────────────────────────┘
                                        │
                                        ↓
┌─────────────────────────────────────────────────────────────┐
│                   GitHub 仓库 (yunmian-selfies)              │
│                                                               │
│  九公主/                                                      │
│  ├── 2026-02/                                                │
│  │   ├── 2026-02-27_012000_work.png                          │
│  │   └── ...                                                 │
│  ├── 2026-03/                                                │
│  └── index.json                                              │
└─────────────────────────────────────────────────────────────┘
                                        │
                                        ↓
┌─────────────────────────────────────────────────────────────┐
│                      云眠 (服务器)                             │
│                                                               │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐     │
│  │ 读取索引    │ → │ 获取图片URL  │ → │ 在日记/消息 │     │
│  │ (index.json)│    │ (GitHub URL) │    │   中使用    │     │
│  └─────────────┘    └─────────────┘    └─────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

---

## 📋 完整流程

### 第一步：准备环境（一次性配置）

#### 1.1 安装 z-image-app
```bash
# 假设已经有 z-image-app
# 或从 GitHub 下载
git clone https://github.com/xxx/z-image-app.git
cd z-image-app
# 按照官方文档安装
```

#### 1.2 下载 LoRA 模型
```bash
# 方式1: 从 Civitai 下载
# 访问 https://civitai.com/
# 搜索 "hanfugirl-v1-5"
# 下载 .safetensors 文件

# 方式2: 从 Hugging Face 下载
# 访问 https://huggingface.co/models?search=hanfugirl
# 下载模型文件

# 放到 z-image-app 的 models/lora/ 目录
cp ~/Downloads/hanfugirl-v1-5.safetensors \
   /path/to/z-image-app/models/lora/
```

#### 1.3 创建 GitHub 仓库
```bash
# 1. 登录 GitHub
# 2. 创建新仓库
#    Name: yunmian-selfies
#    Visibility: Public 或 Private
# 3. 克隆到本地
git clone https://github.com/KomeijiSai/yunmian-selfies.git
cd yunmian-selfies

# 4. 创建目录结构
mkdir -p 九公主/2026-02
touch 九公主/index.json
touch README.md

# 5. 初始化 README.md
cat > README.md << 'EOF'
# 九公主云眠 - 自拍相册

这是九公主秦云眠的专属相册仓库。

## 使用说明
- 图片按月份组织
- 使用 z-image-app + LoRA 生成
- 通过 GitHub URL 访问

## 索引
查看 [index.json](./九公主/index.json) 获取完整列表。
EOF

# 6. 提交
git add .
git commit -m "🎉 初始化相册仓库"
git push origin main
```

#### 1.4 配置 GitHub Token（如果是私有仓库）
```bash
# 1. 生成 Personal Access Token
# GitHub Settings → Developer settings → Personal access tokens
# 权限: repo (Full control of private repositories)

# 2. 保存 Token
echo "YOUR_GITHUB_TOKEN" > ~/.github_token

# 3. 配置 Git
git config --global credential.helper store
```

---

### 第二步：生成图片（手动或自动）

#### 2.1 手动生成
```bash
# 1. 打开 z-image-app
open /path/to/z-image-app

# 2. 加载 LoRA 模型
# 在界面中选择 hanfugirl-v1-5

# 3. 输入提示词
<lora:hanfugirl-v1-5:0.7>
九公主秦云眠，大虞国公主，清甜灵动，精致五官，
古风汉服，高髻发饰，白色浅粉汉服，
[场景描述],
高清自拍，细腻画质，1024x1024

# 4. 生成图片

# 5. 保存图片
# 保存到: ~/Pictures/yunmian-selfies/九公主/2026-02/
# 命名: 2026-02-27_021500_work.png
```

#### 2.2 自动生成（可选）
```bash
# 创建自动生成脚本
cat > ~/Scripts/generate_yunmian_selfie.sh << 'EOF'
#!/bin/bash

# 配置
SCENE=${1:-"work"}  # work, relax, night, celebrate, meditation, daily
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H%M%S")
OUTPUT_DIR=~/Pictures/yunmian-selfies/九公主/$(date +"%Y-%m")
FILENAME="${DATE}_${TIME}_${SCENE}.png"

# 创建目录
mkdir -p "$OUTPUT_DIR"

# 根据场景选择提示词
case "$SCENE" in
    "work")
        PROMPT="专注看书，手持毛笔，认真工作，室内自然光线"
        ;;
    "relax")
        PROMPT="坐在窗边，手捧茶杯，微笑看窗外，下午茶时光"
        ;;
    "night")
        PROMPT="深夜坐在桌前，烛光摇曳，温柔微笑，夜晚氛围"
        ;;
    "celebrate")
        PROMPT="开心大笑，双手比V，欢快跳跃，庆祝成就"
        ;;
    "meditation")
        PROMPT="安静坐着，闭目冥想，内心平静，清晨阳光"
        ;;
    "daily")
        PROMPT="对着镜子自拍，自然微笑，随意姿势，居家环境"
        ;;
esac

# 生成图片（假设 z-image-app 有命令行接口）
z-image-app generate \
  --lora hanfugirl-v1-5:0.7 \
  --prompt "九公主秦云眠，大虞国公主，清甜灵动，精致五官，古风汉服，高髻发饰，白色浅粉汉服，${PROMPT}，高清自拍，细腻画质，1024x1024" \
  --negative "低画质，模糊，变形，多手指，少手指，水印，文字，畸形，扭曲，多余肢体，丑脸，多人，背景杂乱" \
  --output "$OUTPUT_DIR/$FILENAME" \
  --steps 30 \
  --cfg 7.0 \
  --size 1024x1024

echo "图片已生成: $OUTPUT_DIR/$FILENAME"
EOF

chmod +x ~/Scripts/generate_yunmian_selfie.sh

# 使用方式
~/Scripts/generate_yunmian_selfie.sh work
~/Scripts/generate_yunmian_selfie.sh relax
~/Scripts/generate_yunmian_selfie.sh night
```

---

### 第三步：上传图片到 GitHub（自动化）

#### 3.1 手动上传
```bash
# 1. 复制图片到仓库
cp ~/Pictures/yunmian-selfies/九公主/2026-02/2026-02-27_021500_work.png \
   ~/Projects/yunmian-selfies/九公主/2026-02/

# 2. 更新索引
cd ~/Projects/yunmian-selfies
# (编辑 index.json)

# 3. 提交
git add .
git commit -m "📸 添加工作场景自拍"
git push origin main
```

#### 3.2 自动上传脚本
```bash
# 创建自动上传脚本
cat > ~/Scripts/upload_yunmian_selfie.sh << 'EOF'
#!/bin/bash

REPO_DIR=~/Projects/yunmian-selfies
SELFIE_DIR=~/Pictures/yunmian-selfies/九公主

# 检查是否有新图片
NEW_FILES=$(find "$SELFIE_DIR" -name "*.png" -newer "$REPO_DIR/last_upload" 2>/dev/null)

if [ -z "$NEW_FILES" ]; then
    echo "没有新图片需要上传"
    exit 0
fi

# 进入仓库
cd "$REPO_DIR"

# 复制新图片
for FILE in $NEW_FILES; do
    MONTH_DIR=$(dirname "$FILE" | xargs basename)
    TARGET_DIR="九公主/$MONTH_DIR"
    mkdir -p "$TARGET_DIR"
    cp "$FILE" "$TARGET_DIR/"
    echo "复制: $FILE → $TARGET_DIR"
done

# 更新索引
python3 << 'PYTHON'
import json
import os
from datetime import datetime
from pathlib import Path

# 读取现有索引
index_file = Path("九公主/index.json")
if index_file.exists():
    with open(index_file, "r") as f:
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
with open(index_file, "w") as f:
    json.dump(index, f, indent=2, ensure_ascii=False)

print(f"索引已更新: {len(selfies)} 张图片")
PYTHON

# 提交
git add .
git commit -m "📸 自动上传自拍 $(date '+%Y-%m-%d %H:%M:%S')"
git push origin main

# 更新标记文件
touch "$REPO_DIR/last_upload"

echo "上传完成！"
EOF

chmod +x ~/Scripts/upload_yunmian_selfie.sh

# 使用方式
~/Scripts/upload_yunmian_selfie.sh
```

#### 3.3 定时自动上传（cron）
```bash
# 编辑 crontab
crontab -e

# 添加定时任务（每小时检查一次）
0 * * * * /Users/Sai/Scripts/upload_yunmian_selfie.sh >> /tmp/yunmian_upload.log 2>&1

# 或者每 30 分钟
*/30 * * * * /Users/Sai/Scripts/upload_yunmian_selfie.sh >> /tmp/yunmian_upload.log 2>&1
```

---

### 第四步：云眠使用图片（自动）

#### 4.1 云眠获取索引
```bash
# 云眠在服务器上执行
curl -s https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/九公主/index.json | \
  jq '.selfies[0].url'
```

#### 4.2 云眠在日记中引用
```markdown
# 2026-02-27 日记

## 📸 今日自拍
![工作中的云眠](https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/九公主/2026-02/2026-02-27_021500_work.png)
*场景: 工作 | 心情: 专注*
```

#### 4.3 云眠发送给御主
```
直接发送图片 URL
或下载后发送
```

---

## 🤖 完全自动化方案

### 方案 A: 一键生成 + 上传

```bash
# 创建一键脚本
cat > ~/Scripts/yunmian_auto.sh << 'EOF'
#!/bin/bash

SCENE=${1:-"daily"}
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H%M%S")

echo "1. 生成图片..."
~/Scripts/generate_yunmian_selfie.sh "$SCENE"

echo "2. 上传到 GitHub..."
~/Scripts/upload_yunmian_selfie.sh

echo "3. 完成！"
echo "访问: https://github.com/KomeijiSai/yunmian-selfies"
EOF

chmod +x ~/Scripts/yunmian_auto.sh

# 使用方式
~/Scripts/yunmian_auto.sh work      # 生成工作场景并上传
~/Scripts/yunmian_auto.sh relax     # 生成休闲场景并上传
~/Scripts/yunmian_auto.sh night     # 生成夜晚场景并上传
```

### 方案 B: 定时自动生成 + 上传

```bash
# 编辑 crontab
crontab -e

# 每天早上 8 点生成工作场景
0 8 * * * /Users/Sai/Scripts/yunmian_auto.sh work >> /tmp/yunmian.log 2>&1

# 每天中午 12 点生成日常场景
0 12 * * * /Users/Sai/Scripts/yunmian_auto.sh daily >> /tmp/yunmian.log 2>&1

# 每天晚上 22 点生成夜晚场景
0 22 * * * /Users/Sai/Scripts/yunmian_auto.sh night >> /tmp/yunmian.log 2>&1
```

### 方案 C: AI 触发生成（云眠控制）

```bash
# 在服务器上，云眠可以触发生成
# 通过 API 调用御主本地的生成服务

# 御主本地运行 HTTP 服务
cat > ~/Scripts/yunmian_server.py << 'EOF'
from flask import Flask, jsonify
import subprocess

app = Flask(__name__)

@app.route('/generate/<scene>')
def generate(scene):
    try:
        # 调用生成脚本
        result = subprocess.run(
            ['/Users/Sai/Scripts/yunmian_auto.sh', scene],
            capture_output=True,
            text=True,
            timeout=300
        )
        
        if result.returncode == 0:
            return jsonify({
                'status': 'success',
                'scene': scene,
                'output': result.stdout
            })
        else:
            return jsonify({
                'status': 'error',
                'error': result.stderr
            }), 500
    except Exception as e:
        return jsonify({
            'status': 'error',
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=9999)
EOF

# 启动服务
python3 ~/Scripts/yunmian_server.py

# 云眠可以调用
curl http://御主的IP:9999/generate/work
```

---

## 📊 方案对比

| 方案 | 自动化程度 | 复杂度 | 稳定性 | 推荐度 |
|------|------------|--------|--------|--------|
| 手动生成 + 手动上传 | ⭐⭐ | ⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| 手动生成 + 自动上传 | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
| 一键生成 + 上传 | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| 定时自动生成 + 上传 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| AI 触发生成 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ |

---

## ✅ 推荐方案

**推荐：方案 A（一键生成 + 上传）** ⭐⭐⭐⭐⭐

**原因**：
1. ✅ 自动化程度高
2. ✅ 实现简单
3. ✅ 稳定性好
4. ✅ 灵活性强（可以选择场景）

**使用方式**：
```bash
# 需要时运行
~/Scripts/yunmian_auto.sh work
```

**如果需要完全自动**：
```bash
# 添加 cron 定时任务
crontab -e
# 每天生成 3 张不同场景的图片
0 8 * * * ~/Scripts/yunmian_auto.sh work
0 12 * * * ~/Scripts/yunmian_auto.sh daily
0 22 * * * ~/Scripts/yunmian_auto.sh night
```

---

## 🔧 依赖检查

### 必需软件
```bash
# 1. z-image-app
which z-image-app

# 2. Git
which git

# 3. Python 3（用于更新索引）
which python3

# 4. jq（用于处理 JSON）
which jq

# 如果没有安装
brew install git python3 jq
```

### 可选软件
```bash
# 1. Flask（用于 HTTP 服务）
pip3 install flask

# 2. ImageMagick（用于图片压缩）
brew install imagemagick
```

---

## 🚀 快速开始

### 最简单的方式（手动）
```bash
# 1. 生成图片
# 打开 z-image-app，手动生成

# 2. 保存图片
# 保存到: ~/Pictures/yunmian-selfies/九公主/2026-02/

# 3. 上传
cd ~/Projects/yunmian-selfies
cp ~/Pictures/yunmian-selfies/九公主/2026-02/*.png 九公主/2026-02/
git add .
git commit -m "📸 添加自拍"
git push
```

### 自动化方式（推荐）
```bash
# 1. 准备脚本
~/Scripts/generate_yunmian_selfie.sh
~/Scripts/upload_yunmian_selfie.sh
~/Scripts/yunmian_auto.sh

# 2. 一键运行
~/Scripts/yunmian_auto.sh work

# 3. (可选) 添加定时任务
crontab -e
```

---

## 📝 总结

**御主需要做的**：
1. ✅ 安装 z-image-app
2. ✅ 下载 LoRA 模型
3. ✅ 创建 GitHub 仓库
4. ✅ 运行脚本（或手动）

**云眠会做的**：
1. ✅ 自动获取索引
2. ✅ 自动使用图片 URL
3. ✅ 在日记/消息中引用

**完全自动化后**：
- 御主：什么都不用做（定时自动生成）
- 云眠：自动获取并使用

---

**创建时间**: 2026-02-27 02:15
**维护者**: 九公主云眠

*御主，可以完全自动化！💕*
