#!/bin/bash
# 初始化检查点系统
# 用法: ./scripts/init_checkpoint.sh

cd /root/.openclaw/workspace

# 加载工具函数
source scripts/task_utils.sh

echo "🔧 初始化检查点系统..."

# 初始化检查点文件
init_checkpoint

# 初始化心跳时间文件
mkdir -p memory/system
date +%s > memory/system/last-check-time

echo "✅ 检查点系统初始化完成"
echo ""
echo "创建的文件:"
echo " - $CHECKPOINT_FILE"
echo " - memory/system/last-check-time"
