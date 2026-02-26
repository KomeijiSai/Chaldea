# ModelScope API Inference 调研报告

## 🔍 调研结果

### 问题 1：Z-Image-Turbo 不支持 API
```json
{
  "SupportApiInference": false,
  "SupportDashInference": 0
}
```

### 问题 2：错误码 40212
测试多个模型都返回 `submit failed with code: 40212`

**可能原因**：
- 账户配额限制
- 需要开通或充值
- API 权限不足

### 测试结果

| 模型 | 状态 |
|------|------|
| Z-Image-Turbo | ❌ 不支持 API |
| stable-diffusion-xl-base-1.0 | ❌ 40212 错误 |
| stable-diffusion-2-1 | ❌ 40212 错误 |
| kandinsky-2-1 | ❌ Rate limit |

## 💡 解决方案

### 方案 A：继续使用阿里云百炼（推荐）

**优势**：
- ✅ 已验证可用
- ✅ 稳定可靠
- ✅ 通义万相质量好
- ✅ 国内访问快

**成本**：
- 免费额度：100 张图
- 付费：按量计费

**使用方法**：
```bash
cd /root/.openclaw/workspace/clawra-modelscope
./scripts/clawra-bailian.sh "at cafe"
```

### 方案 B：充值 ModelScope

如果御主想用 ModelScope：
1. 访问 https://modelscope.cn/
2. 开通 API Inference 服务
3. 充值账户
4. 然后可以尝试其他支持的模型

### 方案 C：本地部署

需要：
- GPU 服务器（16G+ VRAM）
- 下载模型（10GB+）
- Python 环境

### 方案 D：使用其他平台

- Hugging Face Inference API
- Replicate
- Stability AI
- Midjourney

## 📊 对比

| 方案 | 可用性 | 成本 | 速度 | 质量 |
|------|--------|------|------|------|
| 阿里云百炼 | ✅ | 免费/低 | 快 | 高 |
| ModelScope | ⚠️ 需充值 | ? | ? | ? |
| 本地部署 | ⚠️ 需GPU | 免费 | 中 | 高 |
| 其他平台 | ✅ | 付费 | 快 | 高 |

## 🎯 建议

**短期**：继续使用阿里云百炼
- 立即可用
- 已经配置好
- 测试通过

**长期**：根据使用情况考虑
- 如果需求大，可以充值 ModelScope 或其他平台
- 如果有 GPU 服务器，可以本地部署

---

*调研时间: 2026-02-26 01:55*
