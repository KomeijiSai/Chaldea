#!/bin/bash

###############################################################################
# Mac M5 图片生成环境 - 交互式安装脚本
#
# 版本: v1.0
# 创建时间: 2026-02-27
# 维护者: 九公主云眠
###############################################################################

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印函数
print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_question() {
    echo -e "${BLUE}[?]${NC} $1"
}

# 询问用户
ask_continue() {
    print_question "$1"
    read -p "继续？(y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        print_warning "安装已取消"
        exit 1
    fi
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

###############################################################################
# 欢迎界面
###############################################################################

print_header "Mac M5 图片生成环境安装向导"

echo "欢迎使用云眠的图片生成环境安装向导！"
echo ""
echo "在开始之前，云眠先介绍一下安装流程："
echo ""

cat << 'EOF'
📦 你即将安装的内容：

1. Python 3.11 环境
   - 作用：运行图片生成脚本的编程语言
   - 大小：~200MB

2. PyTorch (MPS 加速)
   - 作用：深度学习框架，运行神经网络
   - 大小：~2GB
   - 特别：针对苹果 M5 芯片优化

3. diffusers + transformers
   - 作用：图片生成库，处理文字提示
   - 大小：~400MB

4. Stable Diffusion XL Base 模型
   - 作用：图片生成核心引擎
   - 大小：~6GB

5. hanfugirl LoRA 模型
   - 作用：让生成的古风汉服更美
   - 大小：~100MB

6. IP-Adapter FaceID 模型
   - 作用：保持面部一致性（御主最需要的功能）
   - 大小：~1GB

总计占用空间：~10GB
预计安装时间：30-60 分钟（取决于网速）
EOF

echo ""
print_question "你准备好了吗？"
read -p "开始安装？(y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "安装已取消"
    exit 1
fi

###############################################################################
# 阶段 1: 环境检查
###############################################################################

print_header "阶段 1/6: 环境检查"

print_info "检查系统环境..."

# 检查 macOS 版本
MACOS_VERSION=$(sw_vers -productVersion)
print_info "macOS 版本: $MACOS_VERSION"

# 检查芯片
CHIP=$(system_profiler SPHardwareDataType | grep Chip | awk '{print $2}')
print_info "芯片: $CHIP"

if [[ "$CHIP" != *"Apple"* ]]; then
    print_error "此脚本仅支持 Apple Silicon (M1/M2/M3/M4/M5)"
    exit 1
fi

# 检查内存
MEMORY=$(system_profiler SPHardwareDataType | grep Memory | awk '{print $2}')
print_info "内存: $MEMORY"

# 检查磁盘空间
DISK_AVAIL=$(df -h / | tail -1 | awk '{print $4}')
print_info "可用磁盘空间: $DISK_AVAIL"

# 检查 Homebrew
print_info "检查 Homebrew..."
if ! command_exists brew; then
    print_warning "Homebrew 未安装"
    print_question "是否安装 Homebrew？"
    read -p "安装？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        print_info "✅ Homebrew 安装完成"
    else
        print_error "Homebrew 是必需的，安装已取消"
        exit 1
    fi
else
    print_info "✅ Homebrew 已安装"
fi

# 检查 Git
print_info "检查 Git..."
if ! command_exists git; then
    print_warning "Git 未安装"
    print_question "是否安装 Git？"
    read -p "安装？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        brew install git
        print_info "✅ Git 安装完成"
    else
        print_error "Git 是必需的，安装已取消"
        exit 1
    fi
else
    print_info "✅ Git 已安装"
fi

# 检查 Python
print_info "检查 Python..."
if command_exists python3.11; then
    PYTHON_VERSION=$(python3.11 --version)
    print_info "✅ $PYTHON_VERSION 已安装"
else
    print_warning "Python 3.11 未安装"
    print_question "是否安装 Python 3.11？"
    read -p "安装？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        brew install python@3.11
        print_info "✅ Python 3.11 安装完成"
    else
        print_error "Python 3.11 是必需的，安装已取消"
        exit 1
    fi
fi

print_info "✅ 环境检查完成"
echo ""

###############################################################################
# 阶段 2: 创建虚拟环境
###############################################################################

print_header "阶段 2/6: 创建虚拟环境"

print_question "是否在当前目录创建虚拟环境？"
read -p "创建？(y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_warning "安装已取消"
    exit 1
fi

# 检查是否已有虚拟环境
if [ -d "venv" ]; then
    print_warning "虚拟环境已存在"
    print_question "是否删除并重新创建？"
    read -p "删除？(y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf venv
        print_info "已删除旧虚拟环境"
    else
        print_info "使用现有虚拟环境"
    fi
fi

# 创建虚拟环境
if [ ! -d "venv" ]; then
    print_info "创建虚拟环境..."
    python3.11 -m venv venv
    print_info "✅ 虚拟环境创建完成"
fi

# 激活虚拟环境
print_info "激活虚拟环境..."
source venv/bin/activate

# 升级 pip
print_info "升级 pip..."
pip install --upgrade pip

print_info "✅ 虚拟环境准备完成"
echo ""

###############################################################################
# 阶段 3: 安装 PyTorch
###############################################################################

print_header "阶段 3/6: 安装 PyTorch (MPS 加速)"

cat << 'EOF'
🔥 PyTorch 是什么？

PyTorch 是一个深度学习框架，用于运行神经网络模型。

为什么需要 MPS 版本？
- MPS = Metal Performance Shaders
- 这是苹果芯片专用的加速技术
- 可以让 M5 芯片发挥最大性能
- 生成速度比 CPU 快 5-10 倍

占用空间：~2GB
下载时间：5-10 分钟（取决于网速）
EOF

print_question "是否安装 PyTorch？"
read -p "安装？(y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "PyTorch 是必需的，安装已取消"
    exit 1
fi

print_info "安装 PyTorch（这可能需要几分钟）..."
pip install torch torchvision torchaudio

# 验证 MPS
print_info "验证 MPS 是否可用..."
python3 -c "import torch; print(f'MPS available: {torch.backends.mps.is_available()}')"

print_info "✅ PyTorch 安装完成"
echo ""

###############################################################################
# 阶段 4: 安装 diffusers + transformers
###############################################################################

print_header "阶段 4/6: 安装图片生成库"

cat << 'EOF'
🎨 安装内容：

1. diffusers - Hugging Face 的图片生成库
2. transformers - 处理文字提示
3. accelerate - 加速库
4. safetensors - 安全的模型格式
5. insightface + onnxruntime - 人脸识别（IP-Adapter 需要）

占用空间：~600MB
下载时间：3-5 分钟
EOF

print_question "是否安装这些库？"
read -p "安装？(y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_error "这些库是必需的，安装已取消"
    exit 1
fi

print_info "安装 diffusers + transformers..."
pip install diffusers[torch] transformers accelerate safetensors pillow opencv-python matplotlib

print_info "安装 IP-Adapter 依赖..."
pip install insightface onnxruntime

print_info "✅ 图片生成库安装完成"
echo ""

###############################################################################
# 阶段 5: 下载模型
###############################################################################

print_header "阶段 5/6: 下载模型"

print_warning "⚠️ 注意：模型文件较大，请根据你的网络情况选择下载方式"
echo ""

# 下载 SDXL Base
cat << 'EOF'
🖼️ Stable Diffusion XL Base 模型

这是什么：
- 图片生成的核心引擎
- 质量：1024x1024，细节丰富

占用空间：~6GB
下载时间：30-60 分钟（国内可能更慢）
EOF

print_question "如何下载 SDXL Base 模型？"
echo "A) 自动下载（推荐，但需要时间）"
echo "B) 手动下载（云眠提供下载链接）"
echo "C) 跳过（稍后下载）"
read -p "选择 (a/b/c): " -n 1 -r
echo

case $REPLY in
    [Aa])
        print_info "开始下载 SDXL Base 模型..."
        mkdir -p models/sdxl-base
        python3 << 'PYEOF'
