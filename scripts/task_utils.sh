#!/bin/bash
# 通用任务工具函数库
# 用法: source scripts/task_utils.sh

# ============================================
# 1. 任务去重检查
# ============================================
check_duplicate_task() {
    local content="$1"
    local existing=$(./scripts/todoist_api.sh "tasks" "GET" 2>/dev/null | \
        jq -r ".[] | select(.content | contains(\"$content\")) | .id" 2>/dev/null)

    if [ -n "$existing" ]; then
        echo "⚠️ 任务已存在: $content (ID: $existing)"
        return 0  # 存在重复
    fi
    return 1  # 不存在重复
}

# ============================================
# 2. 网络重试机制（指数退避）
# ============================================
retry_git_operation() {
    local operation="$1"  # "pull" 或 "push"
    local max_attempts=3
    local delay=10

    for i in $(seq 1 $max_attempts); do
        case "$operation" in
            "pull")
                if git pull origin main 2>/dev/null; then
                    echo "✅ Git pull 成功"
                    return 0
                fi
                ;;
            "push")
                if git push origin main 2>/dev/null; then
                    echo "✅ Git push 成功"
                    return 0
                fi
                ;;
        esac

        if [ $i -lt $max_attempts ]; then
            echo "⚠️ 第 $i 次尝试失败，${delay}秒后重试..."
            sleep $delay
            delay=$((delay * 2))  # 指数退避: 10s -> 20s -> 40s
        fi
    done

    echo "❌ Git $operation 失败，已重试 $max_attempts 次"
    return 1
}

# ============================================
# 3. 外部任务验证
# ============================================
VALID_SOURCES=("coding-agent" "healthcheck-agent" "manual" "external")

validate_external_task() {
    local task="$1"
    local source=$(echo "$task" | jq -r '.source')
    local priority=$(echo "$task" | jq -r '.priority')
    local content=$(echo "$task" | jq -r '.content')

    # 检查必填字段
    if [ -z "$source" ] || [ -z "$content" ]; then
        echo "❌ 任务缺少必填字段"
        return 1
    fi

    # 检查来源白名单
    local source_valid=false
    for valid_source in "${VALID_SOURCES[@]}"; do
        if [ "$source" = "$valid_source" ]; then
            source_valid=true
            break
        fi
    done

    if [ "$source_valid" = false ]; then
        echo "❌ 无效的任务来源: $source (允许: ${VALID_SOURCES[*]})"
        return 1
    fi

    # 检查优先级范围
    if [ "$priority" -lt 1 ] || [ "$priority" -gt 4 ] 2>/dev/null; then
        echo "❌ 无效的优先级: $priority (允许: 1-4)"
        return 1
    fi

    return 0
}

# ============================================
# 4. 检查点管理
# ============================================
CHECKPOINT_FILE="memory/system/checkpoint.json"

init_checkpoint() {
    mkdir -p memory/system
    if [ ! -f "$CHECKPOINT_FILE" ]; then
        echo '{
  "lastCompletedTask": null,
  "lastHeartbeat": null,
  "currentTask": null,
  "pendingActions": [],
  "contextSnapshot": {}
}' > "$CHECKPOINT_FILE"
    fi
}

save_checkpoint() {
    local key="$1"
    local value="$2"

    init_checkpoint
    local temp=$(mktemp)
    jq "$key = $value" "$CHECKPOINT_FILE" > "$temp" && mv "$temp" "$CHECKPOINT_FILE"
}

load_checkpoint() {
    local key="$1"
    init_checkpoint
    jq -r "$key // empty" "$CHECKPOINT_FILE" 2>/dev/null
}

start_task_checkpoint() {
    local task_id="$1"
    local task_content="$2"

    save_checkpoint '.currentTask' "{\"id\": \"$task_id\", \"content\": \"$task_content\", \"startedAt\": \"$(date -Iseconds)\"}"
}

complete_task_checkpoint() {
    local task_id="$1"
    local result="$2"

    save_checkpoint '.lastCompletedTask' "{\"id\": \"$task_id\", \"result\": \"$result\", \"completedAt\": \"$(date -Iseconds)\"}"
    save_checkpoint '.currentTask' 'null'
}

# ============================================
# 5. 任务执行超时检测
# ============================================
MAX_TASK_DURATION=3600  # 1 小时（秒）

check_task_timeout() {
    local started_at=$(load_checkpoint '.currentTask.startedAt')

    if [ -z "$started_at" ] || [ "$started_at" = "null" ]; then
        return 0  # 没有正在执行的任务
    fi

    # 转换时间戳
    local started_ts=$(date -d "$started_at" +%s 2>/dev/null || echo "0")
    local now_ts=$(date +%s)
    local duration=$((now_ts - started_ts))

    if [ "$duration" -gt "$MAX_TASK_DURATION" ]; then
        echo "⚠️ 任务执行超时: ${duration}秒 > ${MAX_TASK_DURATION}秒"
        return 1
    fi

    return 0
}

# ============================================
# 6. 健康自检
# ============================================
self_health_check() {
    local issues=""

    # 检查网络连接
    if ! ping -c 1 -W 3 github.com &>/dev/null; then
        issues="${issues}network_unavailable,"
    fi

    # 检查 Todoist API
    if ! ./scripts/todoist_api.sh "projects" "GET" &>/dev/null | jq -e '.id' &>/dev/null; then
        issues="${issues}todoist_api_error,"
    fi

    # 检查磁盘空间
    local disk_usage=$(df -h / | tail -1 | awk '{print $5}' | tr -d '%')
    if [ "$disk_usage" -gt 80 ]; then
        issues="${issues}disk_full(${disk_usage}%),"
    fi

    # 检查任务超时
    if ! check_task_timeout; then
        issues="${issues}task_timeout,"
    fi

    if [ -n "$issues" ]; then
        echo "⚠️ 健康检查发现问题: ${issues%,}"
        return 1
    fi

    echo "✅ 健康检查通过"
    return 0
}

# ============================================
# 7. 心跳增量检查
# ============================================
LAST_CHECK_FILE="memory/system/last-check-time"

should_full_check() {
    local last_check=$(cat "$LAST_CHECK_FILE" 2>/dev/null || echo "0")
    local now=$(date +%s)
    local interval=$((now - last_check))

    # 超过 1 小时做完整检查
    if [ "$interval" -gt 3600 ]; then
        echo "full"
        return 0
    fi

    # 超过 5 分钟做快速检查
    if [ "$interval" -gt 300 ]; then
        echo "quick"
        return 0
    fi

    # 小于 5 分钟跳过
    echo "skip"
}

update_heartbeat_time() {
    mkdir -p memory/system
    date +%s > "$LAST_CHECK_FILE"
}
