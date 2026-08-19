extends CharacterBody2D
class_name BossMage

# ============================================================
# 封印勇者 - Boss 1 魔法师
# 2026-07-03 实现:
# - 5 技能:瞬移(被动) / 魔法球 / 激光 / 震荡 / 黑幕
# - 距离 AI:远距离→魔法球,中距离→震荡,近距离→激光
# - 瞬移计数:每 2 次普通瞬移,第 3 次带黑幕
# - 黑幕:场地黑雾,护身符照亮 2 格,Boss 受攻击不瞬移只受 1 伤
# ============================================================

# === 尺寸 ===
const TILE_SIZE: int = 32

# 战斗场地 70x50 格(2026-07-03 改为 70x50)
const ARENA_WIDTH_TILES: int = 70
const ARENA_HEIGHT_TILES: int = 50

# 5 个瞬移位置(均匀分布在场地)
const TELEPORT_POSITIONS := [
	Vector2(10, 12),     # 左上
	Vector2(60, 12),     # 右上
	Vector2(10, 38),     # 左下
	Vector2(60, 38),     # 右下
	Vector2(35, 25),     # 中央
]	

# === 状态机 ===
enum BossState {
	IDLE,                    # 待机
	TELEPORTING,             # 瞬移中(过渡)
	CHANTING_MAGIC_BALL,     # 魔法球吟唱
	MAGIC_BALL_FLYING,       # 魔法球飞行
	CHARGING_LASER,          # 激光蓄力(跟随玩家)
	LASER_LOCKED,            # 激光锁定(方向固定)
	FIRING_LASER,            # 激光发射
	CHANTING_SHOCKWAVE,      # 震荡吟唱
	SHOCKWAVE_EXPANDING,     # 震荡扩散
	HIT_STUN,                # 受击硬直(2026-07-03 新增,黑幕解除后)
	DEAD,                    # 死亡
	# DARK_MODE 已删除(2026-07-03):黑幕只是视觉/伤害标记,不影响 Boss 行为
}

var current_state: BossState = BossState.IDLE
var state_elapsed: float = 0.0

# === HP ===
@export var max_hp: int = 3
var hp: int = max_hp

# === 瞬移 ===
@export var teleport_duration: float = 0.3       # 瞬移动画时长(秒)
@export var teleport_count_threshold: int = 2    # 每 2 次普通瞬移,第 3 次带黑幕
var teleport_count: int = 0                      # 当前累计瞬移次数

# === 魔法球 ===
@export var magic_ball_chant_duration: float = 1.5
@export var magic_ball_speed: float = 200.0      # 像素/秒
@export var magic_ball_lifetime: float = 3.0
@export var magic_ball_inertia_distance: float = 96.0  # 闪避后继续飞行距离(3 tile)
@export var magic_ball_cd: float = 5.0
var magic_ball_cd_timer: float = 0.0

# === 激光 ===
@export var laser_charge_duration: float = 2.0   # 蓄力时长(跟随玩家)
@export var laser_pre_fire_delay: float = 0.5    # 锁定后到发射延迟
@export var laser_fire_duration: float = 2.0     # 激光发射动作时长
@export var laser_width: float = TILE_SIZE       # 1 格宽
@export var laser_cd: float = 2.0
var laser_cd_timer: float = 0.0

# === 震荡 ===
@export var shockwave_chant_duration: float = 2.0
@export var shockwave_ring_width: float = TILE_SIZE  # 1 格宽
@export var shockwave_max_radius: float = 240.0       # 最大半径(约 7.5 tile,覆盖大部分场地)
@export var shockwave_expand_speed: float = 200.0     # 像素/秒(环扩散速度)
@export var shockwave_lifetime: float = 10.0          # 震荡总生命期(2026-07-03 新增)
@export var shockwave_cd: float = 3.0
var shockwave_cd_timer: float = 0.0
var shockwave_start_time: float = 0.0                  # 震荡开始时间(2026-07-03 新增)

# === 黑幕 ===
@export var darkness_radius: float = 64.0        # 2 格半径
@export var darkness_damage: int = 1             # 黑幕中受攻击扣 1 点 HP
@export var hit_stun_duration: float = 1.5       # 受击硬直时长
var darkness_layer: CanvasLayer = null           # 黑幕 CanvasLayer
var darkness_modulate: CanvasModulate = null     # 全场调暗
var player_light: Light2D = null                 # 玩家身边光源
var is_in_dark_mode: bool = false                # 黑幕是否激活