from diffusers import StableDiffusionXLPipeline
print("开始下载 SDXL Base 模型（~6GB）...")
print("请耐心等待，这可能需要 30-60 分钟...")
pipe = StableDiffusionXLPipeline.from_pretrained(
    "stabilityai/stable-diffusion-xl-base-1.0",
    torch_dtype="auto",
    variant="fp16",
    use_safetensors=True
)
print("✅ SDXL Base 模型下载完成")
PYEOF
        ;;
    [Bb])
        print_info "手动下载指南："
        echo ""
        echo "1. 访问: https://huggingface.co/stabilityai/stable-diffusion-xl-base-1.0"
        echo "2. 点击 'Files and versions'"
        echo "3. 下载所有文件到 models/sdxl-base/"
        echo ""
        print_warning "下载完成后，重新运行此脚本继续安装"
        exit 0
        ;;
    [Cc])
        print_warning "已跳过 SDXL Base 模型下载"
        print_info "你可以稍后手动下载到 models/sdxl-base/"
        ;;
esac

echo ""

# 下载 LoRA
cat << 'EOF'
👸 hanfugirl-v1-5 LoRA 模型

这是什么：
- 让 SDXL 更擅长生成古风汉服美女
- 专门为云眠自拍优化

占用空间：~100MB
下载时间：1-2 分钟
EOF

