# Clawra ModelScope - 使用阿里云百炼

## ✅ 当前配置

**API**: 阿里云百炼（通义万相）
**状态**: 已配置完成，测试通过

## 🚀 快速使用

```bash
cd /root/.openclaw/workspace/clawra-modelscope

# 生成自拍
./scripts/clawra-bailian.sh "at a cozy cafe"

# 指定输出路径
./scripts/clawra-bailian.sh "wearing a hat" ./selfie.png

# 中文场景
./scripts/clawra-bailian.sh "在咖啡厅"
```

## 📝 配置文件

`.env`:
```bash
ALIYUN_BAILIAN_API_KEY=sk-xxxx
```

## 🎯 场景示例

| 场景 | 效果 |
|------|------|
| "at a cozy cafe" | 咖啡厅自拍 |
| "working at home" | 居家办公 |
| "wearing a hat" | 戴帽子 |
| "at the beach" | 海滩自拍 |
| "in professional attire" | 职业装 |

## ✅ 测试结果

```
✅ 生成成功！
   路径: /tmp/clawra-test-final.png
   大小: 1.3M
```

## 📚 项目结构

```
clawra-modelscope/
├── scripts/
│   ├── clawra-bailian.sh  ← 推荐使用
│   ├── clawra.sh          ← ModelScope（待修复）
│   └── clawra.py
├── src/
│   ├── index.ts
│   ├── cli.ts
│   └── test.ts
├── .env
├── package.json
├── tsconfig.json
├── SKILL.md
└── README.md
```

## 📋 ModelScope API 状态

- Z-Image-Turbo: ❌ 不支持 API Inference
- 其他模型: ⚠️ 需要充值/开通
- 百炼: ✅ 可用

---

*最后更新: 2026-02-26*
*配置者: Olga Marie Animusphere*