# === 状态记录 ===
var laser_dir: Vector2 = Vector2.RIGHT           # 锁定后的激光方向
var shockwave_radius: float = 0.0                # 当前震荡环半径
var magic_ball_node: Node2D = null               # 当前飞行中的魔法球

# === 引用 ===
var player: Node2D = null
var arena_center: Vector2 = Vector2.ZERO         # 场地中心世界坐标

func _ready() -> void:
	add_to_group("boss")
	_load_config()  # 从 JSON 读取参数(覆盖 @export 默认值)
	hp = max_hp
	# 获取场地中心(从父节点的 ArenaCenter Marker2D)
	var arena_marker: Node = get_parent().get_node_or_null("ArenaCenter")
	if arena_marker:
		arena_center = arena_marker.position
	else:
		arena_center = position
	print("[Boss] arena_center = %s" % arena_center)
	print("[Boss] 配置加载完成 max_hp=%d teleport_threshold=%d" % [max_hp, teleport_count_threshold])

# === 配表加载(从 JSON 读参数,覆盖 @export 默认值) ===
func _load_config() -> void:
	var config_path: String = "res://data/boss_mage.json"
	if not FileAccess.file_exists(config_path):
		print("[Boss] 配置文件不存在,使用默认值")
		return
	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		print("[Boss] 配置打开失败")
		return
	var json: JSON = JSON.new()
	if json.parse(file.get_as_text()) != OK:
		print("[Boss] 配置解析失败: ", json.get_error_message())
		return
	var data: Dictionary = json.data
	# Boss
	if data.has("boss"):
		var b: Dictionary = data["boss"]
		if b.has("max_hp"): max_hp = int(b["max_hp"])
		if b.has("teleport_duration"): teleport_duration = float(b["teleport_duration"])
		if b.has("teleport_count_threshold"): teleport_count_threshold = int(b["teleport_count_threshold"])
		if b.has("hit_stun_duration"): hit_stun_duration = float(b["hit_stun_duration"])
	# 魔法球
	if data.has("magic_ball"):
		var m: Dictionary = data["magic_ball"]
		if m.has("chant_duration"): magic_ball_chant_duration = float(m["chant_duration"])
		if m.has("speed"): magic_ball_speed = float(m["speed"])
		if m.has("lifetime"): magic_ball_lifetime = float(m["lifetime"])
		if m.has("inertia_distance"): magic_ball_inertia_distance = float(m["inertia_distance"])
		if m.has("cd"): magic_ball_cd = float(m["cd"])
	# 激光
	if data.has("laser"):
		var l: Dictionary = data["laser"]
		if l.has("charge_duration"): laser_charge_duration = float(l["charge_duration"])
		if l.has("pre_fire_delay"): laser_pre_fire_delay = float(l["pre_fire_delay"])
		if l.has("fire_duration"): laser_fire_duration = float(l["fire_duration"])
		if l.has("width"): laser_width = float(l["width"])
		if l.has("cd"): laser_cd = float(l["cd"])
		if l.has("hit_cooldown"): laser_hit_cooldown = float(l["hit_cooldown"])
	# 震荡
	if data.has("shockwave"):
		var s: Dictionary = data["shockwave"]
		if s.has("chant_duration"): shockwave_chant_duration = float(s["chant_duration"])
		if s.has("ring_width"): shockwave_ring_width = float(s["ring_width"])
		if s.has("max_radius"): shockwave_max_radius = float(s["max_radius"])
		if s.has("expand_speed"): shockwave_expand_speed = float(s["expand_speed"])
		if s.has("lifetime"): shockwave_lifetime = float(s["lifetime"])
		if s.has("cd"): shockwave_cd = float(s["cd"])
		if s.has("hit_cooldown"): shockwave_hit_cooldown = float(s["hit_cooldown"])
	# 黑幕
	if data.has("darkness"):
		var d: Dictionary = data["darkness"]
		if d.has("radius"): darkness_radius = float(d["radius"])
	print("[Boss] 配置加载完成")

