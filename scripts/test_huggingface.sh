#!/bin/bash
# Hugging Face 图像生成测试脚本
# 使用 Inference API（免费）

cd /root/.openclaw/workspace

# 加载环境变量
if [ -f .env ]; then
    export $(cat .env | grep HF_TOKEN | xargs)
fi

# 检查 API Key
if [ -z "$HF_TOKEN" ]; then
    echo "❌ 错误: HF_TOKEN 未设置"
    exit 1
fi

MODEL="stabilityai/stable-diffusion-xl-base-1.0"
PROMPT="九公主秦云眠，大虞国公主，清甜灵动，精致五官，古风汉服，高髻发饰，白色浅粉汉服，统一面部特征，高清自拍"

echo "🎨 Hugging Face 图像生成测试"
echo "模型: $MODEL"
echo ""

# 启用代理
export http_proxy="socks5://127.0.0.1:1080"
export https_proxy="socks5://127.0.0.1:1080"

# 调用 Hugging Face Inference API
echo "📤 发送生成请求..."
RESPONSE=$(curl -s -X POST \
    "https://api-inference.huggingface.co/models/$MODEL" \
    -H "Authorization: Bearer $HF_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
        \"inputs\": \"$PROMPT\",
        \"parameters\": {
            \"negative_prompt\": \"低画质，模糊，变形，多手指，水印，文字\",
            \"num_inference_steps\": 30
        }
    }" \
    --output /tmp/hf_test.png \
    --write-out "%{http_code}")

HTTP_CODE=$RESPONSE

# 关闭代理
unset http_proxy
unset https_proxy

# 检查结果
if [ "$HTTP_CODE" = "200" ]; then
    if [ -f /tmp/hf_test.png ]; then
        SIZE=$(ls -lh /tmp/hf_test.png | awk '{print $5}')
        echo "✅ 生成成功！"
        echo "大小: $SIZE"
        
        # 移动到相册
        OUTPUT="/root/.openclaw/workspace/memory/selfies/九公主/$(date +%Y-%m-%d_%H%M%S)_hf_test.png"
        mv /tmp/hf_test.png "$OUTPUT"
        echo "保存到: $OUTPUT"
    else
        echo "❌ 文件未生成"
    fi
else
    echo "❌ API 调用失败 (HTTP $HTTP_CODE)"
    
    # 显示错误信息
    if [ -f /tmp/hf_test.png ]; then
        cat /tmp/hf_test.png
    fi
fi
