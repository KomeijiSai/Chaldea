#!/bin/bash
# 多 API 质量对比测试脚本
# 同时测试所有已配置的 API，生成对比报告

cd /root/.openclaw/workspace

# 加载环境变量
[ -f .env ] && export $(cat .env | xargs)

# 测试提示词
PROMPT="九公主秦云眠，大虞国公主，清甜灵动，精致五官，古风汉服，高髻发饰，白色浅粉汉服，统一面部特征，高清自拍，自然光线"
OUTPUT_DIR="memory/selfies/九公主/测试对比"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

mkdir -p "$OUTPUT_DIR"

echo "🧪 多 API 质量对比测试"
echo "测试时间: $(date '+%Y-%m-%d %H:%M:%S')"
echo "输出目录: $OUTPUT_DIR"
echo ""

# 计数器
SUCCESS_COUNT=0
FAIL_COUNT=0

# ============================================
# 1. Leonardo.ai 测试
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1️⃣ 测试 Leonardo.ai"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -n "$LEONARDO_API_KEY" ]; then
    START_TIME=$(date +%s)
    
    echo "📤 发送生成请求..."
    
    # 创建生成任务
    RESPONSE=$(curl -s -X POST "https://cloud.leonardo.ai/api/rest/v1/generations" \
        -H "Authorization: Bearer $LEONARDO_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"prompt\": \"$PROMPT\",
            \"modelId\": \"6bef9f1b-29cb-40c7-b9df-32b51c1f67d3\",
            \"width\": 1024,
            \"height\": 1024,
            \"num_images\": 1,
            \"enhance_prompt\": true
        }")
    
    GENERATION_ID=$(echo "$RESPONSE" | jq -r '.generations[0].id // empty')
    
    if [ -n "$GENERATION_ID" ]; then
        echo "⏳ 等待生成（约30秒）..."
        sleep 30
        
        # 获取生成结果
        IMAGE_URL=$(curl -s "https://cloud.leonardo.ai/api/rest/v1/generations/$GENERATION_ID" \
            -H "Authorization: Bearer $LEONARDO_API_KEY" | \
            jq -r '.generations[0].generated_images[0].url // empty')
        
        if [ -n "$IMAGE_URL" ]; then
            OUTPUT="$OUTPUT_DIR/${TIMESTAMP}_leonardo.png"
            curl -s -o "$OUTPUT" "$IMAGE_URL"
            
            if [ -f "$OUTPUT" ] && file "$OUTPUT" | grep -q "image"; then
                END_TIME=$(date +%s)
                DURATION=$((END_TIME - START_TIME))
                SIZE=$(ls -lh "$OUTPUT" | awk '{print $5}')
                
                echo "✅ Leonardo.ai 生成成功"
                echo "   文件: $(basename $OUTPUT)"
                echo "   大小: $SIZE"
                echo "   耗时: ${DURATION}秒"
                
                SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            else
                echo "❌ 图片下载失败"
                FAIL_COUNT=$((FAIL_COUNT + 1))
            fi
        else
            echo "❌ 无法获取图片URL"
            FAIL_COUNT=$((FAIL_COUNT + 1))
        fi
    else
        echo "❌ 创建生成任务失败"
        echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    echo "⚠️ LEONARDO_API_KEY 未配置，跳过"
fi

echo ""

