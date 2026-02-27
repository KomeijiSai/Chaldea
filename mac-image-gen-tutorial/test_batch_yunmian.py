#!/usr/bin/env python3
"""
测试3：批量生成云眠自拍
生成 3 张不同场景的云眠自拍
"""

import torch
from diffusers import StableDiffusionXLPipeline
import os
import time

# 场景配置
SCENES = [
    {
        "name": "work",
        "prompt": """
        九公主秦云眠，专注工作，
        现代办公室背景，认真思考，
        专业气质，优雅端庄，
        高清自拍，自然光线
        """,
    },
    {
        "name": "relax",
        "prompt": """
        九公主秦云眠，休闲放松，
        咖啡馆场景，轻松愉快，
        微笑，自然表情，
        高清自拍，温暖光线
        """,
    },
    {
        "name": "celebrate",
        "prompt": """
        九公主秦云眠，庆祝时刻，
        开心微笑，活力四射，
        庆祝氛围，喜悦表情，
        高清自拍，明亮光线
        """,
    },
]

def main():
    print("=" * 60)
    print("测试3：批量生成云眠自拍（3张）")
    print("=" * 60)

    # 设备配置
    device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
    print(f"✅ 使用设备: {device}")

    # 加载模型（只加载一次）
    print("\n加载 SDXL 模型...")
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

    # 负面提示词
    negative_prompt = """
    低画质，模糊，变形，多手指，少手指，
    水印，文字，畸形，扭曲，多余肢体
    """

    # 固定基础种子
    base_seed = 42

    # 创建输出目录
    os.makedirs("output", exist_ok=True)

    # 批量生成
    print("\n开始批量生成...")
    total_start_time = time.time()

    for i, scene in enumerate(SCENES):
        print(f"\n[{i+1}/3] 生成场景: {scene['name']}")

        # 每张图片使用不同的种子（但基于基础种子）
        seed = base_seed + i
        generator = torch.Generator(device=device).manual_seed(seed)

        start_time = time.time()
        image = pipe(
            prompt=scene["prompt"],
            negative_prompt=negative_prompt,
            num_inference_steps=30,
            guidance_scale=7.5,
            generator=generator,
            width=1024,
            height=1024,
        ).images[0]
        generation_time = time.time() - start_time

        # 保存图片
        output_path = f"output/test3_yunmian_{scene['name']}.png"
        image.save(output_path)
        print(f"✅ 保存成功: {output_path}（耗时: {generation_time:.2f}s）")

    total_time = time.time() - total_start_time

    print("\n" + "=" * 60)
    print(f"✅ 批量生成完成！")
    print(f"共生成 3 张图片")
    print(f"总耗时: {total_time:.2f}s")
    print(f"平均每张: {total_time/3:.2f}s")
    print("=" * 60)

if __name__ == "__main__":
    main()
