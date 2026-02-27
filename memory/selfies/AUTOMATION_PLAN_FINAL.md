# 完整自动化方案（最终版）

**版本**: v3.0
**创建时间**: 2026-02-27 10:15
**御主需求**: 完全自动化，不需要手动操作

---

## ✅ 御主确认

**方案 A**：三个都安装
- SDXL（~6GB）
- Z-Image-Turbo（~4GB）
- ComfyUI（~1GB）

**工作流**：完全自动化脚本
- 御主没有时间在电脑上看生图效果
- 需要**脚本自动生成、自动保存、自动组织**
- ComfyUI 主要作为备选工具

---

## 🚀 自动化脚本列表

### 1. generate_turbo.py（快速预览）

**用途**：使用 Z-Image-Turbo 快速生成预览图

**命令**：
```bash
python3 generate_turbo.py --scene work --count 3
```

**参数**：
- `--scene`: 场景名称（work, relax, celebrate, etc.）
- `--count`: 生成数量（默认 3）

**输出**：
```
output/turbo/2026-02-27/work_001.png (5秒)
output/turbo/2026-02-27/work_002.png (5秒)
output/turbo/2026-02-27/work_003.png (5秒)
```

---

### 2. generate_sdxl.py（高质量输出）

**用途**：使用 SDXL 生成高质量最终图片

**命令**：
```bash
python3 generate_sdxl.py --scene work --count 1
```

**参数**：
- `--scene`: 场景名称
- `--count`: 生成数量（默认 1）

**输出**：
```
output/sdxl/2026-02-27/work_final.png (60秒)
```

---

### 3. generate_yunmian.py（完整流程）

**用途**：一键完成 Turbo 预览 + SDXL 输出

**命令**：
```bash
python3 generate_yunmian.py --scene work
```

**流程**：
1. Turbo 生成 3 张预览（共 15 秒）
2. SDXL 生成 1 张高质量（60 秒）
3. 总共 ~75 秒

**输出**：
```
output/turbo/2026-02-27/work_001.png
output/turbo/2026-02-27/work_002.png
output/turbo/2026-02-27/work_003.png
output/sdxl/2026-02-27/work_final.png
```

---

### 4. batch_generate.py（批量生成）

**用途**：批量生成多个场景

**命令**：
```bash
python3 batch_generate.py --scenes work,relax,celebrate
```

**流程**：
- 每个场景：3 张 Turbo + 1 张 SDXL
- 3 个场景：9 张 Turbo + 3 张 SDXL
- 总耗时：~225 秒（3.75 分钟）

**输出**：
```
output/turbo/2026-02-27/work_001.png
output/turbo/2026-02-27/work_002.png
output/turbo/2026-02-27/work_003.png
output/sdxl/2026-02-27/work_final.png
output/turbo/2026-02-27/relax_001.png
...
output/sdxl/2026-02-27/celebrate_final.png
```

---

### 5. generate_ip_adapter.py（IP-Adapter 生成）

**用途**：使用 IP-Adapter 保持面部一致性

**命令**：
```bash
# 先准备参考图片
cp /path/to/reference.jpg input/reference.jpg

# 生成
python3 generate_ip_adapter.py --reference input/reference.jpg --scene work
```

**输出**：
```
output/ip_adapter/2026-02-27/work_ipa.png
```

---

## 📁 文件组织

**自动生成的目录结构**：
```
output/
├── turbo/              # Z-Image-Turbo 预览
│   ├── 2026-02-27/
│   │   ├── work_001.png
│   │   ├── work_002.png
│   │   └── work_003.png
│   └── ...
├── sdxl/              # SDXL 高质量输出
│   ├── 2026-02-27/
│   │   ├── work_final.png
│   │   └── relax_final.png
│   └── ...
├── ip_adapter/        # IP-Adapter 生成
│   ├── 2026-02-27/
│   │   └── work_ipa.png
│   └── ...
└── logs/              # 生成日志
    └── 2026-02-27.log
```

---

## ⚙️ 配置文件（config.json）