func _physics_process(delta: float) -> void:
	if current_state == BossState.DEAD:
		return
	# CD 倒计时
	if magic_ball_cd_timer > 0.0:
		magic_ball_cd_timer -= delta
	if laser_cd_timer > 0.0:
		laser_cd_timer -= delta
	if shockwave_cd_timer > 0.0:
		shockwave_cd_timer -= delta
	# 获取玩家引用
	if not player:
		player = get_tree().get_first_node_in_group("player")
	# 状态机
	state_elapsed += delta
	match current_state:
		BossState.IDLE:
			_state_idle(delta)
		BossState.TELEPORTING:
			_state_teleporting(delta)
		BossState.CHANTING_MAGIC_BALL:
			_state_chanting_magic_ball(delta)
		BossState.MAGIC_BALL_FLYING:
			_state_magic_ball_flying(delta)
		BossState.CHARGING_LASER:
			_state_charging_laser(delta)
		BossState.LASER_LOCKED:
			_state_laser_locked(delta)
		BossState.FIRING_LASER:
			_state_firing_laser(delta)
		BossState.CHANTING_SHOCKWAVE:
			_state_chanting_shockwave(delta)
		BossState.SHOCKWAVE_EXPANDING:
			_state_shockwave_expanding(delta)
		BossState.HIT_STUN:
			_state_hit_stun(delta)
	queue_redraw()

# === 状态:待机 ===
func _state_idle(_delta: float) -> void:
	if not player:
		return
	var dist := position.distance_to(player.position) / TILE_SIZE  # 单位:格
	# 根据距离选下一个技能
	if dist > 10.0 and magic_ball_cd_timer <= 0.0:
		_start_chant_magic_ball()
	elif dist <= 5.0 and laser_cd_timer <= 0.0:
		_start_charge_laser()
	elif shockwave_cd_timer <= 0.0:
		_start_chant_shockwave()

# === 瞬移(被动触发) ===
func _teleport() -> void:
	teleport_count += 1
	# 黑幕中的瞬移 → 不瞬移,只受 1 伤
	if is_in_dark_mode:
		return
	# 第 3 次瞬移(累计 2 次后)带黑幕
	if teleport_count >= teleport_count_threshold:
		_start_teleport_with_dark_mode()
		return
	# 普通瞬移
	current_state = BossState.TELEPORTING
	state_elapsed = 0.0

func _state_teleporting(_delta: float) -> void:
	if state_elapsed >= teleport_duration:
		# 5 选 1:过滤掉当前位置(2026-07-03 改为 4 选 1)
		# 把 TELEPORT_POSITIONS 转成世界坐标
		var arena_half: Vector2 = Vector2(ARENA_WIDTH_TILES, ARENA_HEIGHT_TILES) / 2.0
		var current_tile: Vector2 = ((position - arena_center) / TILE_SIZE + arena_half).snapped(Vector2.ONE)
		var available: Array[Vector2] = []
		for t in TELEPORT_POSITIONS:
			if (t - current_tile).length() > 0.5:
				available.append(t)
		if available.is_empty():
			# 兜底:全部可选
			available = TELEPORT_POSITIONS.duplicate()
		var new_pos_tile: Vector2 = available[randi() % available.size()]
		var new_pos_world: Vector2 = arena_center + (new_pos_tile - arena_half) * TILE_SIZE
		new_pos_world = new_pos_world.snapped(Vector2(TILE_SIZE, TILE_SIZE))
		position = new_pos_world
		print("[Boss] 瞬移到 %s (第 %d 次)" % [new_pos_tile, teleport_count])
		# 回到 IDLE
		current_state = BossState.IDLE
		state_elapsed = 0.0

func _start_teleport_with_dark_mode() -> void:
	# 瞬移到位置 + 黑幕激活(2026-07-03)
	current_state = BossState.TELEPORTING
	state_elapsed = 0.0
	is_in_dark_mode = true
	_spawn_darkness()  # 立即激活黑幕视觉
	print("[Boss] 瞬移 + 激活黑幕!")

# === 魔法球 ===
func _start_chant_magic_ball() -> void:
	current_state = BossState.CHANTING_MAGIC_BALL
	state_elapsed = 0.0

func _state_chanting_magic_ball(_delta: float) -> void:
	if state_elapsed >= magic_ball_chant_duration:
		_spawn_magic_ball()
		current_state = BossState.MAGIC_BALL_FLYING
		state_elapsed = 0.0

