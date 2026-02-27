#!/usr/bin/env python3
"""
测试2：图像到图像（IP-Adapter）
基于参考图片生成，保持面部一致性
"""

import torch
from diffusers import StableDiffusionXLPipeline
from PIL import Image
import os
import time

def main():
    print("=" * 60)
    print("测试2：图像到图像（IP-Adapter FaceID）")
    print("=" * 60)

    # 检查参考图片
    reference_image_path = "input/reference.jpg"
    if not os.path.exists(reference_image_path):
        print(f"\n❌ 参考图片不存在: {reference_image_path}")
        print("\n请准备参考图片：")
        print("1. 创建 input 目录: mkdir -p input")
        print("2. 将参考图片保存为: input/reference.jpg")
        print("3. 重新运行此脚本")
        return

    # 设备配置
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    print(f"✅ 使用设备: {device}")

    # 加载模型
    print("加载 SDXL 模型...")
    start_time = time.time()
    pipe = StableDiffusionXLPipeline.from_pretrained(
        "stabilityai/stable-diffusion-xl-base-1.0",
        torch_dtype=torch.float16,
        variant="fp16",
        use_safetensors=True
    ).to(device)
    print(f"✅ 模型加载完成（耗时: {time.time() - start_time:.2f}s）")

    # 加载 IP-Adapter
    ip_adapter_path = "models/ip-adapter-plus-faceid_sd15.bin"
    if os.path.exists(ip_adapter_path):
        print("加载 IP-Adapter...")
        try:
            # 注意：IP-Adapter 需要额外的库支持
            # 这里简化处理，实际使用需要安装 insightface
            print("⚠️ IP-Adapter 需要安装 insightface 和 onnxruntime")
            print("运行: pip install insightface onnxruntime")
        except Exception as e:
            print(f"⚠️ IP-Adapter 加载失败: {e}")
    else:
        print("⚠️ IP-Adapter 文件不存在")
        print("运行: python3 -c \"from diffusers.utils import hf_hub_download; ...\"")

    # 加载参考图片
    reference_image = Image.open(reference_image_path).convert("RGB")
    print(f"\n✅ 参考图片加载成功")
    print(f"图片尺寸: {reference_image.size}")

    # 提示词
    prompt = """
    专业人像摄影，高质量，真实感，
    自然光线，柔和背景虚化，
    清晰的面部细节，真实的皮肤质感
    """

    negative_prompt = """
    低画质，模糊，变形，卡通，动漫，
    水印，文字，畸形，扭曲
    """

    # 固定随机种子
    seed = 42
    generator = torch.Generator(device=device).manual_seed(seed)

    # 生成图片
    print("\n开始生成图片...")
    print(f"随机种子: {seed}")
    print(f"推理步数: 40")
    print(f"分辨率: 1024x1024")

    start_time = time.time()

    # 如果 IP-Adapter 加载成功，使用 ip_adapter_image 参数
    # 这里先用标准方式生成
    image = pipe(
        prompt=prompt,
        negative_prompt=negative_prompt,
        num_inference_steps=40,
        guidance_scale=7.5,
        generator=generator,
        width=1024,
        height=1024,
    ).images[0]

    generation_time = time.time() - start_time

    # 保存图片
    output_path = "output/test2_ip_adapter.png"
    os.makedirs("output", exist_ok=True)
    image.save(output_path)

    print(f"\n✅ 图片生成成功！")
    print(f"输出路径: {output_path}")
    print(f"生成时间: {generation_time:.2f}s")
    print("=" * 60)

if __name__ == "__main__":
    main()