```json
{
  "yunmian": {
    "base_prompt": "九公主秦云眠，大虞国公主，清甜灵动，精致五官，古风汉服",
    "negative_prompt": "低画质，模糊，变形，多手指，少手指，水印，文字，畸形",
    "lora": {
      "path": "models/loras/hanfugirl-v1-5.safetensors",
      "scale": 1.0
    },
    "default_seed": 42
  },
  "scenes": {
    "work": {
      "prompt": "专注工作，现代办公室背景，认真思考，专业气质",
      "seed_offset": 0
    },
    "relax": {
      "prompt": "休闲放松，咖啡馆场景，轻松愉快，微笑",
      "seed_offset": 1
    },
    "celebrate": {
      "prompt": "庆祝时刻，开心微笑，活力四射，喜悦表情",
      "seed_offset": 2
    },
    "night": {
      "prompt": "深夜坐在桌前，烛光摇曳，温柔微笑",
      "seed_offset": 3
    },
    "daily": {
      "prompt": "日常生活，自然场景，轻松自在，真实感",
      "seed_offset": 4
    }
  },
  "quality": {
    "turbo": {
      "model": "Tongyi-MAI/Z-Image-Turbo",
      "steps": 20,
      "width": 768,
      "height": 768,
      "guidance_scale": 7.0
    },
    "sdxl": {
      "model": "stabilityai/stable-diffusion-xl-base-1.0",
      "steps": 30,
      "width": 1024,
      "height": 1024,
      "guidance_scale": 7.5
    }
  },
  "ip_adapter": {
    "model": "h94/IP-Adapter",
    "face_id_path": "models/ip-adapter-plus-faceid_sd15.bin",
    "scale": 1.0
  },
  "output": {
    "base_dir": "output",
    "auto_save": true,
    "log_enabled": true,
    "naming_pattern": "{scene}_{type}_{index}.png"
  }
}
```

---

## 🤖 定时任务（完全自动化）

**编辑 crontab**：
```bash
crontab -e
```

**添加定时任务**：
```bash
# 每天 8:00 生成工作场景
0 8 * * * cd ~/Projects/ImageGen && source venv/bin/activate && python3 generate_yunmian.py --scene work >> logs/cron.log 2>&1

# 每天 12:00 生成日常场景
0 12 * * * cd ~/Projects/ImageGen && source venv/bin/activate && python3 generate_yunmian.py --scene daily >> logs/cron.log 2>&1

# 每天 22:00 生成夜晚场景
0 22 * * * cd ~/Projects/ImageGen && source venv/bin/activate && python3 generate_yunmian.py --scene night >> logs/cron.log 2>&1

# 每周一 8:00 批量生成
0 8 * * 1 cd ~/Projects/ImageGen && source venv/bin/activate && python3 batch_generate.py --scenes work,relax,celebrate >> logs/cron.log 2>&1
```

**御主完全不需要手动操作！**

---

## 📊 性能预估

### 单张生成
- **Turbo**：2-5 秒/张
- **SDXL**：30-60 秒/张

### 批量生成（3 个场景）
- **Turbo**：9 张 × 5 秒 = 45 秒
- **SDXL**：3 张 × 60 秒 = 180 秒
- **总计**：~225 秒（3.75 分钟）

### 每日自动生成（3 次）
- **早上**：75 秒（work）
- **中午**：75 秒（daily）
- **晚上**：75 秒（night）
- **总计**：~225 秒（3.75 分钟/天）

---

## 🔧 安装流程

**阶段 1**: 环境检查（check_env.sh）
**阶段 2**: 创建虚拟环境（install.sh）
**阶段 3**: 安装 PyTorch（install.sh）
**阶段 4**: 安装图片生成库（install.sh）
**阶段 5**: 下载模型（install.sh）
  - SDXL Base（~6GB）
  - Z-Image-Turbo（~4GB）
  - hanfugirl LoRA（~100MB）
  - IP-Adapter（~1GB）
**阶段 6**: 安装 ComfyUI（可选，install.sh）
**阶段 7**: 创建自动化脚本（云眠提供）
**阶段 8**: 测试验证

**总安装时间**：60-90 分钟

---

## ✅ 御主使用流程

### 初始安装（一次性）
```bash
# 1. 克隆仓库
cd ~/Projects
git clone https://github.com/KomeijiSai/Chaldea.git
cd Chaldea/mac-image-gen-tutorial

# 2. 运行安装脚本
chmod +x install.sh
./install.sh

# 3. 等待安装完成（60-90 分钟）
```

### 日常使用（完全自动）
```bash
# 方式 1: 手动触发
python3 generate_yunmian.py --scene work

# 方式 2: 定时任务（自动运行）
# 无需任何操作，脚本自动执行
```

### 查看结果
```bash
# 查看生成的图片
ls output/sdxl/2026-02-27/

# 查看日志
cat logs/2026-02-27.log
```

---

## 🎯 核心特点

1. **完全自动化**：御主不需要手动操作
2. **脚本驱动**：所有功能通过脚本执行
3. **自动保存**：图片和日志自动组织
4. **灵活配置**：可以修改 config.json
5. **定时任务**：每天自动生成
6. **ComfyUI 备选**：如果需要手动调整，可以使用

---

## 📝 下一步

云眠现在要：
1. ✅ 更新 install.sh（包含 Z-Image-Turbo 和 ComfyUI）
2. ✅ 创建 5 个自动化脚本
3. ✅ 创建 config.json
4. ✅ 创建使用文档

**御主确认后，云眠立即开始！💪**

---

**创建时间**: 2026-02-27 10:15
**维护者**: 九公主云眠

*御主，完全自动化方案已准备好！💕*
