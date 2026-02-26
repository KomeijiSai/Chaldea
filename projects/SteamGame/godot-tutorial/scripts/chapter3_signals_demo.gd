# ===================================
# Godot 4 - 第3章实战示例
# 信号通信演示项目
# ===================================

# player.gd - 玩家脚本（演示信号发射）
# ===================================
extends CharacterBody2D
class_name Player

# 定义信号
signal health_changed(new_health: int, max_health: int)
signal player_died
signal item_collected(item_name: String, value: int)
signal position_updated(pos: Vector2)

# 导出变量
@export var max_health: int = 100
@export var speed: float = 200.0

# 私有变量
var current_health: int
var items: Array[String] = []

func _ready():
    current_health = max_health
    print("Player ready with %d health" % max_health)

func _physics_process(delta):
    var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_dir * speed
    move_and_slide()
    
    if velocity.length() > 0:
        emit_signal("position_updated", global_position)

# 受伤函数
func take_damage(amount: int):
    current_health = max(0, current_health - amount)
    emit_signal("health_changed", current_health, max_health)
    
    if current_health == 0:
        emit_signal("player_died")
        die()

# 治疗函数
func heal(amount: int):
    current_health = min(max_health, current_health + amount)
    emit_signal("health_changed", current_health, max_health)

# 收集物品
func collect_item(item_name: String, value: int):
    items.append(item_name)
    emit_signal("item_collected", item_name, value)

# 死亡
func die():
    print("Player died!")
    queue_free()

# ===================================
# health_ui.gd - 血量UI脚本（演示信号接收）
# ===================================
extends Control

@onready var health_bar = $ProgressBar
@onready var health_label = $Label

func _ready():
    # 等待父节点准备完毕
    await get_tree().process_frame
    
    # 找到玩家并连接信号
    var player = get_tree().get_first_node_in_group("player")
    if player:
        player.health_changed.connect(_on_player_health_changed)
        player.player_died.connect(_on_player_died)
        print("Health UI connected to player signals")

func _on_player_health_changed(new_health: int, max_health: int):
    health_bar.max_value = max_health
    health_bar.value = new_health
    health_label.text = "HP: %d / %d" % [new_health, max_health]
    
    # 低血量警告
    if new_health < max_health * 0.3:
        health_bar.modulate = Color.RED
    else:
        health_bar.modulate = Color.GREEN

func _on_player_died():
    health_label.text = "GAME OVER"
    health_label.modulate = Color.RED

# ===================================
# score_manager.gd - 计分管理器（单例模式）
# ===================================
extends Node

signal score_updated(new_score: int)
signal new_high_score(score: int)
signal combo_achieved(multiplier: float)

var current_score: int = 0
var high_score: int = 0
var combo_count: int = 0
var combo_timer: float = 0.0

func _process(delta):
    if combo_timer > 0:
        combo_timer -= delta
        if combo_timer <= 0:
            combo_count = 0

func add_points(base_points: int):
    var multiplier = 1.0 + (combo_count * 0.1)
    var points = int(base_points * multiplier)
    
    current_score += points
    emit_signal("score_updated", current_score)
    
    # 更新连击
    combo_count += 1
    combo_timer = 2.0  # 2秒连击窗口
    
    if combo_count >= 3:
        emit_signal("combo_achieved", multiplier)
    
    # 检查高分
    if current_score > high_score:
        high_score = current_score
        emit_signal("new_high_score", high_score)

func reset_score():
    current_score = 0
    combo_count = 0
    emit_signal("score_updated", current_score)

# ===================================
# game_manager.gd - 游戏管理器（全局单例）
# ===================================
extends Node

signal game_started
signal game_paused
signal game_resumed
signal game_over(final_score: int)
signal level_completed(level_number: int)

enum GameState { MENU, PLAYING, PAUSED, GAME_OVER }

var current_state: GameState = GameState.MENU
var current_level: int = 1

func _input(event):
    if event.is_action_pressed("ui_cancel"):
        if current_state == GameState.PLAYING:
            pause_game()
        elif current_state == GameState.PAUSED:
            resume_game()

func start_game():
    current_state = GameState.PLAYING
    current_level = 1
    emit_signal("game_started")
    get_tree().paused = false

func pause_game():
    current_state = GameState.PAUSED
    emit_signal("game_paused")
    get_tree().paused = true

func resume_game():
    current_state = GameState.PLAYING
    emit_signal("game_resumed")
    get_tree().paused = false

func end_game():
    current_state = GameState.GAME_OVER
    var final_score = ScoreManager.current_score
    emit_signal("game_over", final_score)

func complete_level():
    emit_signal("level_completed", current_level)
    current_level += 1

# ===================================
# enemy.gd - 敌人脚本（演示信号组）
# ===================================
extends CharacterBody2D
class_name Enemy

signal died(enemy: Enemy)
signal hit_player(damage: int)

@export var health: int = 50
@export var damage: int = 10

func take_damage(amount: int):
    health -= amount
    
    # 视觉反馈
    modulate = Color.RED
    await get_tree().create_timer(0.1).timeout
    modulate = Color.WHITE
    
    if health <= 0:
        die()

func die():
    emit_signal("died", self)
    queue_free()

# ===================================
# 使用示例
# ===================================

# 在主场景中的用法示例：
# main.gd
extends Node2D

func _ready():
    # 连接游戏管理器信号
    GameManager.game_over.connect(_on_game_over)
    GameManager.level_completed.connect(_on_level_completed)
    
    # 连接计分管理器信号
    ScoreManager.score_updated.connect(_on_score_updated)
    ScoreManager.new_high_score.connect(_on_new_high_score)
    
    # 开始游戏
    GameManager.start_game()

func _on_game_over(final_score: int):
    print("Game Over! Final Score: %d" % final_score)

func _on_level_completed(level: int):
    print("Level %d completed!" % level)

func _on_score_updated(new_score: int):
    print("Score: %d" % new_score)

func _on_new_high_score(score: int):
    print("NEW HIGH SCORE: %d!" % score)
