# 🎨 图像生成 API 注册指南

## 📋 需要注册的 API 列表

| API | 免费额度 | 质量 | 推荐度 |
|-----|---------|------|-------|
| Leonardo.ai | 150张/天 | ⭐⭐⭐⭐⭐ | 🔥 强烈推荐 |
| Stability AI (DreamStudio) | £10 (约1000张) | ⭐⭐⭐⭐⭐ | 🔥 强烈推荐 |
| Hugging Face | 无限制 | ⭐⭐⭐⭐ | ✅ 推荐 |
| 火山引擎 | 待确认 | ⭐⭐⭐⭐ | ⚠️ 待测试 |
| RunwayML | 125张/月 | ⭐⭐⭐⭐ | ✅ 推荐 |
| Replicate | 付费 | ⭐⭐⭐⭐⭐ | 💰 备选 |

---

## 1️⃣ Leonardo.ai（首选推荐）

### 注册步骤

**官网**: https://leonardo.ai/

1. **访问官网**
   ```
   https://leonardo.ai/
   ```

2. **点击注册**
   - 点击右上角 "Get Started" 或 "Sign Up"
   - 使用邮箱注册（推荐 Google 邮箱）

3. **邮箱验证**
   - 检查邮箱
   - 点击验证链接

4. **登录账号**
   ```
   https://app.leonardo.ai/
   ```

5. **获取 API Key**
   ```
   https://app.leonardo.ai/api-keys
   ```
   - 点击 "Create API Key"
   - 输入名称（如 "OpenClaw"）
   - 复制生成的 API Key

6. **配置到 OpenClaw**
   ```bash
   # 编辑 .env 文件
   nano /root/.openclaw/workspace/.env
   
   # 添加这一行
   LEONARDO_API_KEY=your_api_key_here
   ```

### 免费额度
- ✅ 每天 150 tokens（约150张图）
- ✅ 每月 4500 tokens
- ✅ 完全免费

### API 文档
```
https://leonardo.ai/docs/api
```

---

## 2️⃣ Stability AI (DreamStudio)

### 注册步骤

**官网**: https://dreamstudio.ai/

1. **访问官网**
   ```
   https://dreamstudio.ai/
   ```

2. **点击注册**
   - 点击 "Sign Up"
   - 使用邮箱注册

3. **验证邮箱**
   - 检查邮箱
   - 点击验证链接

4. **登录账号**
   ```
   https://dreamstudio.ai/account
   ```

5. **获取 API Key**
   - 登录后自动跳转到账号页面
   - 找到 "API Key" 部分
   - 点击 "Copy" 复制

6. **配置到 OpenClaw**
   ```bash
   # 编辑 .env 文件
   nano /root/.openclaw/workspace/.env
   
   # 添加这一行
   STABILITY_API_KEY=your_api_key_here
   ```

### 免费额度
- ✅ 注册送 £10 credit
- ✅ 约 1000+ 张图
- 💰 超出后 £0.01/张

### API 文档
```
https://platform.stability.ai/docs/
```

---

## 3️⃣ Hugging Face（已配置）

### 确认配置

1. **检查 API Key**
   ```bash
   cat /root/.openclaw/workspace/.env | grep HF_TOKEN
   ```

2. **如果没有，注册步骤**：
   
   **官网**: https://huggingface.co/
   
   - 访问 https://huggingface.co/join
   - 使用邮箱注册
   - 访问 https://huggingface.co/settings/tokens
   - 创建 Access Token（Read权限）
   
3. **配置**
   ```bash
   # 添加到 .env
   HF_TOKEN=your_token_here
   ```

### 免费额度
- ✅ Inference API 完全免费
- ✅ 无限制调用
- ⚠️ 有速率限制

---

## 4️⃣ 火山引擎（字节跳动）

### 注册步骤

**官网**: https://www.volcengine.com/

1. **访问官网**
   ```
   https://www.volcengine.com/
   ```

2. **点击注册**
   - 使用手机号注册（国内服务）

3. **实名认证**
   - 上传身份证
   - 完成认证

4. **开通服务**
   ```
   https://console.volcengine.com/ark
   ```
   - 开通 "方舟" 大模型服务
   - 查看图像生成 API

