#!/usr/bin/env python3
"""
Clawra Selfie Generator - Python Version
使用魔搭 ModelScope Z-Image-Turbo API
"""

import os
import json
import time
import requests
from pathlib import Path

# API 配置
API_URL = "https://api-inference.modelscope.cn/v1/images/generations"
MODEL = "Tongyi-MAI/Z-Image-Turbo"

# 固定人设提示词
CHARACTER_PROMPT = "18yo kpop idol girl, cute, selfie"

def generate_selfie(scene: str, output_path: str = "/tmp/clawra-selfie.png") -> str:
    """生成自拍"""
    api_key = os.getenv("MODELSCOPE_API_KEY")
    if not api_key:
        raise ValueError("MODELSCOPE_API_KEY 未设置")

    # 构建提示词
    prompt = f"{CHARACTER_PROMPT}, {scene}"

    print(f"📸 生成 Clawra 自拍...")
    print(f"场景: {scene}")
    print(f"提示词: {prompt}")

    # 调用 API
    headers = {
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
        "X-ModelScope-Async-Mode": "true"
    }

    payload = {
        "prompt": prompt,
        "model": MODEL,
        "size": "1024x1024",
        "n": 1
    }

    response = requests.post(API_URL, headers=headers, json=payload)
    result = response.json()

    print(f"\nAPI 响应:")
    print(json.dumps(result, indent=2, ensure_ascii=False))

    if "errors" in result:
        raise Exception(f"API 错误: {result['errors']}")

    # 检查任务状态
    task_status = result.get("task_status", "")
    task_id = result.get("task_id", "")

    print(f"\n任务状态: {task_status}")
    print(f"任务 ID: {task_id}")

    # 如果任务成功，尝试获取图片 URL
    if task_status == "SUCCEED":
        # 检查是否有 output 字段
        if "output" in result:
            output = result["output"]
            print(f"\nOutput: {json.dumps(output, indent=2, ensure_ascii=False)}")

            # 尝试提取图片 URL
            image_url = None
            if "results" in output:
                image_url = output["results"][0].get("url")
            elif "images" in output:
                image_url = output["images"][0].get("url")
            elif "url" in output:
                image_url = output["url"]

            if image_url:
                print(f"\n📥 下载图片: {image_url}")
                img_response = requests.get(image_url, timeout=30)
                with open(output_path, "wb") as f:
                    f.write(img_response.content)
                print(f"✅ 图片已保存: {output_path}")
                return output_path

        # 如果没有找到图片 URL，尝试查询任务结果
        if task_id:
            print(f"\n查询任务结果...")
            time.sleep(2)

            task_url = f"https://api-inference.modelscope.cn/v1/tasks/{task_id}"
            task_response = requests.get(task_url, headers={"Authorization": f"Bearer {api_key}"})
            task_result = task_response.json()

            print(f"任务结果: {json.dumps(task_result, indent=2, ensure_ascii=False)}")

    raise Exception("无法获取图片 URL，请检查 API 响应格式")

if __name__ == "__main__":
    import sys

    if len(sys.argv) < 2:
        print("用法: python3 clawra.py <场景> [输出路径]")
        print("示例: python3 clawra.py 'at cafe' ./selfie.png")
        sys.exit(1)

    scene = sys.argv[1]
    output = sys.argv[2] if len(sys.argv) > 2 else "/tmp/clawra-selfie.png"

    # 加载 .env
    from pathlib import Path
    env_file = Path(__file__).parent / ".env"
    if env_file.exists():
        for line in env_file.read_text().split("\n"):
            if "=" in line and not line.startswith("#"):
                key, value = line.split("=", 1)
                os.environ[key.strip()] = value.strip()

    try:
        generate_selfie(scene, output)
    except Exception as e:
        print(f"❌ 错误: {e}")
        sys.exit(1)
