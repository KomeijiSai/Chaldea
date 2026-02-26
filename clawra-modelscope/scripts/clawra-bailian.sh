#!/bin/bash
# Clawra Selfie Generator - 阿里云百炼版
# 使用通义万相 API

set -e

# API 配置
API_URL="https://dashscope.aliyuncs.com/api/v1/services/aigc/text2image/image-synthesis"
MODEL="wanx-v1"

# 固定人设提示词
CHARACTER_PROMPT="photorealistic selfie of an 18-year-old kpop idol girl"

# 加载环境变量
if [ -f ".env" ]; then
    source .env
fi

# 检查 API Key
if [ -z "$ALIYUN_BAILIAN_API_KEY" ]; then
    echo "❌ 错误: ALIYUN_BAILIAN_API_KEY 未设置"
    echo "请在 .env 文件中配置 ALIYUN_BAILIAN_API_KEY"
    exit 1
fi

# 用法
usage() {
    echo "用法: $0 <场景描述> [输出路径]"
    echo ""
    echo "示例:"
    echo "  $0 'at a cozy cafe'"
    echo "  $0 'wearing a hat' ./selfie.png"
    exit 1
}

# 参数检查
if [ -z "$1" ]; then
    usage
fi

SCENE="$1"
OUTPUT="${2:-/tmp/clawra-selfie-$(date +%Y%m%d%H%M%S).png}"

# 构建完整提示词
FULL_PROMPT="${CHARACTER_PROMPT}, ${SCENE}, natural lighting, high quality, smartphone photo"

echo "📸 生成 Clawra 自拍..."
echo "场景: $SCENE"
echo "完整提示词: $FULL_PROMPT"
echo "输出路径: $OUTPUT"
echo ""

# 创建生成任务
RESPONSE=$(curl -s -X POST "$API_URL" \
    -H "Authorization: Bearer $ALIYUN_BAILIAN_API_KEY" \
    -H "Content-Type: application/json" \
    -H "X-DashScope-Async: enable" \
    -d "{
        \"model\": \"$MODEL\",
        \"input\": {
            \"prompt\": \"$FULL_PROMPT\"
        },
        \"parameters\": {
            \"style\": \"<photography>\",
            \"size\": \"1024*1024\",
            \"n\": 1
        }
    }")

# 提取 task_id
TASK_ID=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('output',{}).get('task_id',''))" 2>/dev/null)

if [ -z "$TASK_ID" ]; then
    echo "❌ 创建任务失败"
    echo "响应: $RESPONSE"
    exit 1
fi

echo "任务 ID: $TASK_ID"
echo "等待生成..."

# 轮询任务状态 (最多 60 秒)
for i in {1..12}; do
    sleep 5
    STATUS=$(curl -s -H "Authorization: Bearer $ALIYUN_BAILIAN_API_KEY" \
        "https://dashscope.aliyuncs.com/api/v1/tasks/$TASK_ID")

    TASK_STATUS=$(echo "$STATUS" | python3 -c "import sys,json; print(json.load(sys.stdin).get('output',{}).get('task_status',''))" 2>/dev/null)

    echo "  [$i/12] 状态: $TASK_STATUS"

    if [ "$TASK_STATUS" = "SUCCEEDED" ]; then
        # 提取图片 URL
        IMAGE_URL=$(echo "$STATUS" | python3 -c "import sys,json; r=json.load(sys.stdin).get('output',{}).get('results',[]); print(r[0].get('url','') if r else '')" 2>/dev/null)

        if [ -n "$IMAGE_URL" ]; then
            echo ""
            echo "📥 下载图片: $IMAGE_URL"
            curl -s -o "$OUTPUT" "$IMAGE_URL"

            if [ -f "$OUTPUT" ] && [ -s "$OUTPUT" ]; then
                SIZE=$(ls -lh "$OUTPUT" | awk '{print $5}')
                echo ""
                echo "✅ 生成成功！"
                echo "   路径: $OUTPUT"
                echo "   大小: $SIZE"
                exit 0
            else
                echo "❌ 图片下载失败"
                exit 1
            fi
        fi
        break
    elif [ "$TASK_STATUS" = "FAILED" ]; then
        echo "❌ 任务失败"
        echo "$STATUS"
        exit 1
    fi
done

echo "❌ 超时或未知错误"
exit 1
