#!/bin/bash
# 上传自拍到 GitHub
# 用法: ./scripts/upload_selfie.sh <图片路径> <场景描述>

cd /root/.openclaw/workspace

# 加载环境变量
. ./.env 2>/dev/null

IMAGE_PATH="$1"
SCENE="$2"

if [ ! -f "$IMAGE_PATH" ]; then
    echo "❌ 图片不存在: $IMAGE_PATH"
    exit 1
fi

# 生成文件名
DATE=$(date +%Y-%m-%d)
SCENE_SLUG=$(echo "$SCENE" | tr ' ' '-' | tr -cd 'a-zA-Z0-9-' | head -20)
FILENAME="${DATE}_${SCENE_SLUG}.png"

# 复制到相册
cp "$IMAGE_PATH" "memory/selfies/$FILENAME"
echo "✅ 已保存到相册: memory/selfies/$FILENAME"

# 更新相册文件
ALBUM_FILE="memory/selfies/ALBUM.md"
if [ -f "$ALBUM_FILE" ]; then
    # 添加新记录
    echo "" >> "$ALBUM_FILE"
    echo "### $(date '+%H:%M') - ${SCENE}" >> "$ALBUM_FILE"
    echo "- **文件**: \`$FILENAME\`" >> "$ALBUM_FILE"
    echo "- **场景**: $SCENE" >> "$ALBUM_FILE"
    echo "- **大小**: $(ls -lh "$IMAGE_PATH" | awk '{print $5}')" >> "$ALBUM_FILE"
    echo "✅ 已更新相册文件"
fi

# 同步到 GitHub（使用 Git 命令）
if command -v git &> /dev/null && [ -d ".git" ]; then
    echo "📤 上传到 GitHub..."
    
    # 添加文件
    git add "memory/selfies/$FILENAME" 2>/dev/null || true
    git add "memory/selfies/ALBUM.md" 2>/dev/null || true
    
    # 提交
    git commit -m "📸 新自拍: $SCENE" 2>/dev/null || true
    
    # 推送（使用代理）
    git config --global http.proxy socks5://127.0.0.1:1080 2>/dev/null || true
    git push origin main 2>&1 | head -5
    
    echo "✅ 上传完成"
fi

echo ""
echo "📸 自拍已保存: memory/selfies/$FILENAME"
echo "🔗 GitHub: https://github.com/KomeijiSai/Chaldea/tree/main/memory/selfies"
