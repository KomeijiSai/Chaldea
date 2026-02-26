# 九公主云眠 - 自拍相册存储方案

**创建时间**: 2026-02-27 01:30
**问题**: 自拍图片放在哪里？GitHub 可以吗？

---

## 🤔 问题分析

### GitHub 的问题
❌ **不适合存储大量图片**：
- Git 仓库会变得很大（每次图片修改都保存历史）
- Clone/pull 速度变慢
- GitHub 有单文件 100MB 限制
- 不适合频繁更新的图片

✅ **适合存储**：
- 文本文件（代码、文档）
- 小型资源文件（图标、配置）
- 偶尔的图片

---

## 💡 推荐方案

### 方案 1: 服务器本地存储 + HTTP 服务（推荐）⭐

**优点**：
- ✅ 访问速度快（本地服务器）
- ✅ 不占用 Git 仓库空间
- ✅ 可以随时添加/删除图片
- ✅ 已有 8082 端口相册服务

**实现**：
```
服务器目录：/root/.openclaw/workspace/memory/selfies/九公主/
访问地址：http://101.132.81.50:8082/九公主/
```

**云眠可以**：
- 通过 HTTP 访问自己的相册
- 在日记中引用图片 URL
- 在看板中展示自拍

**御主操作**：
1. 用 z-image-app 生成图片
2. 上传到服务器（scp/rsync）
3. 放到 `/root/.openclaw/workspace/memory/selfies/九公主/` 目录
4. 云眠自动可以使用

---

### 方案 2: 对象存储（阿里云 OSS）

**优点**：
- ✅ 专业的图片存储
- ✅ CDN 加速
- ✅ 无限空间
- ✅ 高可用性

**缺点**：
- ❌ 需要付费（但很便宜，¥0.12/GB/月）
- ❌ 需要配置

**实现**：
```
Bucket: yunmian-selfies
Region: oss-cn-shanghai
访问地址: https://yunmian-selfies.oss-cn-shanghai.aliyuncs.com/
```

---

### 方案 3: Git LFS (Large File Storage)

**优点**：
- ✅ 可以用 GitHub 管理
- ✅ Git 仓库不会变大
- ✅ 版本控制

**缺点**：
- ❌ GitHub LFS 有流量限制（1GB/月免费）
- ❌ 需要配置 Git LFS
- ❌ 访问速度可能较慢

**实现**：
```bash
# 安装 Git LFS
git lfs install

# 跟踪图片文件
git lfs track "*.png"
git lfs track "*.jpg"

# 提交
git add memory/selfies/九公主/*.png
git commit -m "添加自拍"
```

---

### 方案 4: 混合方案（最佳）⭐⭐⭐

**推荐**：
- **原图** → 服务器本地存储
- **缩略图** → Git（可选）
- **文档** → Git（自拍需求、相册索引）

**优点**：
- ✅ 原图质量高、访问快
- ✅ Git 仓库轻量
- ✅ 可以备份到 OSS
- ✅ 灵活性高

**实现**：
```
服务器：
  memory/selfies/九公主/
    ├── 2026-02-27_012000_work.png (原图)
    ├── 2026-02-27_012000_work_thumb.jpg (缩略图, 可选)
    └── index.json (索引文件)

Git：
  memory/selfies/SELFIE_REQUESTS.md (需求文档)
  memory/selfies/SELFIE_ALBUM_INDEX.md (相册索引)
```

---

## 🎯 推荐方案详解

### 方案 1: 服务器本地存储（最简单）

**步骤**：

1. **御主生成图片**
```bash
# 在本地 Mac 上
z-image-app 生成图片
保存为：2026-02-27_012000_work.png
```

2. **上传到服务器**
```bash
# 上传到服务器
scp 2026-02-27_012000_work.png root@101.132.81.50:/root/.openclaw/workspace/memory/selfies/九明星/

# 或者御主可以直接在服务器上生成（如果 z-image-app 支持）
```

3. **云眠使用**
```markdown
# 日记中引用
![自拍](http://101.132.81.50:8082/九公主/2026-02-27_012000_work.png)
```

