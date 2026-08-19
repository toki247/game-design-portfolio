extends Node2D
class_name MagicBall

# ============================================================
# 魔法球 - Boss 1 魔法师的远程飞弹(2026-07-03)
# 可见的紫色光球 + 光环
# ============================================================

const BALL_RADIUS: float = 14.0

# 配置参数(由 spawner 设置)
var lifetime: float = 3.0
var speed: float = 200.0
var inertia_distance: float = 96.0  # 闪避穿过后的惯性飞行距离
var damage: int = 1

# 运行时状态
var elapsed: float = 0.0
var player: Node2D = null
var inertia_remaining: float = 0.0
var passed_player: bool = false
var current_dir: Vector2 = Vector2.RIGHT
var prev_dist: float = 0.0
var prev_player_pos: Vector2 = Vector2.ZERO
var hit_player: bool = false
var has_exploded: bool = false

# 视觉效果
var trail_points: Array[Vector2] = []

func _ready() -> void:
	add_to_group("magic_ball")
	trail_points.append(position)
	queue_redraw()

func setup(lifetime_val: float, speed_val: float, inertia_val: float) -> void:
	lifetime = lifetime_val
	speed = speed_val
	inertia_distance = inertia_val

func _process(delta: float) -> void:
	elapsed += delta
	# 超时消散
	if elapsed >= lifetime:
		_explode()
		return

	# 获取玩家引用
	if not player:
		player = get_tree().get_first_node_in_group("player")
		if player:
			prev_player_pos = player.position
			prev_dist = position.distance_to(player.position)
	if not player:
		return

	# 移动
	if inertia_remaining > 0.0:
		# 惯性飞行:按 current_dir 直线飞
		position += current_dir * speed * delta
		inertia_remaining -= speed * delta
		# 惯性结束 → 重新索敌
		if inertia_remaining <= 0.0:
			passed_player = false
			prev_dist = position.distance_to(player.position)
	else:
		# 索敌玩家(最短路径)
		# 检查是否"穿过"玩家(距离由小变大)
		var dist_to_player: float = position.distance_to(player.position)
		if not passed_player and prev_dist < dist_to_player and prev_dist < 32.0:
			# 穿过了 → 进入惯性
			passed_player = true
			inertia_remaining = inertia_distance
			current_dir = (position - prev_player_pos).normalized()
		prev_dist = dist_to_player
		prev_player_pos = player.position
		if not passed_player:
			position += (player.position - position).normalized() * speed * delta

	# 检测命中玩家
	if not hit_player:
		var dist: float = position.distance_to(player.position)
		if dist < BALL_RADIUS + 16.0:  # 玩家碰撞体 16x16
			_hit_player()

	# 拖尾记录
	trail_points.append(position)
	if trail_points.size() > 8:
		trail_points.pop_front()
	queue_redraw()

func _hit_player() -> void:
	hit_player = true
	# 玩家受击
	if player and player.has_method("take_damage"):
		player.take_damage(damage)
	# 爆炸消失
	_explode()

func _explode() -> void:
	if has_exploded:
		return
	has_exploded = true
	# 创建爆炸效果(简单:画一个白圆并 fade out)
	var explosion := Node2D.new()
	explosion.position = position
	var ExplosionScript = GDScript.new() if false else null
	get_tree().current_scene.add_child(explosion)
	explosion.queue_free()
	queue_free()

func _draw() -> void:
	# 拖尾(8 个历史位置)
	for i in trail_points.size():
		var p: Vector2 = trail_points[i]
		var alpha: float = float(i) / float(trail_points.size()) * 0.6
		var r: float = BALL_RADIUS * (0.4 + 0.6 * float(i) / float(trail_points.size()))
		draw_circle(p, r, Color(0.7, 0.2, 1.0, alpha))
	# 主球
	draw_circle(Vector2.ZERO, BALL_RADIUS, Color(0.6, 0.1, 0.9, 0.9))
	# 外光圈
	draw_arc(Vector2.ZERO, BALL_RADIUS * 1.6, 0, TAU, 24, Color(1, 0.5, 1, 0.5), 3.0)
	# 内核
	draw_circle(Vector2.ZERO, BALL_RADIUS * 0.4, Color(1, 0.8, 1, 0.9))