print_question "如何下载 LoRA 模型？"
echo "A) 自动下载"
echo "B) 手动下载"
echo "C) 跳过"
read -p "选择 (a/b/c): " -n 1 -r
echo

case $REPLY in
    [Aa])
        print_info "下载 LoRA 模型..."
        mkdir -p models/loras
        python3 << 'PYEOF'
from diffusers.utils import hf_hub_download
print("开始下载 hanfugirl LoRA...")
hf_hub_download(
    repo_id="svjack/hanfugirl-v1-5",
    filename="hanfugirl-v1-5.safetensors",
    local_dir="models/loras",
    local_dir_use_symlinks=False
)
print("✅ LoRA 模型下载完成")
PYEOF
        ;;
    [Bb])
        print_info "手动下载指南："
        echo ""
        echo "1. 访问: https://huggingface.co/svjack/hanfugirl-v1-5"
        echo "2. 下载 hanfugirl-v1-5.safetensors"
        echo "3. 保存到 models/loras/"
        echo ""
        print_warning "下载完成后，重新运行此脚本继续安装"
        exit 0
        ;;
    [Cc])
        print_warning "已跳过 LoRA 模型下载"
        ;;
esac

echo ""

# 下载 IP-Adapter
cat << 'EOF'
🎭 IP-Adapter FaceID 模型

这是什么：
- **这是御主最需要的功能**
- 保持面部一致性
- 可以固定某个角色的面部特征
- 生成不同场景、服装、表情的同一人物

占用空间：~1GB
下载时间：10-20 分钟
EOF

print_question "如何下载 IP-Adapter 模型？"
echo "A) 自动下载"
echo "B) 手动下载"
echo "C) 跳过"
read -p "选择 (a/b/c): " -n 1 -r
echo

case $REPLY in
    [Aa])
        print_info "下载 IP-Adapter 模型..."
        python3 << 'PYEOF'
from diffusers.utils import hf_hub_download
print("开始下载 IP-Adapter FaceID...")
hf_hub_download(
    repo_id="h94/IP-Adapter",
    filename="models/ip-adapter-plus-faceid_sd15.bin",
    local_dir="models",
    local_dir_use_symlinks=False
)
print("✅ IP-Adapter 模型下载完成")
PYEOF
        ;;
    [Bb])
        print_info "手动下载指南："
        echo ""
        echo "1. 访问: https://huggingface.co/h94/IP-Adapter"
        echo "2. 进入 models/ 目录"
        echo "3. 下载 ip-adapter-plus-faceid_sd15.bin"
        echo "4. 保存到 models/"
        echo ""
        print_warning "下载完成后，重新运行此脚本继续安装"
        exit 0
        ;;
    [Cc])
        print_warning "已跳过 IP-Adapter 模型下载"
        ;;
esac

print_info "✅ 模型下载完成"
echo ""

###############################################################################
# 阶段 6: 测试验证
###############################################################################

print_header "阶段 6/6: 测试验证"

print_question "是否运行测试脚本验证安装？"
read -p "测试？(y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 检查模型是否存在
    if [ -f "models/loras/hanfugirl-v1-5.safetensors" ]; then
        print_info "运行测试 1: 云眠自拍（LoRA）..."
        python3 test_yunmian_lora.py
    else
        print_warning "LoRA 模型未下载，跳过测试 1"
    fi
fi

###############################################################################
# 完成
###############################################################################

print_header "🎉 安装完成！"

cat << 'EOF'
✅ 恭喜！环境已安装完成

下一步：
1. 查看测试脚本：
   - test_yunmian_lora.py（云眠自拍）
   - test_ip_adapter.py（图像到图像）
   - test_batch_yunmian.py（批量生成）

2. 运行测试：
   source venv/bin/activate
   python3 test_yunmian_lora.py

3. 查看输出：
   ls output/

如果遇到问题：
- 查看 README_V2.md 的常见问题部分
- 或重新运行此脚本

享受你的图片生成之旅！💕
EOF

echo ""
print_info "虚拟环境激活命令："
echo "  source venv/bin/activate"
echo ""