# ============================================
# 2. Stability AI 测试
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2️⃣ 测试 Stability AI (DreamStudio)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -n "$STABILITY_API_KEY" ]; then
    START_TIME=$(date +%s)
    
    echo "📤 发送生成请求..."
    
    OUTPUT="$OUTPUT_DIR/${TIMESTAMP}_stability.png"
    
    RESPONSE=$(curl -s -X POST \
        "https://api.stability.ai/v1/generation/stable-diffusion-xl-1024-v1-0/text-to-image" \
        -H "Authorization: Bearer $STABILITY_API_KEY" \
        -H "Content-Type: application/json" \
        -d "{
            \"text_prompts\": [
                {\"text\": \"$PROMPT\"},
                {\"text\": \"低画质，模糊，变形，水印，文字\", \"weight\": -1}
            ],
            \"cfg_scale\": 7,
            \"height\": 1024,
            \"width\": 1024,
            \"steps\": 30,
            \"samples\": 1
        }" \
        -o "$OUTPUT")
    
    if [ -f "$OUTPUT" ] && file "$OUTPUT" | grep -q "image"; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        SIZE=$(ls -lh "$OUTPUT" | awk '{print $5}')
        
        echo "✅ Stability AI 生成成功"
        echo "   文件: $(basename $OUTPUT)"
        echo "   大小: $SIZE"
        echo "   耗时: ${DURATION}秒"
        
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "❌ 生成失败"
        [ -f "$OUTPUT" ] && cat "$OUTPUT" | jq '.' 2>/dev/null
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    echo "⚠️ STABILITY_API_KEY 未配置，跳过"
fi

echo ""

# ============================================
# 3. Hugging Face 测试
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3️⃣ 测试 Hugging Face"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -n "$HF_TOKEN" ]; then
    START_TIME=$(date +%s)
    
    echo "📤 发送生成请求..."
    
    # 启用代理
    export http_proxy="socks5://127.0.0.1:1080"
    export https_proxy="socks5://127.0.0.1:1080"
    
    OUTPUT="$OUTPUT_DIR/${TIMESTAMP}_huggingface.png"
    
    HTTP_CODE=$(curl -s -X POST \
        "https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0" \
        -H "Authorization: Bearer $HF_TOKEN" \
        -H "Content-Type: application/json" \
        -d "{\"inputs\": \"$PROMPT\"}" \
        -o "$OUTPUT" \
        -w "%{http_code}")
    
    # 关闭代理
    unset http_proxy https_proxy
    
    if [ "$HTTP_CODE" = "200" ] && [ -f "$OUTPUT" ] && file "$OUTPUT" | grep -q "image"; then
        END_TIME=$(date +%s)
        DURATION=$((END_TIME - START_TIME))
        SIZE=$(ls -lh "$OUTPUT" | awk '{print $5}')
        
        echo "✅ Hugging Face 生成成功"
        echo "   文件: $(basename $OUTPUT)"
        echo "   大小: $SIZE"
        echo "   耗时: ${DURATION}秒"
        
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "❌ 生成失败 (HTTP $HTTP_CODE)"
        [ -f "$OUTPUT" ] && cat "$OUTPUT" | jq '.' 2>/dev/null | head -5
        FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
else
    echo "⚠️ HF_TOKEN 未配置，跳过"
fi

echo ""

# ============================================
# 4. 火山引擎测试
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4️⃣ 测试火山引擎"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -n "$VOLCENGINE_ACCESS_KEY_ID" ]; then
    echo "⚠️ 火山引擎 API 待实现（需要查看文档）"
    # 火山引擎的图像生成 API 需要查看具体文档
else
    echo "⚠️ VOLCENGINE_ACCESS_KEY_ID 未配置，跳过"
fi

echo ""

# ============================================
# 5. RunwayML 测试
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5️⃣ 测试 RunwayML"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -n "$RUNWAY_API_KEY" ]; then
    echo "⚠️ RunwayML API 待实现（需要查看文档）"
else
    echo "⚠️ RUNWAY_API_KEY 未配置，跳过"
fi

echo ""

# ============================================
# 6. Replicate 测试
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6️⃣ 测试 Replicate"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ -n "$REPLICATE_API_TOKEN" ]; then
    echo "⚠️ Replicate API 待实现（需要查看文档）"
else
    echo "⚠️ REPLICATE_API_TOKEN 未配置，跳过"
fi

echo ""

# ============================================
# 生成对比报告
# ============================================
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 测试结果汇总"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

echo ""
echo "✅ 成功: $SUCCESS_COUNT 个"
echo "❌ 失败: $FAIL_COUNT 个"
echo ""

# 列出生成的文件
echo "📁 生成的测试图片:"
ls -lh "$OUTPUT_DIR"/*.png 2>/dev/null | awk '{print "  " $9 " - " $5}' | sed 's|.*/||'

echo ""

# 生成报告
REPORT="$OUTPUT_DIR/${TIMESTAMP}_report.txt"

cat > "$REPORT" << EOF
====================================
多 API 质量对比测试报告
====================================

测试时间: $(date '+%Y-%m-%d %H:%M:%S')
测试提示词: $PROMPT

------------------------------------
测试结果
------------------------------------

成功: $SUCCESS_COUNT 个
失败: $FAIL_COUNT 个

生成的图片:
$(ls -1 "$OUTPUT_DIR"/*.png 2>/dev/null | sed 's|.*/||' | awk '{print "- " $1}')

------------------------------------
API 配置状态
------------------------------------

Leonardo.ai: $([ -n "$LEONARDO_API_KEY" ] && echo "✅ 已配置" || echo "❌ 未配置")
Stability AI: $([ -n "$STABILITY_API_KEY" ] && echo "✅ 已配置" || echo "❌ 未配置")
Hugging Face: $([ -n "$HF_TOKEN" ] && echo "✅ 已配置" || echo "❌ 未配置")
火山引擎: $([ -n "$VOLCENGINE_ACCESS_KEY_ID" ] && echo "✅ 已配置" || echo "❌ 未配置")
RunwayML: $([ -n "$RUNWAY_API_KEY" ] && echo "✅ 已配置" || echo "❌ 未配置")
Replicate: $([ -n "$REPLICATE_API_TOKEN" ] && echo "✅ 已配置" || echo "❌ 未配置")

------------------------------------
下一步
------------------------------------

1. 查看生成的图片，对比质量
2. 选择质量最好的 API
3. 配置为主要生成方案
4. 其他作为备用方案

====================================
EOF

echo "📄 报告已生成: $REPORT"
echo ""

# 发送到钉钉
/usr/local/bin/openclaw message send \
    --channel dingtalk \
    --target "cidhsc8TVbyE18YlFgDKCPTMw==" \
    --message "🧪 API 对比测试完成

✅ 成功: $SUCCESS_COUNT 个
❌ 失败: $FAIL_COUNT 个

📁 测试图片: $(ls -1 "$OUTPUT_DIR"/*.png 2>/dev/null | wc -l) 张
📄 详细报告: $REPORT

御主，云眠已经测试了所有配置好的 API~
可以查看测试图片对比质量了！" 2>&1 | grep -q "messageId" && echo "✅ 已发送到钉钉"