5. **获取 API Key**
   - 访问 https://console.volcengine.com/iam/keymanage/
   - 创建 AccessKey
   - 复制 AccessKey ID 和 Secret

6. **配置到 OpenClaw**
   ```bash
   # 添加到 .env
   VOLCENGINE_ACCESS_KEY_ID=your_access_key_id
   VOLCENGINE_ACCESS_KEY_SECRET=your_access_key_secret
   ```

### 免费额度
- ⚠️ 需要确认（可能需要实名认证后才有）
- 💰 国内服务，速度快

---

## 5️⃣ RunwayML

### 注册步骤

**官网**: https://runwayml.com/

1. **访问官网**
   ```
   https://runwayml.com/
   ```

2. **点击注册**
   - 点击 "Sign Up"
   - 使用邮箱注册

3. **验证邮箱**
   - 检查邮箱
   - 点击验证链接

4. **获取 API Key**
   ```
   https://runwayml.com/account/api
   ```
   - 找到 API Key 部分
   - 复制 Key

5. **配置到 OpenClaw**
   ```bash
   # 添加到 .env
   RUNWAY_API_KEY=your_api_key_here
   ```

### 免费额度
- ✅ 每月 125 credits
- ✅ 约 125 张图/月
- 💰 超出后付费

---

## 6️⃣ Replicate（备选）

### 注册步骤

**官网**: https://replicate.com/

1. **访问官网**
   ```
   https://replicate.com/
   ```

2. **点击注册**
   - 使用 GitHub 账号登录（推荐）
   - 或邮箱注册

3. **获取 API Token**
   ```
   https://replicate.com/account/api-tokens
   ```
   - 点击 "Create token"
   - 复制 Token

4. **配置到 OpenClaw**
   ```bash
   # 添加到 .env
   REPLICATE_API_TOKEN=your_token_here
   ```

### 免费额度
- ❌ 无免费额度
- 💰 按秒计费（约 $0.01/张）

---

## 📝 配置汇总

完成所有注册后，`.env` 文件应包含：

```bash
# Leonardo.ai
LEONARDO_API_KEY=your_leonardo_key

# Stability AI (DreamStudio)
STABILITY_API_KEY=your_stability_key

# Hugging Face
HF_TOKEN=your_huggingface_token

# 火山引擎
VOLCENGINE_ACCESS_KEY_ID=your_volcengine_id
VOLCENGINE_ACCESS_KEY_SECRET=your_volcengine_secret

# RunwayML
RUNWAY_API_KEY=your_runway_key

# Replicate
REPLICATE_API_TOKEN=your_replicate_token
```

---

## 🧪 测试脚本

完成配置后，运行测试脚本：

```bash
# 一键测试所有 API
./scripts/test_all_apis.sh
```

测试脚本会：
1. 逐个测试每个 API
2. 生成对比图
3. 记录生成时间和质量
4. 输出对比报告

---

## ⏱️ 预计注册时间

| API | 注册时间 | 难度 |
|-----|---------|------|
| Leonardo.ai | 5分钟 | ⭐ 简单 |
| Stability AI | 5分钟 | ⭐ 简单 |
| Hugging Face | 3分钟 | ⭐ 简单 |
| 火山引擎 | 10分钟 | ⭐⭐ 需实名 |
| RunwayML | 5分钟 | ⭐ 简单 |
| Replicate | 3分钟 | ⭐ 简单 |

**总计**: 约 30 分钟

---

## 💡 优先级建议

**必须注册**（免费额度大）:
1. Leonardo.ai（150张/天）
2. Stability AI（£10免费）

**建议注册**（有免费额度）:
3. RunwayML（125张/月）

**可选**（已有或需要付费）:
4. Hugging Face（已配置）
5. 火山引擎（需实名）
6. Replicate（付费）

---

## 🔐 安全提示

- ✅ 所有 API Key 都存储在 `.env` 文件中
- ✅ `.env` 文件不会被 git 提交
- ✅ 不要在聊天中分享 API Key
- ✅ 定期更换 API Key

---

*创建时间: 2026-02-26*
*用途: API 注册和测试指南*
