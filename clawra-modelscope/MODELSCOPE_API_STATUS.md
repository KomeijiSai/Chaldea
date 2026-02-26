# ModelScope Z-Image-Turbo API 状态报告

## ⚠️ 重要发现

**Z-Image-Turbo 模型不支持 ModelScope API Inference！**

### 模型信息
```json
{
  "SupportApiInference": false,
  "SupportDashInference": 0,
  "SupportInference": "txt2img"
}
```

### 可用方式

1. **本地部署** - 需要下载模型 + GPU
2. **Hugging Face** - 使用 diffusers
3. **阿里云 PAI** - 云端部署

## 为什么 API 返回成功但没有图片？

ModelScope API 接受了请求并返回 `SUCCEED`，但实际上：
- 任务没有真正执行
- 没有生成图片
- 查询任务返回 `task not found`

## 替代方案

### 1. 阿里云百炼（推荐）
- ✅ 已验证可用
- ✅ 国内访问快
- ✅ API 稳定

### 2. 其他 ModelScope 模型
需要查找支持 `SupportApiInference: true` 的图片生成模型

### 3. 本地部署 Z-Image-Turbo
需要：
- 16G+ VRAM GPU
- 下载 10GB+ 模型
- Python 环境

## 代码示例（本地运行）

```python
import torch
from diffusers import ZImagePipeline

pipe = ZImagePipeline.from_pretrained(
    "Tongyi-MAI/Z-Image-Turbo",
    torch_dtype=torch.bfloat16,
)
pipe.to("cuda")

image = pipe(
    prompt="a cute girl taking selfie",
    height=1024,
    width=1024,
    num_inference_steps=9,
    guidance_scale=0.0,
).images[0]

image.save("output.png")
```

---

*报告日期: 2026-02-26*