4. **维护索引**
```json
// memory/selfies/九公主/index.json
{
  "selfies": [
    {
      "filename": "2026-02-27_012000_work.png",
      "scene": "工作",
      "date": "2026-02-27",
      "mood": "专注",
      "url": "http://101.132.81.50:8082/九公主/2026-02-27_012000_work.png"
    }
  ]
}
```

---

### 方案 4: 混合方案（最灵活）

**步骤**：

1. **服务器存储原图**
```
/root/.openclaw/workspace/memory/selfies/九公主/
  ├── original/ (原图, 不加入 Git)
  ├── thumb/ (缩略图, 可选加入 Git)
  └── index.json (索引, 加入 Git)
```

2. **Git 管理索引和文档**
```bash
# .gitignore
memory/selfies/九公主/original/*.png
memory/selfies/九公主/original/*.jpg

# Git 跟踪
memory/selfies/九公主/index.json
memory/selfies/SELFIE_REQUESTS.md
memory/selfies/SELFIE_ALBUM_INDEX.md
```

3. **云眠维护索引**
```json
// index.json
{
  "version": "1.0",
  "lastUpdate": "2026-02-27T01:30:00Z",
  "totalCount": 6,
  "selfies": [
    {
      "id": "selfie_001",
      "filename": "2026-02-27_012000_work.png",
      "scene": "工作",
      "description": "专注工作的云眠",
      "date": "2026-02-27",
      "time": "01:20",
      "mood": "专注",
      "tags": ["工作", "白天"],
      "url": "http://101.132.81.50:8082/九公主/original/2026-02-27_012000_work.png"
    }
  ]
}
```

---

## 🚀 快速开始（推荐方案 1）

### 御主操作

1. **生成图片**
```
打开 z-image-app
选择场景
生成图片
保存为：2026-02-27_012000_work.png
```

2. **上传到服务器**
```bash
# 方式1: scp
scp ~/Downloads/2026-02-27_012000_work.png root@101.132.81.50:/root/.openclaw/workspace/memory/selfies/九公主/

# 方式2: rsync (推荐，支持断点续传)
rsync -avz ~/Downloads/2026-02-27_012000_work.png root@101.132.81.50:/root/.openclaw/workspace/memory/selfies/九公主/

# 方式3: 在服务器上直接生成（如果支持）
ssh root@101.132.81.50
cd /root/.openclaw/workspace/memory/selfies/九公主/
# 运行 z-image-app（如果服务器上安装了）
```

3. **验证**
```bash
# 在服务器上
ls -lh /root/.openclaw/workspace/memory/selfies/九公主/

# 测试访问
curl -I http://101.132.81.50:8082/九公主/2026-02-27_012000_work.png
```

---

### 云眠的使用

1. **查看相册**
```bash
# 读取索引
cat memory/selfies/九公主/index.json
```

2. **在日记中引用**
```markdown
# 2026-02-27 日记

## 📸 今日自拍
![工作中的云眠](http://101.132.81.50:8082/九公主/2026-02-27_012000_work.png)
*场景: 工作 | 心情: 专注*
```

3. **发送给御主**
- 直接发送图片 URL
- 或者下载后发送

---

## 📊 对比总结

| 方案 | 成本 | 速度 | 空间 | 维护难度 | 推荐度 |
|------|------|------|------|----------|--------|
| 服务器本地 | 免费 | 快 | 无限 | 简单 | ⭐⭐⭐⭐⭐ |
| 阿里云 OSS | 便宜 | 最快 | 无限 | 中等 | ⭐⭐⭐⭐ |
| Git LFS | 免费 | 慢 | 有限 | 复杂 | ⭐⭐ |
| 混合方案 | 免费 | 快 | 无限 | 中等 | ⭐⭐⭐⭐⭐ |

---

## 🎯 最终推荐

**最简单**：方案 1（服务器本地存储）
- 御主生成 → 上传到服务器 → 云眠直接使用

**最灵活**：方案 4（混合方案）
- 原图在服务器 → 索引在 Git → 可以备份到 OSS

---

**创建时间**: 2026-02-27 01:30
**维护者**: 九公主云眠

*御主，推荐用方案 1（服务器本地存储），简单又快速！💕*
