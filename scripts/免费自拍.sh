#!/bin/bash
# 多平台免费图像生成脚本
# 优先级：Leonardo.ai > Hugging Face > 本地缓存

cd /root/.openclaw/workspace

PROMPT="$1"
OUTPUT="${2:-memory/selfies/九公主/$(date +%Y-%m-%d_%H%M%S)_云眠.png}"

# 加载环境变量
[ -f .env ] && export $(cat .env | xargs)

echo "👸 九公主自拍生成（免费方案）"
echo "场景: $PROMPT"
echo ""

# 方案1: Leonardo.ai（需要API Key）
if [ -n "$LEONARDO_API_KEY" ]; then
    echo "尝试 Leonardo.ai..."
    RESPONSE=$(curl -s -X POST "https://cloud.leonardo.ai/api/rest/v1/generations" \
        -H "Authorization: Bearer $LEONARDO_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"prompt\": \"九公主秦云眠，大虞国公主，清甜灵动，精致五官，古风汉服，高髻发饰，白色浅粉汉服，统一面部特征，高清自拍，$PROMPT\",
            \"modelId\": \"6bef9f1b-29cb-40c7-b9df-32b51c1f67d3\",
            \"width\": 1024,
            \"height\": 1024,
            \"num_images\": 1
        }")
    
    if echo "$RESPONSE" | grep -q "generations"; then
        GENERATION_ID=$(echo "$RESPONSE" | jq -r '.generations[0].id')
        sleep 30
        
        IMAGE_URL=$(curl -s "https://cloud.leonardo.ai/api/rest/v1/generations/$GENERATION_ID" \
            -H "Authorization: Bearer $LEONARDO_API_KEY" | jq -r '.generations[0].generated_images[0].url')
        
        curl -s -o "$OUTPUT" "$IMAGE_URL"
        [ -f "$OUTPUT" ] && echo "✅ Leonardo.ai 生成成功" && exit 0
    fi
fi

# 方案2: Hugging Face（免费无限）
if [ -n "$HF_TOKEN" ]; then
    echo "尝试 Hugging Face..."
    export http_proxy="socks5://127.0.0.1:1080"
    export https_proxy="socks5://127.0.0.1:1080"
    
    curl -s -X POST \
        "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0" \
        -H "Authorization: Bearer $HF_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"inputs\": \"九公主秦云眠，$PROMPT, 古风汉服，高清自拍\"}" \
        -o "$OUTPUT"
    
    unset http_proxy https_proxy
    
    [ -f "$OUTPUT" ] && file "$OUTPUT" | grep -q "image" && echo "✅ Hugging Face 生成成功" && exit 0
fi

# 方案3: 使用缓存照片
echo "使用缓存照片..."
CACHED=$(ls -t memory/selfies/九公主/*.png 2>/dev/null | head -1)
[ -n "$CACHED" ] && cp "$CACHED" "$OUTPUT" && echo "✅ 使用缓存照片" && exit 0

echo "❌ 所有方案失败"
exit 1
