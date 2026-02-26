# 九公主云眠 - 自拍存储方案 v3.0

**创建时间**: 2026-02-27 01:55
**方案**: 使用独立 GitHub 仓库存储照片

---

## ✅ 方案优势

### 为什么用独立 GitHub 仓库？

✅ **完全免费**
- 无存储费用
- 无流量费用
- GitHub 非常稳定

✅ **不会丢失**
- GitHub 有完整的备份机制
- 可以随时恢复历史版本

✅ **访问快速**
- GitHub CDN 全球加速
- raw.githubusercontent.com 直接访问

✅ **云眠使用简单**
- 只需要引用 URL
- 不需要管理图片文件

✅ **版本管理**
- 可以看到每次更新
- 可以回退到历史版本

---

## 📁 仓库设计

### 仓库名称
```
https://github.com/KomeijiSai/yunmian-selfies
```

### 目录结构
```
yunmian-selfies/
├── README.md                 # 仓库说明
├── 九公主/
│   ├── 2026-02/
│   │   ├── 2026-02-27_012000_work.png
│   │   ├── 2026-02-27_012100_relax.png
│   │   └── ...
│   ├── 2026-03/
│   │   └── ...
│   └── index.json            # 图片索引
├── lora/                     # LoRA 模型（可选）
│   └── yunmian_v1.safetensors
└── assets/                   # 其他资源
    └── ...
```

---

## 🚀 实现步骤

### 第一步：创建仓库（御主操作）

1. 登录 GitHub
2. 创建新仓库
   ```
   Repository name: yunmian-selfies
   Description: 九公主云眠的自拍相册
   Visibility: Public（公开访问）或 Private（私有）
   ```
3. 初始化 README.md
   ```markdown
   # 九公主云眠 - 自拍相册

   这是九公主秦云眠的专属相册仓库。

   ## 使用说明
   - 图片按月份组织
   - 使用 z-image-app + LoRA 生成
   - 通过 GitHub URL 访问

   ## 索引
   查看 [index.json](./九公主/index.json) 获取完整列表。
   ```

---

### 第二步：生成并上传图片（御主操作）

**方式 1: 本地生成 + Git 上传**
```bash
# 1. 克隆仓库
git clone https://github.com/KomeijiSai/yunmian-selfies.git
cd yunmian-selfies

# 2. 生成本地生成图片
# 使用 z-image-app 生成
# 保存到 九公主/2026-02/2026-02-27_012000_work.png

# 3. 添加到 Git
git add 九公主/2026-02/2026-02-27_012000_work.png
git commit -m "📸 添加工作场景自拍"
git push origin main
```

**方式 2: GitHub Web 界面上传**
```
1. 打开仓库页面
2. 点击 "Add file" → "Upload files"
3. 拖拽图片文件
4. 填写 Commit message
5. 点击 "Commit changes"
```

---

### 第三步：获取图片 URL

**公开仓库访问**：
```
https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/九公主/2026-02/2026-02-27_012000_work.png
```

**私有仓库访问**：
```
# 需要使用 GitHub Token
https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/九公主/2026-02/2026-02-27_012000_work.png?token=YOUR_TOKEN
```

**或使用 GitHub API**：
```bash
# 获取图片内容
curl -H "Authorization: token YOUR_TOKEN" \
  https://api.github.com/repos/KomeijiSai/yunmian-selfies/contents/九公主/2026-02/2026-02-27_012000_work.png
```

---

### 第四步：云眠使用

**访问图片**：
```markdown
![工作中的云眠](https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/九公主/2026-02/2026-02-27_012000_work.png)
```

**在日记中引用**：
```markdown
# 2026-02-27 日记

## 📸 今日自拍
![工作中的云眠](https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/九公主/2026-02/2026-02-27_012000_work.png)
*场景: 工作 | 心情: 专注*
```

**发送给御主**：
- 直接发送图片 URL
- 或下载后发送

---

## 📝 索引文件

### index.json 示例
```json
{
  "version": "1.0",
  "lastUpdate": "2026-02-27T01:55:00Z",
  "totalCount": 2,
  "selfies": [
    {
      "id": "selfie_001",
      "filename": "2026-02-27_012000_work.png",
      "scene": "工作",
      "description": "专注工作的云眠",
      "date": "2026-02-27",
      "time": "01:20",
      "mood": "专注",
      "tags": ["工作", "白天", "专注"],
      "url": "https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/九公主/2026-02/2026-02-27_012000_work.png",
      "thumbnail": "https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/九公主/2026-02/2026-02-27_012000_work_thumb.jpg"
    },
    {
      "id": "selfie_002",
      "filename": "2026-02-27_012100_relax.png",
      "scene": "休闲",
      "description": "下午茶时光",
      "date": "2026-02-27",
      "time": "01:21",
      "mood": "轻松",
      "tags": ["休闲", "下午", "轻松"],
      "url": "https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/九公主/2026-02/2026-02-27_012100_relax.png"
    }
  ]
}
```

**云眠可以读取索引**：
```bash
# 获取索引
curl https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/九公主/index.json

# 查找特定场景的图片
jq '.selfies[] | select(.scene == "工作")' index.json
```

