#!/usr/bin/env python3
"""
批量生成脚本
版本: v1.0
创建时间: 2026-02-27

用途：批量生成多个场景
特点：完全预设参数 + 性能优化
"""

import time
import argparse
from generate_yunmian import YunmianGenerator, SCENES

def main():
    parser = argparse.ArgumentParser(description="批量生成云眠自拍")
    parser.add_argument(
        "--scenes",
        type=str,
        default="work,relax,celebrate",
        help="场景列表，用逗号分隔（默认: work,relax,celebrate）"
    )

    args = parser.parse_args()

    # 解析场景列表
    scene_list = [s.strip() for s in args.scenes.split(",")]

    # 验证场景
    for scene in scene_list:
        if scene not in SCENES:
            print(f"❌ 场景 '{scene}' 不存在")
            print(f"可用场景: {', '.join(SCENES.keys())}")
            return

    print(f"{'='*60}")
    print(f"批量生成：{len(scene_list)} 个场景")
    print(f"场景列表: {', '.join(scene_list)}")
    print(f"{'='*60}")

    generator = YunmianGenerator()
    total_start = time.time()

    for i, scene in enumerate(scene_list, 1):
        print(f"\n[{i}/{len(scene_list)}] 生成场景: {SCENES[scene]['description']}")
        generator.generate_full(scene)

        # 场景之间等待 10 秒（让电脑彻底休息）
        if i < len(scene_list):
            print(f"\n等待 10 秒（让电脑休息）...")
            time.sleep(10)

    total_time = time.time() - total_start

    print(f"\n{'='*60}")
    print(f"✅ 批量生成完成！")
    print(f"总场景数: {len(scene_list)}")
    print(f"总耗时: {total_time/60:.1f} 分钟")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
