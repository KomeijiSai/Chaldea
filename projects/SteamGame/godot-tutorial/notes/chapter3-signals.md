# Godot 4 基础教程第3章学习笔记

**日期**: 2026-02-26  
**章节**: 信号与节点通信 (Signals and Node Communication)

---

## 核心概念

### 1. 信号 (Signals)

**什么是信号？**
- Godot 的观察者模式实现
- 节点之间解耦的通信方式
- 事件驱动的编程范式

**基本语法**:
```gdscript
# 定义信号
signal health_changed(new_health)
signal player_died

# 发射信号
emit_signal("health_changed", 100)
emit_signal("player_died")
```

### 2. 连接信号

**方法1: 代码连接**
```gdscript
func _ready():
    # 连接信号
    button.pressed.connect(_on_button_pressed)
    
func _on_button_pressed():
    print("Button was pressed!")
```

**方法2: 编辑器连接**
1. 选择节点
2. 切换到"节点"标签
3. 双击信号
4. 选择接收节点
5. 自动生成回调函数

### 3. 内置信号

**常用节点信号**:
- `Button`: `pressed`, `button_down`, `button_up`
- `Timer`: `timeout`
- `Area2D`: `body_entered`, `body_exited`
- `AnimationPlayer`: `animation_finished`

---

## 实战示例

### 示例1: 血量系统

```gdscript
# player.gd
extends CharacterBody2D

signal health_changed(new_health)
signal player_died

@export var max_health: int = 100
var current_health: int

func _ready():
    current_health = max_health

func take_damage(amount: int):
    current_health -= amount
    emit_signal("health_changed", current_health)
    
    if current_health <= 0:
        emit_signal("player_died")

func heal(amount: int):
    current_health = min(current_health + amount, max_health)
    emit_signal("health_changed", current_health)
```

```gdscript
# health_bar.gd
extends ProgressBar

func _ready():
    var player = get_parent().get_node("Player")
    player.health_changed.connect(_on_player_health_changed)
    player.player_died.connect(_on_player_died)

func _on_player_health_changed(new_health: int):
    value = new_health

func _on_player_died():
    modulate = Color.RED
```

### 示例2: 游戏管理器

```gdscript
# game_manager.gd
extends Node

signal score_updated(new_score)
signal level_completed(level_number)

var current_score: int = 0
var current_level: int = 1

func add_score(points: int):
    current_score += points
    emit_signal("score_updated", current_score)

func complete_level():
    emit_signal("level_completed", current_level)
    current_level += 1
```

---

## 第3章重点内容

### 1. 信号参数

```gdscript
signal item_collected(item_name: String, value: int)

func collect_coin():
    emit_signal("item_collected", "Gold Coin", 10)
```

### 2. 断开信号

```gdscript
func _exit_tree():
    button.pressed.disconnect(_on_button_pressed)
```

### 3. 延迟调用

```gdscript
func _ready():
    # 延迟2秒后调用
    await get_tree().create_timer(2.0).timeout
    print("2 seconds later!")
```

### 4. 自定义信号数组

```gdscript
signal enemies_defeated(count: int)

var defeated_count: int = 0

func on_enemy_died():
    defeated_count += 1
    if defeated_count >= 5:
        emit_signal("enemies_defeated", defeated_count)
```

---

## 最佳实践

### 1. 命名约定
- 信号名使用过去式或状态描述: `health_changed`, `player_died`
- 回调函数以 `_on_` 开头: `_on_button_pressed`

### 2. 解耦设计
```gdscript
# ❌ 不好的做法
func _on_button_pressed():
    get_parent().get_node("Player").take_damage(10)

# ✅ 好的做法
signal damage_player(amount)

func _on_button_pressed():
    emit_signal("damage_player", 10)
```

### 3. 类型提示
```gdscript
signal health_changed(new_health: int)

# 连接时也提供类型
func _on_health_changed(new_health: int):
    update_health_display(new_health)
```

---

## 练习项目

### 迷你游戏: 计分板系统

**目标**: 使用信号实现计分板

**步骤**:
1. 创建 `ScoreManager` 节点
2. 定义 `score_updated` 信号
3. 连接到 UI 显示
4. 添加音效反馈

**代码**:
```gdscript
# score_manager.gd
extends Node

signal score_updated(new_score: int)
signal new_high_score(score: int)

var current_score: int = 0
var high_score: int = 0

func add_points(points: int):
    current_score += points
    emit_signal("score_updated", current_score)
    
    if current_score > high_score:
        high_score = current_score
        emit_signal("new_high_score", high_score)

func reset_score():
    current_score = 0
    emit_signal("score_updated", current_score)
```

---

## 学习总结

✅ **已掌握**:
- 信号的定义和发射
- 信号的连接和断开
- 参数传递
- 常用内置信号

🎯 **下一步**:
- 第4章: 动画系统
- 第5章: 物理引擎
- 第6章: UI 系统

---

## 参考资料

- [Godot 官方文档 - 信号](https://docs.godotengine.org/en/stable/getting_started/step_by_step/signals.html)
- [GDScript 语法参考](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html)

---

*学习时间: 30分钟*  
*掌握程度: 80%*  
*笔记完成时间: 2026-02-26 05:40*