func _spawn_magic_ball() -> void:
	# 创建独立的魔法球脚本(可见 + 自动索敌 + 命中检测)
	var ball = MagicBall.new()
	ball.setup(magic_ball_lifetime, magic_ball_speed, magic_ball_inertia_distance)
	get_tree().current_scene.add_child(ball)
	ball.global_position = global_position
	magic_ball_node = ball
	magic_ball_cd_timer = magic_ball_cd
	print("[Boss] 魔法球释放")

func _state_magic_ball_flying(delta: float) -> void:
	# 等待魔法球消失(球自己管理生命周期)
	if not magic_ball_node or not is_instance_valid(magic_ball_node):
		magic_ball_node = null
		current_state = BossState.IDLE
		state_elapsed = 0.0
		print("[Boss] 魔法球消失,回到 IDLE")

# === 激光 ===
func _start_charge_laser() -> void:
	current_state = BossState.CHARGING_LASER
	state_elapsed = 0.0

func _state_charging_laser(_delta: float) -> void:
	# 蓄力期间持续朝向玩家
	if player:
		laser_dir = (player.position - position).normalized()
	if state_elapsed >= laser_charge_duration:
		# 锁定方向,进入预发射
		current_state = BossState.LASER_LOCKED
		state_elapsed = 0.0
		print("[Boss] 激光锁定方向 %s,%.1fs 后发射" % [laser_dir, laser_pre_fire_delay])

func _state_laser_locked(_delta: float) -> void:
	if state_elapsed >= laser_pre_fire_delay:
		current_state = BossState.FIRING_LASER
		state_elapsed = 0.0
		laser_cd_timer = laser_cd
		print("[Boss] 激光发射")

func _state_firing_laser(delta: float) -> void:
	# 激光:玩家在激光方向 1 格宽内 → 受伤
	if not player:
		if state_elapsed >= laser_fire_duration:
			current_state = BossState.IDLE
			state_elapsed = 0.0
			print("[Boss] 激光结束")
		return
	# 检测玩家是否在激光方向 ± 半宽内
	var to_player: Vector2 = player.position - position
	var projection_length: float = to_player.dot(laser_dir)
	if projection_length > 0:
		var projection_point: Vector2 = position + laser_dir * projection_length
		var dist_to_line: float = player.position.distance_to(projection_point)
		if dist_to_line < laser_width / 2.0 + 16.0:
			# 在激光范围内,每 0.3 秒才造成一次伤害
			if state_elapsed - laser_last_hit_time >= laser_hit_cooldown:
				if player.has_method("take_damage"):
					player.take_damage(1)
					laser_last_hit_time = state_elapsed
	if state_elapsed >= laser_fire_duration:
		current_state = BossState.IDLE
		state_elapsed = 0.0
		print("[Boss] 激光结束")

var laser_last_hit_time: float = 0.0
var laser_hit_cooldown: float = 0.3

# === 震荡 ===
func _start_chant_shockwave() -> void:
	current_state = BossState.CHANTING_SHOCKWAVE
	state_elapsed = 0.0

func _state_chanting_shockwave(_delta: float) -> void:
	if state_elapsed >= shockwave_chant_duration:
		shockwave_radius = 0.0
		shockwave_start_time = 0.0  # 在 IDLE 中累积
		current_state = BossState.SHOCKWAVE_EXPANDING
		state_elapsed = 0.0
		print("[Boss] 震荡扩散,生命周期 %.1fs" % shockwave_lifetime)

func _state_shockwave_expanding(delta: float) -> void:
	# 记录已用时间(用于生命期检测)
	shockwave_start_time += delta
	shockwave_radius += shockwave_expand_speed * delta
	# 检测玩家是否在环内 — 持续命中,每 shockwave_hit_cooldown 秒一次(2026-07-03)
	if player:
		var dist_to_boss: float = position.distance_to(player.position)
		var ring_inner: float = shockwave_radius - shockwave_ring_width
		var ring_outer: float = shockwave_radius + shockwave_ring_width
		var in_ring: bool = dist_to_boss >= ring_inner and dist_to_boss <= ring_outer
		if in_ring:
			# 上次命中已经过 cooldown 即可再次命中
			if shockwave_start_time - shockwave_last_hit_time >= shockwave_hit_cooldown:
				if player.has_method("take_damage"):
					player.take_damage(1)
					shockwave_last_hit_time = shockwave_start_time
					print("[Boss] 震荡命中玩家 (半径:%.1f)" % shockwave_radius)
	# 结束条件:达到最大半径 OR 生命期到了
	if shockwave_radius >= shockwave_max_radius or shockwave_start_time >= shockwave_lifetime:
		current_state = BossState.IDLE
		state_elapsed = 0.0
		shockwave_cd_timer = shockwave_cd
		print("[Boss] 震荡结束 (半径:%.1f,生命期:%.1fs)" % [shockwave_radius, shockwave_start_time])

