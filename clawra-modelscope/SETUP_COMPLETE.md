# Clawra ModelScope 完整配置

## ✅ 已完成

项目已配置完成，包含两种 API 实现：

### 1. 阿里云百炼 (推荐 - 已验证可用)
- 脚本: `scripts/clawra-bailian.sh`
- API: 通义万相 (wanx-v1)
- 状态: ✅ 测试成功

### 2. ModelScope Z-Image-Turbo (待修复)
- 脚本: `scripts/clawra.sh`
- 问题: API 返回成功但无图片 URL
- 状态: ⚠️ 等待官方修复

## 📦 项目结构

```
clawra-modelscope/
├── src/
│   ├── index.ts      # 核心业务 (TypeScript)
│   ├── cli.ts        # 命令行工具
│   └── test.ts       # 测试脚本
├── scripts/
│   ├── clawra-bailian.sh  # 阿里云百炼 (推荐)
│   ├── clawra.sh          # ModelScope (待修复)
│   └── clawra.py          # Python 版本
├── package.json
├── tsconfig.json
├── .env
├── .env.example
├── SKILL.md
├── SKILL-BAILIAN.md
└── README.md
```

## 🚀 快速开始

### 方式 1: Shell 脚本 (推荐)

```bash
cd /root/.openclaw/workspace/clawra-modelscope

# 生成自拍
./scripts/clawra-bailian.sh "at a cozy cafe"

# 指定输出路径
./scripts/clawra-bailian.sh "wearing a hat" ./selfie.png
```

### 方式 2: TypeScript

```bash
# 安装依赖
npm install

# 编译
npm run build

# 测试
npm run test

# 生成自拍
node dist/cli.js generate "at cafe"
```

## 📝 环境配置

`.env` 文件:

```bash
# 阿里云百炼 (推荐)
ALIYUN_BAILIAN_API_KEY=sk-xxxx

# ModelScope (待修复)
MODELSCOPE_API_KEY=ms-xxxx
```

## 🎯 使用示例

```bash
# 场景示例
./scripts/clawra-bailian.sh "at a cozy cafe"
./scripts/clawra-bailian.sh "working at home"
./scripts/clawra-bailian.sh "wearing a hat"
./scripts/clawra-bailian.sh "at the beach"
./scripts/clawra-bailian.sh "in professional attire"
```

## ✅ 测试结果

```
📸 生成 Clawra 自拍...
场景: at a cozy cafe
完整提示词: photorealistic selfie of an 18-year-old kpop idol girl, at a cozy cafe, natural lighting, high quality, smartphone photo
输出路径: /tmp/clawra-selfie-20260226012153.png

任务 ID: 48d9cf31-8384-47e2-ad41-699dc3de5f7e
等待生成...
  [1/12] 状态: RUNNING
  [2/12] 状态: RUNNING
  [3/12] 状态: RUNNING
  [4/12] 状态: RUNNING
  [5/12] 状态: RUNNING
  [6/12] 状态: SUCCEEDED

📥 下载图片: https://dashscope-result-bj.oss-cn-beijing.aliyuncs.com/...

✅ 生成成功！
   路径: /tmp/clawra-selfie-20260226012153.png
   大小: 1.5M
```

## 🔧 固定配置

- **人设**: 18岁 K-pop 少女，元气可爱
- **尺寸**: 1024x1024
- **风格**: 写实 (photography)
- **质量**: 高清，自然光线

## 📚 API 文档

- 阿里云百炼: https://bailian.console.aliyun.com/
- ModelScope: https://modelscope.cn/docs/model-service/API-Inference/intro

## 🔄 下一步

1. ✅ 项目已配置完成
2. ✅ 阿里云百炼 API 可用
3. ⏳ 等待 ModelScope API 修复
4. 📝 可集成到 OpenClaw skill

---

*配置完成: 2026-02-26 01:22*
*作者: Olga Marie Animusphere*