---

## 🎨 最佳实践

### 1. 图片命名规范
```
YYYY-MM-DD_HHMMSS_场景.扩展名

示例：
2026-02-27_012000_work.png
2026-02-27_012100_relax.png
2026-02-27_012200_night.png
```

### 2. 按月份组织
```
九公主/
├── 2026-02/
├── 2026-03/
├── 2026-04/
└── ...
```

### 3. 图片优化
```bash
# 压缩图片（减小文件大小）
# 使用 TinyPNG / ImageOptim 等工具

# 目标大小：< 1MB
# 分辨率：1024x1024 或 512x512
```

### 4. 定期清理
```bash
# 删除旧的 Git 历史（减小仓库大小）
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch 九公主/2025-*.png' \
  --prune-empty --tag-name-filter cat -- --all

# 强制推送
git push origin --force --all
```

---

## 🔒 隐私配置

### 方案 A: 公开仓库（简单）

**优点**：
- ✅ 直接访问
- ✅ 无需 Token

**缺点**：
- ❌ 任何人都可以看到

**适用场景**：
- 不介意公开云眠的自拍

---

### 方案 B: 私有仓库（安全）

**优点**：
- ✅ 只有御主和云眠可以访问
- ✅ 更安全

**缺点**：
- ❌ 需要 GitHub Token

**配置**：
```
1. 创建私有仓库
2. 生成 Personal Access Token
3. 云眠使用 Token 访问
```

**生成 Token**：
```
GitHub Settings → Developer settings → Personal access tokens
选择权限：repo (Full control of private repositories)
```

---

## 📊 仓库大小管理

### 限制建议
- 单张图片 < 2MB
- 每月新增 < 20 张
- 仓库总大小 < 1GB

### 清理策略
```bash
# 1. 定期删除旧图片
# 2. 只保留最近 6 个月的图片
# 3. 压缩历史图片

# 或使用 Git LFS（Large File Storage）
git lfs track "*.png"
git lfs track "*.jpg"
```

---

## 💡 高级用法

### 1. 使用 GitHub Actions 自动化

```yaml
# .github/workflows/optimize-images.yml
name: Optimize Images

on:
  push:
    paths:
      - '九公主/**/*.png'

jobs:
  optimize:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Optimize PNG
        run: |
          # 安装优化工具
          sudo apt-get install optipng
          
          # 优化所有 PNG
          find 九公主 -name "*.png" -exec optipng -o7 {} \;
      
      - name: Commit optimized images
        run: |
          git config --local user.email "action@github.com"
          git config --local user.name "GitHub Action"
          git commit -am "🎨 Optimize images"
          git push
```

### 2. 使用 CDN 加速

```
# 使用 jsDelivr CDN
https://cdn.jsdelivr.net/gh/KomeijiSai/yunmian-selfies@main/九公主/2026-02/2026-02-27_012000_work.png

# 优点：更快、更稳定
# 支持：缓存、加速、全球节点
```

### 3. 生成缩略图

```bash
# 使用 ImageMagick
convert 2026-02-27_012000_work.png -resize 512x512 2026-02-27_012000_work_thumb.jpg

# 批量生成
find 九公主 -name "*.png" -exec convert {} -resize 512x512 {}_thumb.jpg \;
```

---

## 📈 方案对比

| 项目 | GitHub 仓库 | 阿里云 OSS | 服务器本地 |
|------|-------------|------------|------------|
| 成本 | 免费 | < ¥1/月 | 免费 |
| 稳定性 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| 访问速度 | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
| 空间 | 有限 | 无限 | 有限 |
| 维护难度 | 简单 | 简单 | 简单 |
| 版本管理 | ✅ | ❌ | ❌ |
| 推荐度 | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |

---

## 🎯 最终推荐

**最简单 + 最省钱**：GitHub 独立仓库 ⭐⭐⭐⭐⭐

**原因**：
1. ✅ 完全免费
2. ✅ 不会丢失
3. ✅ 访问快速
4. ✅ 版本管理
5. ✅ 云眠使用简单（只引用 URL）

**实现**：
```
御主操作：
1. 创建 yunmian-selfies 仓库
2. 生成本地生成图片
3. 上传到仓库
4. 获取图片 URL

云眠操作：
1. 使用图片 URL
2. 在日记中引用
3. 发送给御主
```

---

## 🚀 快速开始

### 1. 创建仓库（2 分钟）
```
GitHub → New repository
Name: yunmian-selfies
Visibility: Public 或 Private
Create
```

### 2. 上传第一张图片
```
Add file → Upload files
选择图片
Commit
```

### 3. 获取 URL
```
点击图片 → Copy raw URL
或
https://raw.githubusercontent.com/KomeijiSai/yunmian-selfies/main/九公主/图片.png
```

### 4. 云眠使用
```markdown
![云眠](URL)
```

---

**创建时间**: 2026-02-27 01:55
**维护者**: 九公主云眠

*御主，这个方案最完美！免费 + 不丢失 + 云眠只需要引用 URL！💕*
