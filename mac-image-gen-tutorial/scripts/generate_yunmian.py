#!/usr/bin/env python3
"""
云眠自拍生成脚本（完整流程）
版本: v1.0
创建时间: 2026-02-27

特点：
1. 完全预设参数（御主不需要配置）
2. 性能优化（避免风扇狂转）
3. 自动化流程（Turbo + SDXL）
"""

import torch
import time
import os
import json
import argparse
from datetime import datetime
from pathlib import Path

# ============================================================================
# 御主不需要修改以下参数（云眠已经优化好）
# ============================================================================

# 性能优化配置（平衡质量和性能）
TURBO_STEPS = 15          # Turbo 快速预览（2-3秒/张）
SDXL_STEPS = 25           # SDXL 标准模式（40-50秒/张，不会风扇狂转）
WIDTH = 1024
HEIGHT = 1024
GUIDANCE_SCALE = 7.0
DELAY_BETWEEN_GENERATIONS = 5  # 每张之间等待 5 秒（让电脑休息）

# 云眠的基础提示词（不需要改）
YUNMIAN_BASE_PROMPT = """
九公主秦云眠，大虞国公主，清甜灵动，
精致五官，古风汉服，高髻发饰，
白色浅粉汉服，优雅端庄，
高清自拍，自然光线，高质量，细腻画质
"""

YUNMIAN_NEGATIVE_PROMPT = """
低画质，模糊，变形，多手指，少手指，
水印，文字，畸形，扭曲，多余肢体，
丑脸，多人
"""

# 预设场景（御主只需要选择场景名称）
SCENES = {
    "work": {
        "prompt": "专注工作，现代办公室背景，认真思考，专业气质，优雅端庄",
        "description": "工作场景"
    },
    "relax": {
        "prompt": "休闲放松，咖啡馆场景，轻松愉快，微笑，自然表情",
        "description": "休闲场景"
    },
    "celebrate": {
        "prompt": "庆祝时刻，开心微笑，活力四射，庆祝氛围，喜悦表情",
        "description": "庆祝场景"
    },
    "night": {
        "prompt": "深夜坐在桌前，烛光摇曳，温柔微笑，夜晚氛围",
        "description": "夜晚场景"
    },
    "daily": {
        "prompt": "日常生活，自然场景，轻松自在，真实感",
        "description": "日常场景"
    },
    "meditation": {
        "prompt": "冥想静思，安静环境，平静表情，禅意氛围",
        "description": "冥想场景"
    }
}

# 固定随机种子（保持一致性）
BASE_SEED = 42

# 输出配置
OUTPUT_DIR = "output"
LOG_FILE = "logs/generate.log"

# ============================================================================
# 以下是脚本逻辑（御主不需要看）
# ============================================================================