var shockwave_last_hit_time: float = 0.0
var shockwave_hit_cooldown: float = 0.3

# === 黑幕 ===
# 2026-07-03 重构:用 CanvasModulate + Light2D
# - CanvasModulate 让全场变暗
# - 玩家身上 Light2D 加亮光源范围内
# - 自然结果:光源外所有实体变暗看不到,光源内正常显示

func _spawn_darkness() -> void:
	if darkness_layer:
		return
	# 找玩家
	if not player:
		player = get_tree().get_first_node_in_group("player")
	if not player:
		print("[Boss] 黑幕激活失败:找不到玩家")
		return
	# 创建 CanvasLayer(顶层),内含 CanvasModulate(全场调暗)
	darkness_layer = CanvasLayer.new()
	darkness_layer.layer = 100
	darkness_modulate = CanvasModulate.new()
	darkness_modulate.color = Color(0.05, 0.05, 0.1)  # 接近全黑(几乎看不到)
	darkness_layer.add_child(darkness_modulate)
	get_tree().current_scene.add_child(darkness_layer)
	# 在玩家身上挂 Light2D(光源)
	player_light = Light2D.new()
	player_light.texture = _create_light_texture(darkness_radius)
	player_light.texture_scale = 1.0
	player_light.color = Color(1, 0.95, 0.85)
	player_light.energy = 2.5
	player_light.range_item_cull_mask = 1  # 影响所有 CanvasItem(layer 1)
	player.add_child(player_light)
	print("[Boss] 黑幕激活(CanvasModulate + Light2D)")

func _create_light_texture(radius: float) -> ImageTexture:
	var size: int = 128
	var img: Image = Image.create(size, size, false, Image.FORMAT_RGBA)
	img.fill(Color(0, 0, 0, 0))
	var center: Vector2 = Vector2(size, size) / 2.0
	for y in size:
		for x in size:
			var d: float = Vector2(x, y).distance_to(center) / (size / 2.0)
			if d <= 1.0:
				# 中心亮,边缘渐弱
				var a: float = 1.0 - smoothstep(0.6, 1.0, d)
				img.set_pixel(x, y, Color(1, 1, 1, a))
	return ImageTexture.create_from_image(img)

func _despawn_darkness() -> void:
	if player_light and is_instance_valid(player_light):
		player_light.queue_free()
	player_light = null
	if darkness_layer and is_instance_valid(darkness_layer):
		darkness_layer.queue_free()
	darkness_layer = null
	darkness_modulate = null
	print("[Boss] 黑幕解除")

# === 战斗接口 ===
# 2026-07-03 重构:
# - 普通状态(非黑幕)受攻击:不扣 HP,只触发瞬移(瞬移免伤)
# - 黑幕中受攻击:扣 1 HP + 解除黑幕 + 进入 1.5s 受击硬直
# - 受击硬直中受攻击:无视(无敌)
# - HP <= 0:死亡
func take_damage(amount: int) -> void:
	if current_state == BossState.DEAD:
		return
	# 黑幕已解除但在受击硬直中 → 无敌
	if current_state == BossState.HIT_STUN:
		print("[Boss] 受击硬直中,无敌")
		return
	# 黑幕中受攻击:扣血 + 解除黑幕 + 受击硬直
	if is_in_dark_mode:
		hp -= amount
		print("[Boss] 黑幕破绽期受攻击 -%d HP,剩 %d / %d" % [amount, hp, max_hp])
		var hud: Node = get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("update_boss_hp"):
			hud.update_boss_hp(hp, max_hp)
		# 解除黑幕 + 进入受击硬直
		_exit_dark_mode_with_hit_stun()
		if hp <= 0:
			_die()
		return
	# 普通状态:不扣 HP,只触发瞬移(瞬移免伤)
	print("[Boss] 普通状态受攻击 → 瞬移免伤(HP 不变 %d / %d)" % [hp, max_hp])
	if hp > 0:
		_teleport()
	else:
		_die()

