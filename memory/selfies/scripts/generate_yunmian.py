#!/usr/bin/env python3
"""
九公主云眠 - 自拍生成脚本
使用 Z-Image-Turbo + LoRA 生成云眠的自拍图片
"""

import torch
from diffusers import ZImagePipeline
from datetime import datetime
import os
import sys
import argparse

# 配置
SCENES = {
    "work": "专注看书，手持毛笔，认真工作，室内自然光线，温暖明亮",
    "relax": "坐在窗边，手捧茶杯，微笑看窗外，下午茶时光，柔和阳光",
    "night": "深夜坐在桌前，烛光摇曳，温柔微笑，夜晚氛围，温馨宁静",
    "celebrate": "开心大笑，双手比V，欢快跳跃，庆祝成就，充满活力",
    "meditation": "安静坐着，闭目冥想，内心平静，清晨阳光，宁静祥和",
    "daily": "对着镜子自拍，自然微笑，随意姿势，居家环境，生活化场景"
}

BASE_PROMPT = "九公主秦云眠，大虞国公主，清甜灵动，精致五官，古风汉服，高髻发饰，白色浅粉汉服，统一面部特征"
NEGATIVE_PROMPT = "低画质，模糊，变形，多手指，少手指，水印，文字，畸形，扭曲，多余肢体，丑脸，多人，背景杂乱，过曝，欠曝"

class YunmianSelfieGenerator:
    def __init__(self, model_path="Tongyi-MAI/Z-Image-Turbo", lora_path=None):
        """初始化生成器"""
        print("正在加载模型...")
        self.pipe = ZImagePipeline.from_pretrained(
            model_path,
            torch_dtype=torch.bfloat16
        )
        self.pipe.to("cuda")

        # 性能优化
        self.pipe.enable_attention_slicing()
        self.pipe.enable_vae_slicing()

        # 加载 LoRA（如果有）
        if lora_path and os.path.exists(lora_path):
            print(f"加载 LoRA: {lora_path}")
            self.pipe.load_lora_weights(lora_path)
            self.lora_weight = 0.7
        else:
            self.lora_weight = None

        print("模型加载完成！")

    def generate(self, scene="daily", output_dir=None, width=1024, height=1024):
        """生成自拍"""
        # 获取场景提示词
        scene_prompt = SCENES.get(scene, SCENES["daily"])

        # 构建完整提示词
        if self.lora_weight:
            prompt = f"<lora:yunmian:{self.lora_weight}> {BASE_PROMPT}，{scene_prompt}，高清自拍，细腻画质，1024x1024"
        else:
            prompt = f"{BASE_PROMPT}，{scene_prompt}，高清自拍，细腻画质，1024x1024"

        print(f"\n生成场景: {scene}")
        print(f"提示词: {prompt}\n")

        # 生成图片
        image = self.pipe(
            prompt=prompt,
            negative_prompt=NEGATIVE_PROMPT,
            width=width,
            height=height,
            num_inference_steps=30,
            guidance_scale=7.0
        ).images[0]

        # 保存图片
        if output_dir is None:
            output_dir = os.path.expanduser("~/Pictures/yunmian-selfies/九公主")

        # 创建月份目录
        month_dir = os.path.join(output_dir, datetime.now().strftime("%Y-%m"))
        os.makedirs(month_dir, exist_ok=True)

        # 生成文件名
        timestamp = datetime.now().strftime("%Y-%m-%d_%H%M%S")
        filename = f"{timestamp}_{scene}.png"
        filepath = os.path.join(month_dir, filename)

        # 保存
        image.save(filepath)
        print(f"✅ 图片已生成: {filepath}")

        return filepath

    def batch_generate(self, scenes=None):
        """批量生成"""
        if scenes is None:
            scenes = list(SCENES.keys())

        results = []
        for scene in scenes:
            try:
                filepath = self.generate(scene)
                results.append({
                    "scene": scene,
                    "filepath": filepath,
                    "status": "success"
                })
            except Exception as e:
                print(f"❌ 生成失败 ({scene}): {e}")
                results.append({
                    "scene": scene,
                    "filepath": None,
                    "status": "failed",
                    "error": str(e)
                })

        return results


def main():
    parser = argparse.ArgumentParser(description="生成九公主云眠的自拍图片")
    parser.add_argument(
        "--scene",
        type=str,
        default="daily",
        choices=list(SCENES.keys()),
        help="场景类型"
    )
    parser.add_argument(
        "--all",
        action="store_true",
        help="生成所有场景"
    )
    parser.add_argument(
        "--output",
        type=str,
        default=None,
        help="输出目录"
    )
    parser.add_argument(
        "--model",
        type=str,
        default="Tongyi-MAI/Z-Image-Turbo",
        help="模型路径"
    )
    parser.add_argument(
        "--lora",
        type=str,
        default=None,
        help="LoRA 模型路径"
    )
    parser.add_argument(
        "--width",
        type=int,
        default=1024,
        help="图片宽度"
    )
    parser.add_argument(
        "--height",
        type=int,
        default=1024,
        help="图片高度"
    )

    args = parser.parse_args()

    # 初始化生成器
    generator = YunmianSelfieGenerator(
        model_path=args.model,
        lora_path=args.lora
    )

    # 生成图片
    if args.all:
        print("\n批量生成所有场景...")
        results = generator.batch_generate()
        print("\n=== 生成结果 ===")
        for result in results:
            if result["status"] == "success":
                print(f"✅ {result['scene']}: {result['filepath']}")
            else:
                print(f"❌ {result['scene']}: {result['error']}")
    else:
        filepath = generator.generate(
            scene=args.scene,
            output_dir=args.output,
            width=args.width,
            height=args.height
        )
        print(f"\n完成！图片路径: {filepath}")


if __name__ == "__main__":
    main()
