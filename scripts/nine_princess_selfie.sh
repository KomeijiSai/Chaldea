#!/bin/bash
# 九公主秦云眠自拍生成脚本
# 支持场景参数化

set -e

cd /root/.openclaw/workspace/clawra-modelscope

# API 配置
API_URL="https://dashscope.aliyuncs.com/api/v1/services/aigc/text2image/image-synthesis"
MODEL="wanx-v1"

# 固定人设提示词 - 九公主秦云眠
CHARACTER_PROMPT="ancient Chinese princess Qin Yunmian, character from Chinese drama, played by actress Lin Jiahui, 18-year-old young woman, jet black long hair in high bun with traditional hair ornaments and silk ribbons, lively almond-shaped dark eyes, bright curious gaze, fair jade-like skin, oval delicate face, small pink lips, wearing white and pale pink embroidered gold Hanfu, gentle yet playful expression, royal elegance"

# 加载环境变量
if [ -f "../.env" ]; then
    source ../.env
fi

# 检查 API Key
if [ -z "$ALIYUN_BAILIAN_API_KEY" ]; then
    echo "❌ 错误: ALIYUN_BAILIAN_API_KEY 未设置"
    exit 1
fi

# 用法
usage() {
    echo "九公主秦云眠自拍生成器"
    echo ""
    echo "用法: $0 <场景描述> [输出路径]"
    echo ""
    echo "场景示例:"
    echo "  $0 '御花园抚琴'"
    echo "  $0 '书房看书' ./nine-princess/reading.png"
    echo "  $0 '湖边散步'"
    echo ""
    echo "常见场景:"
    echo "  • 御花园抚琴 (in imperial garden playing guqin)"
    echo "  • 书房看书 (in study room reading)"
    echo "  • 宫殿漫步 (walking in palace hall)"
    echo "  • 湖边赏荷 (by lotus lake)"
    echo "  • 梳妆打扮 (dressing up with mirror)"
    exit 1
}

# 参数检查
if [ -z "$1" ]; then
    usage
fi

SCENE="$1"
OUTPUT_DIR="/root/.openclaw/workspace/memory/selfies/nine-princess"
mkdir -p "$OUTPUT_DIR"

OUTPUT="${2:-$OUTPUT_DIR/$(date +%Y-%m-%d_%H%M%S)_nine-princess.png}"

# 场景映射（中文 -> 英文）
declare -A SCENE_MAP
SCENE_MAP["御花园抚琴"]="in imperial garden playing traditional guqin, surrounded by blooming flowers, spring morning light"
SCENE_MAP["书房看书"]="in elegant study room reading ancient scroll, warm candle light, scholarly atmosphere"
SCENE_MAP["宫殿漫步"]="walking in magnificent palace hall, golden pillars and silk curtains, royal grandeur"
SCENE_MAP["湖边赏荷"]="by tranquil lotus lake admiring lotus flowers, traditional bridge in background, golden hour light"
SCENE_MAP["梳妆打扮"]="sitting at vanity mirror dressing up, traditional cosmetics, soft morning light"
SCENE_MAP["品茶"]="sitting elegantly drinking tea, traditional tea set, peaceful atmosphere"
SCENE_MAP["弹琵琶"]="playing traditional pipa, in garden pavilion, afternoon light"
SCENE_MAP["写字画画"]="writing calligraphy, in study room, ink and brush, scholarly atmosphere"

# 检查是否有映射的场景
if [ -n "${SCENE_MAP[$SCENE]}" ]; then
    SCENE_EN="${SCENE_MAP[$SCENE]}"
else
    # 如果没有映射，直接使用（假设是英文）
    SCENE_EN="$SCENE"
fi

# 构建完整提示词
FULL_PROMPT="photorealistic selfie of ${CHARACTER_PROMPT}, ${SCENE_EN}, natural lighting, high quality, detailed, sharp focus"

echo "👸 九公主秦云眠自拍生成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "场景: $SCENE"
echo "英文: ${SCENE_EN:0:50}..."
echo "输出: $OUTPUT"
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
            \"size\": \"1024*1024\",
            \"n\": 1
        }
    }")

# 提取任务 ID
TASK_ID=$(echo "$RESPONSE" | jq -r '.output.task_id // empty')

if [ -z "$TASK_ID" ]; then
    echo "❌ 创建任务失败"
    echo "响应: $RESPONSE"
    exit 1
fi

echo "任务 ID: $TASK_ID"
echo "等待生成..."

# 轮询任务状态
MAX_RETRIES=12
for i in $(seq 1 $MAX_RETRIES); do
    sleep 5
    
    STATUS_RESPONSE=$(curl -s \
        "https://dashscope.aliyuncs.com/api/v1/tasks/$TASK_ID" \
        -H "Authorization: Bearer $ALIYUN_BAILIAN_API_KEY")
    
    STATUS=$(echo "$STATUS_RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('output',{}).get('task_status',''))" 2>/dev/null)
    
    echo "  [$i/$MAX_RETRIES] 状态: $STATUS"
    
    if [ "$STATUS" = "SUCCEEDED" ]; then
        # 提取图片 URL
        IMAGE_URL=$(echo "$STATUS_RESPONSE" | python3 -c "import sys,json; r=json.load(sys.stdin).get('output',{}).get('results',[]); print(r[0].get('url','') if r else '')" 2>/dev/null)
        
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
            
            # 更新相册
            echo ""
            echo "📷 更新相册索引..."
            ALBUM_FILE="/root/.openclaw/workspace/memory/selfies/nine-princess/ALBUM.md"
            
            if [ ! -f "$ALBUM_FILE" ]; then
                cat > "$ALBUM_FILE" << EOF
# 👸 九公主秦云眠相册

---

## 📸 自拍列表

EOF
            fi
            
            # 添加新照片记录
            DATE=$(date "+%Y-%m-%d %H:%M:%S")
            echo "" >> "$ALBUM_FILE"
            echo "### $DATE" >> "$ALBUM_FILE"
            echo "- **场景**: $SCENE" >> "$ALBUM_FILE"
            echo "- **文件**: \`$(basename $OUTPUT)\`" >> "$ALBUM_FILE"
            echo "- **大小**: $SIZE" >> "$ALBUM_FILE"
            
            echo "✅ 相册已更新"
        fi
        
        exit 0
    elif [ "$STATUS" = "FAILED" ]; then
        echo "❌ 生成失败"
        echo "$STATUS_RESPONSE" | jq '.'
        exit 1
    fi
done

echo "❌ 超时：任务未在预期时间内完成"
exit 1
