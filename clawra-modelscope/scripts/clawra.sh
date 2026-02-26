#!/bin/bash
# Clawra Selfie Generator - Shell Script Version
# 使用魔搭 ModelScope Z-Image-Turbo API

set -e

# 配置
API_URL="https://api-inference.modelscope.cn/v1/images/generations"
MODEL="Tongyi-MAI/Z-Image-Turbo"

# 固定人设提示词 (精简版)
CHARACTER_PROMPT="18yo kpop idol selfie"

# 加载环境变量
if [ -f ".env" ]; then
    source .env
fi

# 检查 API Key
if [ -z "$MODELSCOPE_API_KEY" ]; then
    echo "❌ 错误: MODELSCOPE_API_KEY 未设置"
    echo "请在 .env 文件中配置 MODELSCOPE_API_KEY"
    exit 1
fi

# 用法
usage() {
    echo "用法: $0 <场景描述> [输出路径]"
    echo ""
    echo "示例:"
    echo "  $0 '在咖啡馆'"
    echo "  $0 '戴着帽子' ./selfie.png"
    echo "  $0 '在家里工作' /tmp/clawra.png"
    exit 1
}

# 参数检查
if [ -z "$1" ]; then
    usage
fi

SCENE="$1"
OUTPUT="${2:-/tmp/clawra-selfie-$(date +%Y%m%d%H%M%S).png}"

# 构建完整提示词
FULL_PROMPT="${CHARACTER_PROMPT}, ${SCENE}"

echo "📸 生成 Clawra 自拍..."
echo "场景: $SCENE"
echo "完整提示词: $FULL_PROMPT"
echo "输出路径: $OUTPUT"
echo ""

# 调用 API (异步模式)
RESPONSE=$(curl -s -X POST "$API_URL" \
    -H "Authorization: Bearer $MODELSCOPE_API_KEY" \
    -H "Content-Type: application/json" \
    -H "X-ModelScope-Async-Mode: true" \
    -d "{
        \"prompt\": \"$FULL_PROMPT\",
        \"model\": \"$MODEL\",
        \"size\": \"1024x1024\",
        \"n\": 1
    }")

# 检查错误
if echo "$RESPONSE" | grep -q "error\|Error\|ERROR"; then
    echo "❌ API 调用失败:"
    echo "$RESPONSE" | jq -r '.message // .error // .' 2>/dev/null || echo "$RESPONSE"
    exit 1
fi

# 提取图片 URL
IMAGE_URL=$(echo "$RESPONSE" | jq -r '.data[0].url // empty' 2>/dev/null)

if [ -z "$IMAGE_URL" ]; then
    echo "❌ 无法提取图片 URL"
    echo "响应: $RESPONSE"
    exit 1
fi

# 下载图片
echo "📥 下载图片: $IMAGE_URL"
curl -s -o "$OUTPUT" "$IMAGE_URL"

# 检查文件
if [ -f "$OUTPUT" ] && [ -s "$OUTPUT" ]; then
    SIZE=$(ls -lh "$OUTPUT" | awk '{print $5}')
    echo ""
    echo "✅ 生成成功！"
    echo "   路径: $OUTPUT"
    echo "   大小: $SIZE"
else
    echo "❌ 图片下载失败"
    exit 1
fi