# 黑幕中受击后的处理:解除黑幕 + 进入 1.5s 受击硬直(2026-07-03)
func _exit_dark_mode_with_hit_stun() -> void:
	is_in_dark_mode = false
	teleport_count = 0  # 重置瞬移计数
	_despawn_darkness()
	# 通知玩家场景变亮
	var player_node: Node = get_tree().get_first_node_in_group("player")
	if player_node and player_node.has_method("on_darkness_removed"):
		player_node.on_darkness_removed()
	# 进入 1.5s 受击硬直
	current_state = BossState.HIT_STUN
	state_elapsed = 0.0
	print("[Boss] 解除黑幕,进入 %.1fs 受击硬直" % hit_stun_duration)

func _state_hit_stun(_delta: float) -> void:
	# 受击硬直:不行动,也不受伤(take_damage 中已拦截)
	if state_elapsed >= hit_stun_duration:
		# 2026-07-03:受击硬直结束 → 立刻触发一次瞬移
		_teleport()
		print("[Boss] 受击硬直结束,立即瞬移")

func _die() -> void:
	current_state = BossState.DEAD
	print("[Boss] 死亡")
	if is_in_dark_mode:
		is_in_dark_mode = false
		teleport_count = 0  # 重置瞬移计数
		_despawn_darkness()
		# 通知玩家场景变亮
		var player_node: Node = get_tree().get_first_node_in_group("player")
		if player_node and player_node.has_method("on_darkness_removed"):
			player_node.on_darkness_removed()

# === 辅助 ===
func set_arena_center(center: Vector2) -> void:
	arena_center = center

# === 绘制 ===
func _draw() -> void:
	# 身体
	var body_color := Color(0.5, 0.2, 0.8)  # 紫袍
	if current_state == BossState.DEAD:
		body_color = Color(0.3, 0.3, 0.3)
	var half := Vector2(24, 32) / 2  # 大致占位
	draw_rect(Rect2(-half.x, -half.y, 48, 64), body_color)
	# 巫师帽(简化:三角)
	var hat_color := Color(0.2, 0.1, 0.4)
	var hat_points := PackedVector2Array([
		Vector2(-16, -24),
		Vector2(16, -24),
		Vector2(0, -56)
	])
	draw_colored_polygon(hat_points, hat_color)

	# 状态可视化
	match current_state:
		BossState.CHANTING_MAGIC_BALL:
			# 吟唱光环
			draw_arc(Vector2.ZERO, 32, 0, TAU * state_elapsed / magic_ball_chant_duration, 32, Color(1, 0.5, 1, 0.6), 3.0)
		BossState.CHANTING_SHOCKWAVE:
			draw_arc(Vector2.ZERO, 36, 0, TAU * state_elapsed / shockwave_chant_duration, 32, Color(0.5, 1, 1, 0.6), 3.0)
		BossState.SHOCKWAVE_EXPANDING:
			# 扩散的环(中空圆,宽度 shockwave_ring_width)
			draw_arc(Vector2.ZERO, shockwave_radius, 0, TAU, 64, Color(0.5, 1, 1, 0.7), shockwave_ring_width)
		BossState.CHARGING_LASER:
			# 蓄力期间:瞄准线
			if state_elapsed / laser_charge_duration > 0.5:
				var alpha: float = (state_elapsed / laser_charge_duration - 0.5) * 2
				# 画瞄准线
				draw_line(Vector2.ZERO, laser_dir * 400, Color(1, 0, 0, alpha * 0.5), 2.0)
		BossState.LASER_LOCKED:
			# 锁定:亮红色瞄准线
			draw_line(Vector2.ZERO, laser_dir * 400, Color(1, 0.2, 0.2, 0.8), 3.0)
		BossState.FIRING_LASER:
			# 发射:红色激光 + 末端渐变
			var laser_end: Vector2 = laser_dir * 800
			# 主激光线
			draw_line(Vector2.ZERO, laser_end, Color(1, 0.2, 0.2, 0.9), laser_width)
			# 外层光晕
			draw_line(Vector2.ZERO, laser_end, Color(1, 0.5, 0.5, 0.5), laser_width * 1.8)
			# 内层亮线
			draw_line(Vector2.ZERO, laser_end, Color(1, 0.8, 0.8, 0.9), laser_width * 0.5)