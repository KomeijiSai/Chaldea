#!/bin/bash
# Replicate FLUX schnell 自拍生成脚本
# 成本：$0.003/张（1000张仅需$3）

set -e

cd /root/.openclaw/workspace

# 加载环境变量
if [ -f .env ]; then
    export $(cat .env | grep REPLICATE_API_TOKEN | xargs)
fi

# 检查 API Token
if [ -z "$REPLICATE_API_TOKEN" ]; then
    echo "❌ 错误: REPLICATE_API_TOKEN 未设置"
    echo ""
    echo "获取方法："
    echo "1. 访问 https://replicate.com"
    echo "2. 注册账号"
    echo "3. 添加付款方式（最低充值 $10）"
    echo "4. 获取 API Token"
    echo "5. 添加到 .env: REPLICATE_API_TOKEN=xxx"
    exit 1
fi

# 用法
usage() {
    echo "Replicate FLUX schnell 自拍生成器"
    echo ""
    echo "用法: $0 <提示词> [输出路径]"
    echo ""
    echo "示例:"
    echo "  $0 '九公主秦云眠，御花园抚琴'"
    echo "  $0 'Clawra working at home' ./output.png"
    echo ""
    echo "成本: \$0.003/张（1000张仅\$3）"
    exit 1
}

# 参数检查
if [ -z "$1" ]; then
    usage
fi

PROMPT="$1"
OUTPUT="${2:-/tmp/replicate-selfie-$(date +%Y%m%d_%H%M%S).png}"

echo "🎨 Replicate FLUX schnell 自拍生成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "提示词: ${PROMPT:0:60}..."
echo "输出: $OUTPUT"
echo "成本: \$0.003"
echo ""

# 创建预测
RESPONSE=$(curl -s -X POST \
    "https://api.replicate.com/v1/predictions" \
    -H "Authorization: Token $REPLICATE_API_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"version\": \"black-forest-labs/flux-schnell\",
        \"input\": {
            \"prompt\": \"$PROMPT\",
            \"num_outputs\": 1,
            \"aspect_ratio\": \"1:1\",
            \"output_format\": \"png\",
            \"output_quality\": 100
        }
    }")

# 提取预测 ID
PREDICTION_ID=$(echo "$RESPONSE" | jq -r '.id // empty')

if [ -z "$PREDICTION_ID" ]; then
    echo "❌ 创建预测失败"
    echo "响应: $RESPONSE"
    exit 1
fi

echo "预测 ID: $PREDICTION_ID"
echo "等待生成..."

# 轮询状态
MAX_RETRIES=30
for i in $(seq 1 $MAX_RETRIES); do
    sleep 2
    
    STATUS_RESPONSE=$(curl -s \
        "https://api.replicate.com/v1/predictions/$PREDICTION_ID" \
        -H "Authorization: Token $REPLICATE_API_TOKEN")
    
    STATUS=$(echo "$STATUS_RESPONSE" | jq -r '.status')
    
    echo "  [$i/$MAX_RETRIES] 状态: $STATUS"
    
    if [ "$STATUS" = "succeeded" ]; then
        # 提取图片 URL
        IMAGE_URL=$(echo "$STATUS_RESPONSE" | jq -r '.output[0]')
        
        echo ""
        echo "📥 下载图片: $IMAGE_URL"
        
        # 下载图片
        curl -s -o "$OUTPUT" "$IMAGE_URL"
        
        if [ -f "$OUTPUT" ]; then
            SIZE=$(ls -lh "$OUTPUT" | awk '{print $5}')
            echo ""
            echo "✅ 生成成功！"
            echo "   路径: $OUTPUT"
            echo "   大小: $SIZE"
            echo "   成本: \$0.003"
        fi
        
        exit 0
    elif [ "$STATUS" = "failed" ]; then
        echo "❌ 生成失败"
        echo "$STATUS_RESPONSE" | jq '.'
        exit 1
    fi
done

echo "❌ 超时：任务未在预期时间内完成"
exit 1
