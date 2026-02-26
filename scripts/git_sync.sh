#!/bin/bash
# Git 自动同步脚本 (使用 GitHub API)
# 由于服务器网络限制，使用 GitHub API 推送而非 git push
# 用法: ./scripts/git_sync.sh [commit_message]

cd /root/.openclaw/workspace

# 加载环境变量
source .env 2>/dev/null

if [ -z "$GITHUB_TOKEN" ]; then
    echo "❌ 错误: GITHUB_TOKEN 未设置"
    exit 1
fi

# GitHub API 推送函数
push_file() {
    local file_path="$1"
    local repo_path="$2"
    local message="$3"
    
    if [ ! -f "$file_path" ]; then
        return
    fi
    
    # 获取文件的 SHA（如果存在）
    local SHA=$(curl -s -H "Authorization: token $GITHUB_TOKEN" \
        "https://api.github.com/repos/KomeijiSai/Chaldea/contents/$repo_path?ref=main" | jq -r '.sha // empty')
    
    # Base64 编码文件内容
    local CONTENT=$(base64 -w 0 "$file_path")
    
    # 准备 JSON
    local JSON
    if [ -n "$SHA" ]; then
        JSON=$(jq -n \
            --arg message "$message" \
            --arg content "$CONTENT" \
            --arg sha "$SHA" \
            '{message: $message, content: $content, sha: $sha, branch: "main"}')
    else
        JSON=$(jq -n \
            --arg message "$message" \
            --arg content "$CONTENT" \
            '{message: $message, content: $content, branch: "main"}')
    fi
    
    # 推送
    local RESPONSE=$(curl -s -X PUT \
        -H "Authorization: token $GITHUB_TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/KomeijiSai/Chaldea/contents/$repo_path" \
        -d "$JSON")
    
    if echo "$RESPONSE" | jq -e '.content' > /dev/null 2>&1; then
        echo "✅ $repo_path"
    else
        echo "❌ $repo_path: $(echo "$RESPONSE" | jq -r '.message // .')"
    fi
}

# 获取 commit 消息
MSG="${1:-🤖 Auto sync: $(date '+%Y-%m-%d %H:%M')}"

echo "📤 开始同步到 GitHub..."
echo "📝 $MSG"
echo ""

# 同步核心文件
push_file "memory/AUTO_WORK_SYSTEM.md" "memory/AUTO_WORK_SYSTEM.md" "$MSG"
push_file "memory/EVOLUTION_DIARY.md" "memory/EVOLUTION_DIARY.md" "$MSG"
push_file "memory/current-state.json" "memory/current-state.json" "$MSG"
push_file "MEMORY.md" "MEMORY.md" "$MSG"

echo ""
echo "✅ 同步完成"
