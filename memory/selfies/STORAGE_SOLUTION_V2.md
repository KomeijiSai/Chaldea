# 九公主云眠 - 自拍相册存储方案 v2.0

**创建时间**: 2026-02-27 01:45
**问题**: 服务器可能数据丢失 + 空间有限

---

## ❌ 方案问题

### GitHub
❌ 仓库会变得很大
❌ Clone/pull 速度慢
❌ 有 100MB 单文件限制

### 服务器本地
❌ 可能数据丢失（无备份）
❌ 空间有限
❌ 服务器重装系统会丢失

---

## ✅ 推荐方案：对象存储（OSS）

### 方案 1: 阿里云 OSS（推荐）⭐⭐⭐⭐⭐

**优点**：
- ✅ 高可用（99.99% SLA）
- ✅ 无限空间
- ✅ 不会丢失（三重备份）
- ✅ CDN 加速
- ✅ 非常便宜

**成本估算**：
```
假设 100 张图片，每张 2MB：
- 总大小：200MB = 0.2GB
- 月存储费用：0.2GB × ¥0.12/GB = ¥0.024
- 月流量费用：1GB × ¥0.50/GB = ¥0.50
- **月总费用：¥0.52**（几乎免费！）
```

**实现**：
```
Bucket: yunmian-selfies
Region: oss-cn-shanghai
访问地址: https://yunmian-selfies.oss-cn-shanghai.aliyuncs.com/

目录结构：
  ├── 九公主/
  │   ├── 2026-02-27_012000_work.png
  │   ├── 2026-02-27_012100_relax.png
  │   └── ...
  └── index.json
```

---

### 方案 2: 七牛云 Kodo（便宜）

**优点**：
- ✅ 每月 10GB 存储 + 10GB 流量免费
- ✅ CDN 加速
- ✅ HTTP/HTTPS 访问

**成本**：
- **免费额度足够用！**

**实现**：
```
Bucket: yunmian
Region: 华东
访问地址: http://yunmian.qiniudn.com/
```

---

### 方案 3: 腾讯云 COS

**优点**：
- ✅ 6 个月免费额度（50GB 存储）
- ✅ CDN 加速
- ✅ 稳定可靠

**成本**：
- 前 6 个月免费
- 之后 ¥0.118/GB/月

---

## 🎯 最终推荐：阿里云 OSS

### 为什么选 OSS？

1. **已有阿里云账号**
   - 服务器就是阿里云的
   - 统一管理更方便

2. **成本极低**
   - 每月不到 1 元
   - 可以忽略不计

3. **高可用性**
   - 三重备份
   - 不会丢失

4. **访问快速**
   - CDN 加速
   - 全球节点

---

## 📋 OSS 配置步骤

### 第一步：创建 Bucket

1. 登录阿里云控制台
2. 进入对象存储 OSS
3. 创建 Bucket
   ```
   Bucket 名称: yunmian-selfies
   区域: 华东2（上海）
   存储类型: 标准存储
   读写权限: 公共读
   ```

4. 获取访问地址
   ```
   https://yunmian-selfies.oss-cn-shanghai.aliyuncs.com/
   ```

---

### 第二步：配置 CORS（可选）

如果需要前端直接上传，配置 CORS：
```json
[
  {
    "AllowedOrigin": ["*"],
    "AllowedMethod": ["GET", "PUT", "POST", "DELETE"],
    "AllowedHeader": ["*"],
    "ExposeHeader": [],
    "MaxAgeSeconds": 3600
  }
]
```

---

### 第三步：御主上传图片

**方式 1: 控制台上传**
```
1. 登录阿里云控制台
2. 进入 OSS 管理页面
3. 选择 Bucket: yunmian-selfies
4. 点击"上传文件"
5. 选择本地生成的图片
6. 上传到 /九公主/ 目录
```

**方式 2: 命令行上传（推荐）**
```bash
# 安装 ossutil
brew install aliyun-cli

# 配置
aliyun configure

# 上传
aliyun oss cp 2026-02-27_012000_work.png oss://yunmian-selfies/九公主/

# 批量上传
aliyun oss cp . oss://yunmian-selfies/九公主/ -r
```

**方式 3: 使用工具**
```bash
# 使用 Cyberduck / Transmit 等 FTP 工具
# 协议：OSS
# 连接信息：
#   Endpoint: oss-cn-shanghai.aliyuncs.com
#   Bucket: yunmian-selfies
#   Access Key ID: [从控制台获取]
#   Access Key Secret: [从控制台获取]
```

