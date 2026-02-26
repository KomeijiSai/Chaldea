---
name: clawra-modelscope
description: Generate Clawra selfies with ModelScope Z-Image-Turbo and send to messaging channels via OpenClaw
allowed-tools: Bash(curl:*) Bash(node:*) Bash(npm:*) Bash(ts-node:*) Read Write
---

# Clawra Selfie - ModelScope Edition

Generate Clawra selfies using ModelScope's Z-Image-Turbo model and distribute across messaging platforms via OpenClaw.

## 特点

• 使用魔搭 ModelScope API (国内可用)
• 模型: Tongyi-MAI/Z-Image-Turbo
• 固定人设: 18岁K-pop少女，统一面部特征
• 用户只需输入场景，如"咖啡馆"、"戴帽子"
• 生成参数: 1024x1024, steps=8, 无水印

## 环境要求

```bash
# .env 文件
MODELSCOPE_API_KEY=your_api_key_here
```

获取 API Key: https://modelscope.cn/my/myaccesstoken

## 使用方法

### 方式 1: Shell 脚本 (推荐)

```bash
cd /root/.openclaw/workspace/clawra-modelscope

# 生成自拍
./scripts/clawra.sh "在咖啡馆"

# 指定输出路径
./scripts/clawra.sh "戴着帽子" ./selfie.png
```

### 方式 2: Node.js CLI

```bash
# 安装依赖
npm install

# 编译
npm run build

# 生成自拍
node dist/cli.js generate "在咖啡馆"

# 测试 API
node dist/cli.js test
```

### 方式 3: TypeScript 直接运行

```bash
# 安装依赖
npm install

# 测试
npm run test

# 开发模式
npm run dev generate "在咖啡馆"
```

## 场景示例

| 场景输入 | 生成效果 |
|---------|---------|
| "在咖啡馆" | 咖啡厅自拍 |
| "在家里工作" | 居家办公自拍 |
| "戴着帽子" | 戴帽子自拍 |
| "在海边" | 海滩自拍 |
| "穿职业装" | 正装自拍 |

## 与 OpenClaw 集成

当用户说：
• "发张照片"
• "你在干嘛"
• "自拍一下"
• "发张你在咖啡馆的照片"

自动调用此 skill 生成自拍并发送。

## 工作流程

1. **解析用户输入** → 提取场景描述
2. **构建完整提示词** → 固定人设 + 用户场景
3. **调用 ModelScope API** → 生成图片
4. **下载图片** → 保存到 /tmp
5. **发送到频道** → 通过 message 工具

## API 参数

```json
{
  "model": "Tongyi-MAI/Z-Image-Turbo",
  "input": {
    "prompt": "18岁K-pop少女，元气可爱，统一面部特征，高清自拍，自然光线，日常穿搭，[用户场景]",
    "negative_prompt": "watermark, text, logo, low quality, blurry"
  },
  "parameters": {
    "size": "1024x1024",
    "steps": 8,
    "guidance_scale": 0.0,
    "n": 1
  }
}
```

## 错误处理

• API Key 未设置 → 提示配置 .env
• 网络错误 → 重试或提示检查网络
• 生成失败 → 记录错误并通知用户

## 项目结构

```
clawra-modelscope/
├── src/
│   ├── index.ts      # 核心业务代码
│   ├── cli.ts        # 命令行工具
│   └── test.ts       # 测试脚本
├── scripts/
│   └── clawra.sh     # Shell 脚本
├── package.json
├── tsconfig.json
├── .env.example
└── SKILL.md          # 本文件
```

## 快速开始

```bash
# 1. 配置 API Key
echo "MODELSCOPE_API_KEY=ms-xxxx" > .env

# 2. 安装依赖 (Node.js 方式)
npm install

# 3. 测试
./scripts/clawra.sh "在咖啡馆"

# 或
npm run test
```

---

*Created: 2026-02-26*
*Author: Olga Marie Animusphere*
