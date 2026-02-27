#!/bin/bash

###############################################################################
# 环境检查脚本
#
# 用途：检查系统环境是否满足安装要求
###############################################################################

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
}

print_ok() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查计数
PASS=0
FAIL=0
WARN=0

print_header "环境检查"

# 1. 检查操作系统
echo "1. 检查操作系统..."
MACOS_VERSION=$(sw_vers -productVersion 2>/dev/null)
if [ $? -eq 0 ]; then
    print_ok "macOS 版本: $MACOS_VERSION"
    PASS=$((PASS + 1))
else
    print_error "无法获取 macOS 版本"
    FAIL=$((FAIL + 1))
fi

# 2. 检查芯片
echo ""
echo "2. 检查芯片..."
CHIP=$(system_profiler SPHardwareDataType 2>/dev/null | grep Chip | awk '{print $2}')
if [[ "$CHIP" == *"Apple"* ]]; then
    print_ok "芯片: $CHIP"
    PASS=$((PASS + 1))
else
    print_error "不支持此芯片: $CHIP（仅支持 Apple Silicon）"
    FAIL=$((FAIL + 1))
fi

# 3. 检查内存
echo ""
echo "3. 检查内存..."
MEMORY=$(system_profiler SPHardwareDataType 2>/dev/null | grep Memory | awk '{print $2}')
MEMORY_NUM=${MEMORY% GB}
if [ "$MEMORY_NUM" -ge 16 ]; then
    print_ok "内存: $MEMORY"
    PASS=$((PASS + 1))
else
    print_warning "内存: $MEMORY（推荐 16GB+）"
    WARN=$((WARN + 1))
fi

# 4. 检查磁盘空间
echo ""
echo "4. 检查磁盘空间..."
DISK_AVAIL=$(df -h / 2>/dev/null | tail -1 | awk '{print $4}')
DISK_NUM=$(echo "$DISK_AVAIL" | sed 's/Gi//')
if [ "$(echo "$DISK_NUM > 30" | bc)" -eq 1 ]; then
    print_ok "可用磁盘空间: $DISK_AVAIL"
    PASS=$((PASS + 1))
else
    print_warning "可用磁盘空间: $DISK_AVAIL（推荐 30GB+）"
    WARN=$((WARN + 1))
fi

# 5. 检查 Homebrew
echo ""
echo "5. 检查 Homebrew..."
if command -v brew &> /dev/null; then
    BREW_VERSION=$(brew --version 2>/dev/null | head -1)
    print_ok "$BREW_VERSION"
    PASS=$((PASS + 1))
else
    print_error "Homebrew 未安装"
    echo "   安装命令: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    FAIL=$((FAIL + 1))
fi

# 6. 检查 Git
echo ""
echo "6. 检查 Git..."
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version 2>/dev/null)
    print_ok "$GIT_VERSION"
    PASS=$((PASS + 1))
else
    print_warning "Git 未安装"
    echo "   安装命令: brew install git"
    WARN=$((WARN + 1))
fi

# 7. 检查 Python
echo ""
echo "7. 检查 Python..."
if command -v python3.11 &> /dev/null; then
    PYTHON_VERSION=$(python3.11 --version 2>/dev/null)
    print_ok "$PYTHON_VERSION"
    PASS=$((PASS + 1))
else
    print_warning "Python 3.11 未安装"
    echo "   安装命令: brew install python@3.11"
    WARN=$((WARN + 1))
fi

# 8. 检查虚拟环境
echo ""
echo "8. 检查虚拟环境..."
if [ -d "venv" ]; then
    print_ok "虚拟环境已存在"
    PASS=$((PASS + 1))
else
    print_ok "虚拟环境未创建（稍后会创建）"
    PASS=$((PASS + 1))
fi

# 总结
print_header "检查结果"

echo "通过: $PASS"
echo "警告: $WARN"
echo "失败: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    print_ok "环境检查通过！"
    echo ""
    echo "下一步："
    echo "  ./install.sh"
else
    print_error "环境检查失败，请先安装缺失的组件"
    echo ""
    echo "常见问题："
    echo "  - Homebrew: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "  - Git: brew install git"
    echo "  - Python: brew install python@3.11"
fi
