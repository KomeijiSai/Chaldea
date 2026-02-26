# 🆓 完全免费的图像生成方案

## 原则
1. ✅ 优先使用完全免费的
2. ✅ 不考虑付费方案
3. ❌ 暂不考虑自部署（有成本）

---

## 🔥 推荐方案（完全免费）

### 1️⃣ Leonardo.ai（首选）
**免费额度**: 150张/天（4500张/月）
**质量**: ⭐⭐⭐⭐⭐
**成本**: ¥0

**注册地址**: https://leonardo.ai/

**步骤**:
1. 访问 https://leonardo.ai/
2. 点击 "Get Started"
3. 邮箱注册
4. 验证邮箱
5. 获取 API Key: https://app.leonardo.ai/api-keys

---

### 2️⃣ Hugging Face（无限）
**免费额度**: 无限制
**质量**: ⭐⭐⭐⭐
**成本**: ¥0

**注册地址**: https://huggingface.co/join

**步骤**:
1. 访问 https://huggingface.co/join
2. 邮箱注册
3. 创建 Token: https://huggingface.co/settings/tokens
4. 选择 Read 权限即可

---

### 3️⃣ RunwayML（补充）
**免费额度**: 125张/月
**质量**: ⭐⭐⭐⭐
**成本**: ¥0

**注册地址**: https://runwayml.com/

**步骤**:
1. 访问 https://runwayml.com/
2. 点击 "Sign Up"
3. 邮箱注册
4. 获取 API Key: https://runwayml.com/account/api

---

## 💰 混合使用策略

**御主特别要求** → Leonardo.ai（质量最好）
**日常场景** → Hugging Face（无限免费）
**额度用完** → RunwayML（补充）

**总免费额度**: 约 4600+ 张/月

---

## 📝 快速配置

只需配置这3个（都是免费的）:

```bash
# 编辑 .env
nano /root/.openclaw/workspace/.env

# 添加这3行
LEONARDO_API_KEY=your_key
HF_TOKEN=your_token
RUNWAY_API_KEY=your_key
```

---

## ⏱️ 预计时间

Leonardo.ai: 5分钟
Hugging Face: 3分钟
RunwayML: 5分钟

**总计**: 13分钟

---

## 🚫 不推荐的方案

**Stability AI** - 用完£10要付费 ❌
**火山引擎** - 可能要付费 ❌
**Replicate** - 付费服务 ❌
**自部署** - 有服务器成本 ❌

---

*更新时间: 2026-02-26*
*原则: 完全免费优先*