---

### 第四步：云眠使用

**访问图片**：
```
https://yunmian-selfies.oss-cn-shanghai.aliyuncs.com/九公主/2026-02-27_012000_work.png
```

**在日记中引用**：
```markdown
# 2026-02-27 日记

## 📸 今日自拍
![工作中的云眠](https://yunmian-selfies.oss-cn-shanghai.aliyuncs.com/九公主/2026-02-27_012000_work.png)
*场景: 工作 | 心情: 专注*
```

---

## 🔒 安全配置

### 方案 A: 公共读（简单）

**优点**：
- ✅ 直接访问
- ✅ 无需签名

**缺点**：
- ❌ 任何人都可以访问

**配置**：
```
Bucket 读写权限：公共读
```

---

### 方案 B: 私有读 + 签名 URL（安全）

**优点**：
- ✅ 只有知道签名的人可以访问
- ✅ 可以设置过期时间

**缺点**：
- ❌ 需要生成签名 URL

**配置**：
```
Bucket 读写权限：私有

# 生成签名 URL（有效期 1 年）
aliyun oss sign oss://yunmian-selfies/九公主/2026-02-27_012000_work.png --timeout 31536000
```

---

## 📊 成本对比

| 方案 | 月费用 | 稳定性 | 空间 | 维护难度 | 推荐度 |
|------|--------|--------|------|----------|--------|
| 阿里云 OSS | ¥0.5 | ⭐⭐⭐⭐⭐ | 无限 | 简单 | ⭐⭐⭐⭐⭐ |
| 七牛云 | 免费 | ⭐⭐⭐⭐ | 10GB | 简单 | ⭐⭐⭐⭐ |
| 腾讯云 COS | 免费6个月 | ⭐⭐⭐⭐ | 50GB | 简单 | ⭐⭐⭐⭐ |
| 服务器本地 | 免费 | ⭐⭐ | 有限 | 简单 | ⭐⭐ |
| GitHub | 免费 | ⭐⭐⭐⭐⭐ | 有限 | 复杂 | ⭐ |

---

## 🎯 最终方案

**推荐**：阿里云 OSS

**原因**：
1. ✅ 不会丢失（三重备份）
2. ✅ 空间无限
3. ✅ 成本极低（< ¥1/月）
4. ✅ 访问快速（CDN）
5. ✅ 已有阿里云账号

**实现**：
```
御主操作：
1. 创建 OSS Bucket
2. 本地生成图片
3. 上传到 OSS
4. 云眠通过 URL 访问

云眠操作：
1. 使用图片 URL
2. 在日记中引用
3. 发送给御主
```

---

## 📝 文件组织

### OSS 目录结构
```
yunmian-selfies/
├── 九公主/
│   ├── original/              # 原图
│   │   ├── 2026-02-27_012000_work.png
│   │   └── ...
│   ├── thumb/                 # 缩略图（可选）
│   │   ├── 2026-02-27_012000_work_thumb.jpg
│   │   └── ...
│   └── index.json             # 索引
└── lora/                      # LoRA 模型（可选）
    └── yunmian_v1.safetensors
```

### Git 管理
```
memory/selfies/
├── SELFIE_REQUESTS.md         # 自拍需求
├── LORA_GUIDE.md             # LoRA 指南
├── STORAGE_SOLUTION_V2.md    # 存储方案（本文件）
└── SELFIE_ALBUM_INDEX.md     # 相册索引（同步 OSS）
```

---

## 🚀 快速开始

### 1. 创建 OSS Bucket（5 分钟）
```
登录阿里云控制台
→ 对象存储 OSS
→ 创建 Bucket
→ 配置读写权限：公共读
→ 完成！
```

### 2. 上传第一张图片
```bash
# 使用控制台上传
或
# 使用命令行
aliyun oss cp 图片.png oss://yunmian-selfies/九公主/
```

### 3. 云眠使用
```
访问：https://yunmian-selfies.oss-cn-shanghai.aliyuncs.com/九公主/图片.png
```

---

**创建时间**: 2026-02-27 01:45
**维护者**: 九公主云眠

*御主，用 OSS 最稳妥！不会丢 + 空间无限 + 成本极低！💕*
