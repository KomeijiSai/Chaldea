#!/usr/bin/env python3
"""
测试1：云眠自拍生成
使用 LoRA + 文本描述生成九公主秦云眠
"""

import torch
from diffusers import StableDiffusionXLPipeline
import os
import time

def main():
    print("=" * 60)
    print("测试1：云眠自拍生成（文本 + LoRA）")
    print("=" * 60)

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

    # 加载 LoRA
    print("加载云眠专用 LoRA...")
    lora_path = "models/loras/hanfugirl-v1-5.safetensors"
    if os.path.exists(lora_path):
        pipe.load_lora_weights(".", weight_name=lora_path)
        print("✅ LoRA 加载成功")
    else:
        print("⚠️ LoRA 文件不存在，使用纯文本生成")

    # 提示词
    prompt = """
    九公主秦云眠，大虞国公主，清甜灵动，
    精致五官，古风汉服，高髻发饰，
    白色浅粉汉服，优雅端庄，
    高清自拍，自然光线，高质量，细腻画质
    """

    negative_prompt = """
    低画质，模糊，变形，多手指，少手指，
    水印，文字，畸形，扭曲，多余肢体，
    丑脸，多人
    """

    # 固定随机种子（保持一致性）
    seed = 42
    generator = torch.Generator(device=device).manual_seed(seed)

    # 生成图片
    print("\n开始生成图片...")
    print(f"提示词: {prompt.strip()}")
    print(f"随机种子: {seed}")
    print(f"推理步数: 30")
    print(f"分辨率: 1024x1024")

    start_time = time.time()
    image = pipe(
        prompt=prompt,
        negative_prompt=negative_prompt,
        num_inference_steps=30,
        guidance_scale=7.5,
        generator=generator,
        width=1024,
        height=1024,
    ).images[0]
    generation_time = time.time() - start_time

    # 保存图片
    output_path = "output/test1_yunmian_lora.png"
    os.makedirs("output", exist_ok=True)
    image.save(output_path)

    print(f"\n✅ 图片生成成功！")
    print(f"输出路径: {output_path}")
    print(f"生成时间: {generation_time:.2f}s")
    print("=" * 60)

if __name__ == "__main__":
    main()
