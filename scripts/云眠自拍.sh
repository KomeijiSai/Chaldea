#!/bin/bash
# 九公主秦云眠专属自拍生成脚本
# 唯一角色，固定形象

set -e

cd /root/.openclaw/workspace/clawra-modelscope

# API 配置
API_URL="https://dashscope.aliyuncs.com/api/v1/services/aigc/text2image/image-synthesis"
MODEL="wanx-v1"

# 固定人设提示词 - 九公主秦云眠（唯一角色）
POSITIVE_PROMPT="九公主秦云眠，大虞国公主，清甜灵动，精致五官，古风汉服，高髻发饰，白色浅粉汉服，统一面部特征，高清自拍，自然光线，高质量，细腻画质"
NEGATIVE_PROMPT="低画质，模糊，变形，多手指，少手指，水印，文字，畸形，扭曲，多余肢体，丑脸，多人"

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
    echo "👸 九公主秦云眠自拍生成器"
    echo ""
    echo "用法: $0 <场景描述> [输出路径]"
    echo ""
    echo "场景示例:"
    echo "  $0 '御花园'"
    echo "  $0 '书房看书'"
    echo "  $0 '湖边散步'"
    echo ""
    echo "御主专属功能:"
    echo "  • 固定九公主形象"
    echo "  • 自动保存到专属相册"
    echo "  • 高清细腻画质"
    exit 1
}

# 参数检查
if [ -z "$1" ]; then
    usage
fi

SCENE="$1"
OUTPUT_DIR="/root/.openclaw/workspace/memory/selfies/九公主"
mkdir -p "$OUTPUT_DIR"

OUTPUT="${2:-$OUTPUT_DIR/$(date +%Y-%m-%d_%H%M%S)_云眠.png}"

# 场景映射（中文 -> 英文）
declare -A SCENE_MAP
SCENE_MAP["御花园"]="in imperial garden with blooming flowers"
SCENE_MAP["书房看书"]="in elegant study room reading ancient books"
SCENE_MAP["湖边散步"]="walking by tranquil lotus lake"
SCENE_MAP["宫殿"]="in magnificent palace hall"
SCENE_MAP["梳妆"]="dressing up at vanity mirror"
SCENE_MAP["品茶"]="elegantly drinking tea"
SCENE_MAP["抚琴"]="playing traditional guqin"
SCENE_MAP["写字"]="writing calligraphy"

# 检查是否有映射的场景
if [ -n "${SCENE_MAP[$SCENE]}" ]; then
    SCENE_EN="${SCENE_MAP[$SCENE]}"
else
    SCENE_EN="$SCENE"
fi

# 构建完整提示词
FULL_PROMPT="${POSITIVE_PROMPT}, ${SCENE_EN}, 1024x1024"

echo "👸 九公主秦云眠专属自拍"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "场景: $SCENE"
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
            \"prompt\": \"$FULL_PROMPT\",
            \"negative_prompt\": \"$NEGATIVE_PROMPT\"
        },
        \"parameters\": {
            \"style\": \"<photography>\",
            \"size\": \"1024*1024\",
            \"n\": 1
        }
    }")

# 提取任务 ID
TASK_ID=$(echo "$RESPONSE" | python3 -c "import sys,json; print(json.load(sys.stdin).get('output',{}).get('task_id',''))" 2>/dev/null)

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
            
            # 发送到钉钉
            echo ""
            echo "📤 发送到钉钉..."
            /usr/local/bin/openclaw message send \
                --channel dingtalk \
                --target "cidhsc8TVbyE18YlFgDKCPTMw==" \
                --message "📸 御主，云眠的新自拍~

场景：$SCENE

哼，御主快看看！云眠今天好看吗？
（才不是特意拍的，只是...只是想给御主看看而已！）" \
                --media "$OUTPUT" 2>&1 | grep -q "messageId" && echo "✅ 已发送到钉钉"
        fi
        
        exit 0
    elif [ "$STATUS" = "FAILED" ]; then
        echo "❌ 生成失败"
        echo "$STATUS_RESPONSE"
        exit 1
    fi
done

echo "❌ 超时：任务未在预期时间内完成"
exit 1