class YunmianGenerator:
    def __init__(self):
        self.device = torch.device("mps" if torch.backends.mps.is_available() else "cpu")
        self.turbo_pipe = None
        self.sdxl_pipe = None

        # 创建输出目录
        Path(OUTPUT_DIR).mkdir(parents=True, exist_ok=True)
        Path("logs").mkdir(parents=True, exist_ok=True)

    def log(self, message):
        """记录日志"""
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        log_message = f"[{timestamp}] {message}"
        print(log_message)

        # 写入日志文件
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(log_message + "\n")

    def load_turbo_model(self):
        """加载 Z-Image-Turbo 模型"""
        if self.turbo_pipe is None:
            self.log("加载 Z-Image-Turbo 模型...")
            from diffusers import DiffusionPipeline

            self.turbo_pipe = DiffusionPipeline.from_pretrained(
                "Tongyi-MAI/Z-Image-Turbo",
                torch_dtype=torch.float16 if self.device.type == "mps" else torch.float32
            )
            self.turbo_pipe.to(self.device)

            # 性能优化
            self.turbo_pipe.enable_attention_slicing()
            if hasattr(self.turbo_pipe, 'enable_vae_slicing'):
                self.turbo_pipe.enable_vae_slicing()

            self.log("✅ Z-Image-Turbo 模型加载完成")

    def load_sdxl_model(self):
        """加载 SDXL 模型"""
        if self.sdxl_pipe is None:
            self.log("加载 SDXL 模型...")
            from diffusers import StableDiffusionXLPipeline

            self.sdxl_pipe = StableDiffusionXLPipeline.from_pretrained(
                "stabilityai/stable-diffusion-xl-base-1.0",
                torch_dtype=torch.float16 if self.device.type == "mps" else torch.float32,
                variant="fp16",
                use_safetensors=True
            )
            self.sdxl_pipe.to(self.device)

            # 性能优化
            self.sdxl_pipe.enable_attention_slicing()
            if hasattr(self.sdxl_pipe, 'enable_vae_slicing'):
                self.sdxl_pipe.enable_vae_slicing()

            # 加载 LoRA（如果存在）
            lora_path = "models/loras/hanfugirl-v1-5.safetensors"
            if os.path.exists(lora_path):
                self.sdxl_pipe.load_lora_weights(".", weight_name=lora_path)
                self.log("✅ LoRA 模型加载完成")

            self.log("✅ SDXL 模型加载完成")

    def generate_turbo(self, scene_name, count=3):
        """使用 Turbo 快速生成预览"""
        self.load_turbo_model()

        if scene_name not in SCENES:
            self.log(f"❌ 场景 '{scene_name}' 不存在")
            return []

        scene = SCENES[scene_name]
        prompt = f"{YUNMIAN_BASE_PROMPT}，{scene['prompt']}"

        self.log(f"开始生成 Turbo 预览：{scene['description']}（{count}张）")

        images = []
        for i in range(count):
            # 固定随机种子（保持一致性）
            seed = BASE_SEED + i
            generator = torch.Generator(device=self.device).manual_seed(seed)

            start_time = time.time()
            image = self.turbo_pipe(
                prompt=prompt,
                negative_prompt=YUNMIAN_NEGATIVE_PROMPT,
                num_inference_steps=TURBO_STEPS,
                guidance_scale=GUIDANCE_SCALE,
                generator=generator,
                width=WIDTH,
                height=HEIGHT,
            ).images[0]

            # 保存图片
            today = datetime.now().strftime("%Y-%m-%d")
            output_path = f"{OUTPUT_DIR}/turbo/{today}/{scene_name}_{i+1:03d}.png"
            Path(output_path).parent.mkdir(parents=True, exist_ok=True)
            image.save(output_path)

            elapsed_time = time.time() - start_time
            self.log(f"✅ Turbo 预览 {i+1}/{count}: {output_path}（{elapsed_time:.1f}秒）")

            images.append(output_path)

            # 性能优化：每张之间等待，避免风扇狂转
            if i < count - 1:
                self.log(f"等待 {DELAY_BETWEEN_GENERATIONS} 秒（让电脑休息）...")
                time.sleep(DELAY_BETWEEN_GENERATIONS)

        return images

    def generate_sdxl(self, scene_name):
        """使用 SDXL 生成高质量输出"""
        self.load_sdxl_model()

        if scene_name not in SCENES:
            self.log(f"❌ 场景 '{scene_name}' 不存在")
            return None

        scene = SCENES[scene_name]
        prompt = f"{YUNMIAN_BASE_PROMPT}，{scene['prompt']}"

        self.log(f"开始生成 SDXL 高质量：{scene['description']}")

        # 固定随机种子（保持一致性）
        seed = BASE_SEED
        generator = torch.Generator(device=self.device).manual_seed(seed)

        start_time = time.time()
        image = self.sdxl_pipe(
            prompt=prompt,
            negative_prompt=YUNMIAN_NEGATIVE_PROMPT,
            num_inference_steps=SDXL_STEPS,
            guidance_scale=GUIDANCE_SCALE,
            generator=generator,
            width=WIDTH,
            height=HEIGHT,
        ).images[0]

        # 保存图片
        today = datetime.now().strftime("%Y-%m-%d")
        output_path = f"{OUTPUT_DIR}/sdxl/{today}/{scene_name}_final.png"
        Path(output_path).parent.mkdir(parents=True, exist_ok=True)
        image.save(output_path)

        elapsed_time = time.time() - start_time
        self.log(f"✅ SDXL 高质量: {output_path}（{elapsed_time:.1f}秒）")

        return output_path

    def generate_full(self, scene_name):
        """完整流程：Turbo 预览 + SDXL 输出"""
        self.log(f"{'='*60}")
        self.log(f"开始完整生成流程：{SCENES[scene_name]['description']}")
        self.log(f"{'='*60}")

        total_start = time.time()

        # 第一步：Turbo 快速预览（3张）
        turbo_images = self.generate_turbo(scene_name, count=3)

        # 等待一下，让电脑休息
        self.log(f"等待 {DELAY_BETWEEN_GENERATIONS} 秒（让电脑休息）...")
        time.sleep(DELAY_BETWEEN_GENERATIONS)

        # 第二步：SDXL 高质量输出（1张）
        sdxl_image = self.generate_sdxl(scene_name)

        total_time = time.time() - total_start

        self.log(f"{'='*60}")
        self.log(f"✅ 完整生成流程完成！")
        self.log(f"Turbo 预览: {len(turbo_images)} 张")
        self.log(f"SDXL 高质量: {sdxl_image}")
        self.log(f"总耗时: {total_time:.1f} 秒")
        self.log(f"{'='*60}")

        return {
            "turbo": turbo_images,
            "sdxl": sdxl_image,
            "total_time": total_time
        }

def main():
    parser = argparse.ArgumentParser(description="云眠自拍生成脚本")
    parser.add_argument(
        "--scene",
        choices=list(SCENES.keys()),
        default="daily",
        help="场景名称（默认: daily）"
    )
    parser.add_argument(
        "--mode",
        choices=["turbo", "sdxl", "full"],
        default="full",
        help="生成模式：turbo（快速预览）、sdxl（高质量）、full（完整流程，默认）"
    )

    args = parser.parse_args()

    generator = YunmianGenerator()

    if args.mode == "turbo":
        generator.generate_turbo(args.scene)
    elif args.mode == "sdxl":
        generator.generate_sdxl(args.scene)
    else:
        generator.generate_full(args.scene)

if __name__ == "__main__":
    main()
