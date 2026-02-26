#!/bin/bash
# API Key 快速配置脚本

cd /root/.openclaw/workspace

echo "🔧 API Key 配置工具"
echo ""

# 检查 .env 文件
if [ ! -f .env ]; then
    touch .env
    echo "✅ 创建 .env 文件"
fi

# Leonardo.ai
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "1. Leonardo.ai"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "注册地址: https://leonardo.ai/"
echo "API Key 地址: https://app.leonardo.ai/api-keys"
echo ""
read -p "请输入 Leonardo API Key (留空跳过): " LEONARDO_KEY
if [ -n "$LEONARDO_KEY" ]; then
    if grep -q "LEONARDO_API_KEY" .env; then
        sed -i "s/LEONARDO_API_KEY=.*/LEONARDO_API_KEY=$LEONARDO_KEY/" .env
    else
        echo "LEONARDO_API_KEY=$LEONARDO_KEY" >> .env
    fi
    echo "✅ Leonardo API Key 已配置"
fi
echo ""

# Stability AI
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "2. Stability AI (DreamStudio)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "注册地址: https://dreamstudio.ai/"
echo "API Key 地址: https://dreamstudio.ai/account"
echo ""
read -p "请输入 Stability API Key (留空跳过): " STABILITY_KEY
if [ -n "$STABILITY_KEY" ]; then
    if grep -q "STABILITY_API_KEY" .env; then
        sed -i "s/STABILITY_API_KEY=.*/STABILITY_API_KEY=$STABILITY_KEY/" .env
    else
        echo "STABILITY_API_KEY=$STABILITY_KEY" >> .env
    fi
    echo "✅ Stability API Key 已配置"
fi
echo ""

# Hugging Face
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "3. Hugging Face"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "注册地址: https://huggingface.co/join"
echo "Token 地址: https://huggingface.co/settings/tokens"
echo ""
read -p "请输入 Hugging Face Token (留空跳过): " HF_KEY
if [ -n "$HF_KEY" ]; then
    if grep -q "HF_TOKEN" .env; then
        sed -i "s/HF_TOKEN=.*/HF_TOKEN=$HF_KEY/" .env
    else
        echo "HF_TOKEN=$HF_KEY" >> .env
    fi
    echo "✅ Hugging Face Token 已配置"
fi
echo ""

# 火山引擎
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "4. 火山引擎"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "注册地址: https://www.volcengine.com/"
echo "Key 地址: https://console.volcengine.com/iam/keymanage/"
echo ""
read -p "请输入火山引擎 Access Key ID (留空跳过): " VOLC_ID
if [ -n "$VOLC_ID" ]; then
    read -p "请输入火山引擎 Access Key Secret: " VOLC_SECRET
    if grep -q "VOLCENGINE_ACCESS_KEY_ID" .env; then
        sed -i "s/VOLCENGINE_ACCESS_KEY_ID=.*/VOLCENGINE_ACCESS_KEY_ID=$VOLC_ID/" .env
        sed -i "s/VOLCENGINE_ACCESS_KEY_SECRET=.*/VOLCENGINE_ACCESS_KEY_SECRET=$VOLC_SECRET/" .env
    else
        echo "VOLCENGINE_ACCESS_KEY_ID=$VOLC_ID" >> .env
        echo "VOLCENGINE_ACCESS_KEY_SECRET=$VOLC_SECRET" >> .env
    fi
    echo "✅ 火山引擎已配置"
fi
echo ""

# RunwayML
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "5. RunwayML"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "注册地址: https://runwayml.com/"
echo "API Key 地址: https://runwayml.com/account/api"
echo ""
read -p "请输入 RunwayML API Key (留空跳过): " RUNWAY_KEY
if [ -n "$RUNWAY_KEY" ]; then
    if grep -q "RUNWAY_API_KEY" .env; then
        sed -i "s/RUNWAY_API_KEY=.*/RUNWAY_API_KEY=$RUNWAY_KEY/" .env
    else
        echo "RUNWAY_API_KEY=$RUNWAY_KEY" >> .env
    fi
    echo "✅ RunwayML API Key 已配置"
fi
echo ""

# Replicate
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "6. Replicate"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "注册地址: https://replicate.com/"
echo "Token 地址: https://replicate.com/account/api-tokens"
echo ""
read -p "请输入 Replicate API Token (留空跳过): " REPLICATE_KEY
if [ -n "$REPLICATE_KEY" ]; then
    if grep -q "REPLICATE_API_TOKEN" .env; then
        sed -i "s/REPLICATE_API_TOKEN=.*/REPLICATE_API_TOKEN=$REPLICATE_KEY/" .env
    else
        echo "REPLICATE_API_TOKEN=$REPLICATE_KEY" >> .env
    fi
    echo "✅ Replicate API Token 已配置"
fi
echo ""

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ 配置完成"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "下一步: 运行测试脚本"
echo "  ./scripts/test_all_apis.sh"
