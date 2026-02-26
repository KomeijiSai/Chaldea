# Leonardo.ai 注册指南

## 注册步骤

1. **访问官网**: https://leonardo.ai/
2. **点击注册**: "Get Started" 或 "Sign Up"
3. **邮箱验证**: 使用邮箱注册
4. **获取 API Key**:
   - 登录后访问: https://app.leonardo.ai/api-keys
   - 点击 "Create API Key"
   - 复制 API Key

## 配置方法

编辑 `/root/.openclaw/workspace/.env`:
```bash
LEONARDO_API_KEY=your_api_key_here
```

## 免费额度

- 每天 150 tokens
- 约 150 张图片/天
- 完全免费

## 测试命令

```bash
./scripts/免费自拍.sh "御花园"
```

---

*创建时间: 2026-02-26*
