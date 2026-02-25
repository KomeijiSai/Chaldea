#!/bin/bash
# Git 自动同步脚本
# 用法: ./git_sync.sh [commit_message]

cd /root/.openclaw/workspace

# 检查是否有更改
if [ -z "$(git status --porcelain)" ]; then
    echo "✅ 没有需要同步的更改"
    exit 0
fi

# 获取 commit 消息
if [ -z "$1" ]; then
    MSG="🤖 Auto sync: $(date '+%Y-%m-%d %H:%M')"
else
    MSG="$1"
fi

# 添加、提交、推送
git add .
git commit -m "$MSG"

# 检查是否有远程仓库
if git remote | grep -q "origin"; then
    git push origin main
    echo "✅ 已推送到远程仓库"
else
    echo "⚠️ 没有配置远程仓库"
fi

echo "📝 Commit: $MSG"
