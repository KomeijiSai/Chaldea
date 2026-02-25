#!/bin/bash
# 使用 GitHub API 推送文件
# 用法: ./scripts/github_api_push.sh <file_path> <repo_path> <commit_message>
# 需要设置环境变量: GITHUB_TOKEN

TOKEN="${GITHUB_TOKEN:-}"
REPO="KomeijiSai/Chaldea"
BRANCH="main"

if [ -z "$TOKEN" ]; then
    echo "❌ 错误: 请设置 GITHUB_TOKEN 环境变量"
    exit 1
fi

FILE_PATH="$1"
REPO_PATH="$2"
MESSAGE="$3"

if [ -z "$FILE_PATH" ] || [ -z "$REPO_PATH" ]; then
    echo "用法: $0 <本地文件路径> <仓库路径> [提交信息]"
    exit 1
fi

MESSAGE="${MESSAGE:-Update $REPO_PATH}"

# 获取文件的 SHA（如果存在）
SHA=$(curl -s -H "Authorization: token $TOKEN" \
    "https://api.github.com/repos/$REPO/contents/$REPO_PATH?ref=$BRANCH" | jq -r '.sha // empty')

# Base64 编码文件内容
CONTENT=$(base64 -w 0 "$FILE_PATH")

# 准备 JSON
if [ -n "$SHA" ]; then
    # 更新现有文件
    JSON=$(jq -n \
        --arg message "$MESSAGE" \
        --arg content "$CONTENT" \
        --arg sha "$SHA" \
        --arg branch "$BRANCH" \
        '{message: $message, content: $content, sha: $sha, branch: $branch}')
else
    # 创建新文件
    JSON=$(jq -n \
        --arg message "$MESSAGE" \
        --arg content "$CONTENT" \
        --arg branch "$BRANCH" \
        '{message: $message, content: $content, branch: $branch}')
fi

# 推送
RESPONSE=$(curl -s -X PUT \
    -H "Authorization: token $TOKEN" \
    -H "Accept: application/vnd.github.v3+json" \
    "https://api.github.com/repos/$REPO/contents/$REPO_PATH" \
    -d "$JSON")

if echo "$RESPONSE" | jq -e '.content' > /dev/null 2>&1; then
    echo "✅ 推送成功: $REPO_PATH"
else
    echo "❌ 推送失败: $REPO_PATH"
    echo "$RESPONSE" | jq -r '.message // .'
fi
