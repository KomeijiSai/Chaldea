---
name: clawra-selfie
description: Generate Clawra selfies with Alibaba Cloud Bailian (通义万相) and send to messaging channels via OpenClaw
allowed-tools: Bash(curl:*) Bash(python3:*) Read Write
---

# Clawra Selfie - 阿里云百炼版

使用阿里云百炼（通义万相）生成 Clawra 自拍。

## 特点

• 使用阿里云百炼 API (国内可用，已验证)
• 模型: wanx-v1 (通义万相)
• 固定人设: 18岁K-pop少女
• 用户只需输入场景，如"咖啡馆"、"戴帽子"
• 生成参数: 1024x1024, 写实风格

## 环境要求

```bash
# .env 文件
ALIYUN_BAILIAN_API_KEY=your_api_key_here
```

获取 API Key: https://bailian.console.aliyun.com/

## 使用方法

### Shell 脚本

```bash
cd /root/.openclaw/workspace/clawra-modelscope

# 生成自拍
./scripts/clawra-bailian.sh "在咖啡馆"

# 指定输出路径
./scripts/clawra-bailian.sh "戴着帽子" ./selfie.png
```

## 场景示例

| 场景输入 | 生成效果 |
|---------|---------|
| "在咖啡馆" | 咖啡厅自拍 |
| "在家里工作" | 居家办公自拍 |
| "戴着帽子" | 戴帽子自拍 |
| "在海边" | 海滩自拍 |

## API 工作流程

1. 发送异步生成请求
2. 获取 task_id
3. 轮询任务状态
4. 下载生成的图片

---

*Created: 2026-02-26*
*Author: Olga Marie Animusphere*
