extends CharacterBody2D

# ============================================================
# 封印勇者 - 主角控制
# 2026-07-01 重写为 grid-based 移动:
# - 按一下方向键 → 移动一格(32px),吸附到网格
# - 长按方向键 → 持续逐格移动
# - 停止输入立即停止,无惯性
# - 移动中按 K 翻滚可以取消
# - 静止时才能做其他动作(攻击 / 举盾 / 弓)
# ============================================================

# === 尺寸常量 ===
const TILE_SIZE: int = 32
const PLAYER_SPRITE_SIZE: Vector2 = Vector2(32, 48)
const PLAYER_COLLISION_SIZE: Vector2 = Vector2(16, 16)

# === 玩家能力状态(开局齐全,boss 战消耗) ===
var abilities: Dictionary = {
	"sword": true,
	"shield": true,
	"bow": true,
	"charm": true,
}

# === 数值参数(@export,策划在编辑器调) ===
# 移动
@export var move_step_duration: float = 0.15   # 一格动画时间(秒)

# 翻滚
@export var dodge_step_count: int = 3          # 翻滚移动几格(2026-07-01 改为 3)
@export var dodge_invulnerable_start: float = 0.05
@export var dodge_invulnerable_end: float = 0.35

# 剑(4 段)
@export var attack_windup: float = 0.08         # 起手
@export var attack_swing: float = 0.10          # 挥砍
@export var attack_recover: float = 0.08        # 结束
@export var attack_sheath: float = 0.14         # 收剑
@export var attack_range: float = 48.0          # 攻击范围(像素)
@export var attack_angle: float = 90.0          # 攻击角度(度)
@export var charge_duration: float = 0.5        # 蓄力时长

# 盾
@export var parry_window: float = 0.2           # 弹反帧时长
@export var shield_damage_reduction: int = 2    # 盾牌减伤
@export var max_shield_stamina: int = 10        # 盾精力最大值(2026-07-03 新增)
@export var shield_regen_rate: float = 5.0      # 盾精力回复速率(点/秒,未受击时)
@export var break_recovery_duration: float = 2.0  # 破防僵直时长(秒,2026-07-03 新增)
@export var recovery_invincibility_duration: float = 0.5  # 受身无敌帧时长(2026-07-03 新增)
@export var shield_break_stamina_per_damage: float = 1.0  # 每点伤害消耗的精力(可按伤害类型调整)

# 弓
@export var arrow_speed: float = 600.0
@export var arrow_range: float = 480.0
@export var arrow_pickup_radius: float = 32.0

# HP
@export var max_hp: int = 5
var current_hp: int = 5

# === 8 方向朝向 ===
enum Facing { UP, UP_RIGHT, RIGHT, DOWN_RIGHT, DOWN, DOWN_LEFT, LEFT, UP_LEFT }
var facing: int = Facing.DOWN
var last_movement: Vector2 = Vector2.DOWN

# === Grid-based 移动状态 ===
var is_stepping: bool = false
var step_start_pos: Vector2
var step_target_pos: Vector2
var step_progress: float = 0.0
var step_has_input: bool = false  # 移动期间是否有方向键持续按下

# === 动作状态 ===
var is_dodging: bool = false
var is_attacking: bool = false
var is_charging: bool = false
var is_shielding: bool = false
var is_parrying: bool = false
var is_break: bool = false                    # 破防状态(2026-07-03)
var is_recovery_invincible: bool = false      # 受身无敌中(2026-07-03)
var dodge_elapsed: float = 0.0
var dodge_total_duration: float = 0.0
var dodge_direction: Vector2 = Vector2.DOWN   # 翻滚方向(独立于 last_movement)
var attack_timer: float = 0.0
var charge_timer: float = 0.0
var parry_timer: float = 0.0
var shield_stamina: int = 10                  # 当前盾精力(2026-07-03)
var break_elapsed: float = 0.0                # 破防已用时长(2026-07-03)
var recovery_invincibility_elapsed: float = 0.0  # 受身无敌剩余时长(2026-07-03)

# Boss 战相关
var is_in_darkness: bool = false

# 外部钩子
func on_darkness_removed() -> void:
	# 由 Boss 死亡时调用,清理玩家这边状态
	is_in_darkness = false
	print("[Player] 黑幕已解除")

# === 初始化 ===
func _ready() -> void:
	current_hp = max_hp
	shield_stamina = max_shield_stamina
	add_to_group("player")
	# 起始位置对齐到网格
	position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))
	_refresh_hud()
	print("[Player] _ready at position: ", position)

# === 物理处理 ===
func _physics_process(delta: float) -> void:
	# 破防中:不能做任何动作,只能等待倒计时
	if is_break:
		_update_combat_state(delta)
		queue_redraw()
		return
	# 翻滚中:高速移动 + 无敌
	if is_dodging:
		_update_dodge(delta)
		return

	# 格子移动中:不能做其他动作(除了翻滚取消)
	if is_stepping:
		_update_step(delta)
		# 移动中持续按方向键 → 标记(下一步开始时连续移动)
		step_has_input = _has_movement_input()
		# 移动中可以翻滚取消
		if Input.is_action_just_pressed("dodge"):
			_start_dodge()
			is_stepping = false
			step_has_input = false
			return
		return

	# === 静止状态:处理输入 ===
	# 1. 移动(格子移动)
	var input_dir := _read_movement_input()
	if input_dir.length() > 0.0:
		last_movement = input_dir.normalized()
		facing = _vector_to_facing(last_movement)
		step_has_input = _has_movement_input()
		_start_step()
		return

	# 2. 举盾(持续)
	is_shielding = Input.is_action_pressed("shield") and abilities.shield
	if is_shielding:
		parry_timer += delta
		is_parrying = parry_timer <= parry_window
	else:
		parry_timer = 0.0
		is_parrying = false

	# 3. 攻击 / 交互(共用 J)
	if Input.is_action_just_pressed("attack"):
		if _has_interactable_in_front():
			_do_interact()
		elif abilities.sword and not is_attacking:
			_start_attack()

	# 4. 翻滚
	if Input.is_action_just_pressed("dodge") and not is_attacking:
		_start_dodge()

	# 5. 弓
	if Input.is_action_just_pressed("bow") and abilities.bow and not is_attacking:
		_start_bow()

	# 6. 蓄力(剑 / 弓,长按 J / I)
	if Input.is_action_pressed("attack") and is_attacking and abilities.sword:
		charge_timer += delta
		if charge_timer >= charge_duration:
			is_charging = true
	elif Input.is_action_pressed("bow") and is_attacking and abilities.bow:
		charge_timer += delta
		if charge_timer >= charge_duration:
			is_charging = true
	else:
		charge_timer = 0.0

	# 7. 护身符
	if Input.is_action_just_pressed("use_charm"):
		use_charm()

	# 攻击计时 + 命中检测
	if is_attacking:
		attack_timer -= delta
		_check_attack_hit()
		if attack_timer <= 0.0:
			is_attacking = false
			is_charging = false
			charge_timer = 0.0

	# 战斗状态更新(破防倒计时 / 受身无敌 / 精力回复)
	_update_combat_state(delta)

	queue_redraw()

# === Grid-based 移动 ===
func _start_step() -> void:
	step_start_pos = position
	step_target_pos = position + last_movement * TILE_SIZE
	# 吸附到网格(防止漂移)
	step_target_pos = step_target_pos.snapped(Vector2(TILE_SIZE, TILE_SIZE))
	step_progress = 0.0
	is_stepping = true

func _update_step(delta: float) -> void:
	step_progress = min(step_progress + delta / move_step_duration, 1.0)
	position = step_start_pos.lerp(step_target_pos, step_progress)
	if step_progress >= 1.0:
		position = step_target_pos  # 强制对齐到网格
		is_stepping = false
		# 移动完成:如果方向键还按着,继续移动下一格
		if step_has_input:
			var input_dir := _read_movement_input()
			if input_dir.length() > 0.0:
				last_movement = input_dir.normalized()
				facing = _vector_to_facing(last_movement)
				step_has_input = _has_movement_input()
				_start_step()
	queue_redraw()

func _has_movement_input() -> bool:
	return Input.is_action_pressed("move_left") or \
		   Input.is_action_pressed("move_right") or \
		   Input.is_action_pressed("move_up") or \
		   Input.is_action_pressed("move_down")

# === 输入 / 朝向 ===
func _read_movement_input() -> Vector2:
	var v := Vector2.ZERO
	if Input.is_action_pressed("move_left"): v.x -= 1.0
	if Input.is_action_pressed("move_right"): v.x += 1.0
	if Input.is_action_pressed("move_up"): v.y -= 1.0
	if Input.is_action_pressed("move_down"): v.y += 1.0
	return v

func _vector_to_facing(v: Vector2) -> int:
	var angle := atan2(v.y, v.x)
	var deg := rad_to_deg(angle)
	if deg >= -22.5 and deg < 22.5: return Facing.RIGHT
	elif deg >= 22.5 and deg < 67.5: return Facing.DOWN_RIGHT
	elif deg >= 67.5 and deg < 112.5: return Facing.DOWN
	elif deg >= 112.5 and deg < 157.5: return Facing.DOWN_LEFT
	elif deg >= 157.5 or deg < -157.5: return Facing.LEFT
	elif deg >= -157.5 and deg < -112.5: return Facing.UP_LEFT
	elif deg >= -112.5 and deg < -67.5: return Facing.UP
	elif deg >= -67.5 and deg < -22.5: return Facing.UP_RIGHT
	return Facing.DOWN

func _get_facing_vector() -> Vector2:
	match facing:
		Facing.UP: return Vector2.UP
		Facing.UP_RIGHT: return Vector2(1, -1).normalized()
		Facing.RIGHT: return Vector2.RIGHT
		Facing.DOWN_RIGHT: return Vector2(1, 1).normalized()
		Facing.DOWN: return Vector2.DOWN
		Facing.DOWN_LEFT: return Vector2(-1, 1).normalized()
		Facing.LEFT: return Vector2.LEFT
		Facing.UP_LEFT: return Vector2(-1, -1).normalized()
	return Vector2.DOWN

func _get_facing_angle() -> float:
	match facing:
		Facing.UP: return -PI / 2
		Facing.UP_RIGHT: return -PI / 4
		Facing.RIGHT: return 0.0
		Facing.DOWN_RIGHT: return PI / 4
		Facing.DOWN: return PI / 2
		Facing.DOWN_LEFT: return 3 * PI / 4
		Facing.LEFT: return PI
		Facing.UP_LEFT: return -3 * PI / 4
	return 0.0

# === 动作函数 ===
func _start_attack() -> void:
	is_attacking = true
	attack_timer = attack_windup + attack_swing + attack_recover + attack_sheath
	charge_timer = 0.0
	is_charging = false
	attack_has_hit = false
	print("[Player] 剑挥砍! 4 段动作 总时长:%.2fs" % attack_timer)

# 攻击命中检测 — 在挥砍段(attack_swing)检测面前 90 度扇形范围
var attack_has_hit: bool = false  # 当前攻击是否已命中(防止多次命中)

func _check_attack_hit() -> void:
	if attack_has_hit:
		return
	var total: float = attack_windup + attack_swing + attack_recover + attack_sheath
	var elapsed: float = total - attack_timer
	# 仅在挥砍段检测
	if elapsed < attack_windup or elapsed >= attack_windup + attack_swing:
		return
	# 找 Boss
	var boss: Node = get_tree().get_first_node_in_group("boss")
	if not boss:
		return
	# 面前扇形检测(attack_range 半径, attack_angle 度)
	var to_boss: Vector2 = boss.position - position
	var dist: float = to_boss.length()
	if dist > attack_range:
		return
	var facing_v: Vector2 = _get_facing_vector()
	var angle_to_boss: float = abs(acos(to_boss.normalized().dot(facing_v)))
	var half_angle: float = deg_to_rad(attack_angle / 2.0)
	if angle_to_boss > half_angle:
		return
	# 命中!
	attack_has_hit = true
	if boss.has_method("take_damage"):
		boss.take_damage(1)
	print("[Player] 剑命中 Boss!")

func _start_dodge() -> void:
	is_dodging = true
	dodge_elapsed = 0.0
	dodge_total_duration = move_step_duration * dodge_step_count
	# 翻滚方向:优先用当前移动输入,否则用当前朝向
	var input_dir := _read_movement_input()
	if input_dir.length() > 0.0:
		dodge_direction = input_dir.normalized()
		print("[Player] 翻滚!方向=移动输入 %s,距离=%d 格" % [dodge_direction, dodge_step_count])
	else:
		dodge_direction = _get_facing_vector()
		print("[Player] 翻滚!方向=当前朝向 %s,距离=%d 格" % [dodge_direction, dodge_step_count])
	# 更新朝向和 last_movement(让动画用对的方向)
	facing = _vector_to_facing(dodge_direction)
	last_movement = dodge_direction
	# 立即吸附到网格(避免起点是中间状态)
	position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))

func _update_dodge(delta: float) -> void:
	# 翻滚:固定方向移动几格,带无敌帧
	dodge_elapsed += delta
	velocity = dodge_direction * (TILE_SIZE / move_step_duration)
	move_and_slide()
	queue_redraw()
	if dodge_elapsed >= dodge_total_duration:
		is_dodging = false
		position = position.snapped(Vector2(TILE_SIZE, TILE_SIZE))

func _start_bow() -> void:
	var facing_v := _get_facing_vector()
	print("[Player] 射箭! 朝向: %s, 速度: %s px/s, 射程: %s px" % [
		facing_v, arrow_speed, arrow_range
	])

func _has_interactable_in_front() -> bool:
	return false

func _do_interact() -> void:
	pass

# === 护身符(保留) ===
func use_charm() -> void:
	if not abilities.charm:
		return
	if not is_in_darkness:
		return
	var darkness: Node = get_tree().get_first_node_in_group("darkness")
	if darkness:
		darkness.queue_free()
	is_in_darkness = false
	abilities.charm = false
	_refresh_hud()

# === 伤害系统 ===
func take_damage(amount: int) -> void:
	# 1. 翻滚无敌(主动)
	if is_dodging:
		print("[Player] 翻滚无敌,免伤!")
		return
	# 2. 受身无敌(被动,0.5 秒内不会再次受伤)
	if is_recovery_invincible:
		print("[Player] 受身无敌,免伤!")
		return
	# 3. 弹反(强化盾牌)
	if is_parrying:
		print("[Player] 弹反!攻击被反弹!")
		return
	# 4. 破防中(已僵直,但仍然能受伤)
	# 跳过(让人继续攻击)
	# 5. 举盾 → 消耗精力
	if is_shielding:
		var stamina_cost: int = int(ceil(amount * shield_break_stamina_per_damage))
		shield_stamina -= stamina_cost
		print("[Player] 举盾消耗精力 %d,剩余 %d / %d" % [stamina_cost, shield_stamina, max_shield_stamina])
		# 精力耗尽 → 破防
		if shield_stamina <= 0:
			is_break = true
			break_elapsed = 0.0
			is_shielding = false
			is_parrying = false
			print("[Player] 破防!进入 2 秒僵直")
		var actual_damage: int = int(max(1, amount - shield_damage_reduction))
		current_hp -= actual_damage
		current_hp = max(0, current_hp)
		# 启动受身无敌(0.5 秒)
		is_recovery_invincible = true
		recovery_invincibility_elapsed = 0.0
		update_hud()
		if current_hp <= 0:
			die()
		return
	# 6. 正常受伤
	var actual_damage := amount
	current_hp -= actual_damage
	current_hp = max(0, current_hp)
	# 启动受身无敌
	is_recovery_invincible = true
	recovery_invincibility_elapsed = 0.0
	update_hud()
	print("[Player] 受伤 %d 点,剩 %d / %d" % [actual_damage, current_hp, max_hp])
	if current_hp <= 0:
		die()

# === 状态计时(在 _physics_process 调用) ===
func _update_combat_state(delta: float) -> void:
	# 1. 破防倒计时
	if is_break:
		break_elapsed += delta
		if break_elapsed >= break_recovery_duration:
			is_break = false
			break_elapsed = 0.0
			# 破防结束 → 回复全部精力
			shield_stamina = max_shield_stamina
			print("[Player] 破防恢复,精力回满")
	# 2. 受身无敌倒计时
	if is_recovery_invincible:
		recovery_invincibility_elapsed += delta
		if recovery_invincibility_elapsed >= recovery_invincibility_duration:
			is_recovery_invincible = false
			recovery_invincibility_elapsed = 0.0
	# 3. 盾精力回复(未受击且未破防时)
	if not is_shielding and not is_break and not is_recovery_invincible and shield_stamina < max_shield_stamina:
		shield_stamina = min(int(shield_stamina + shield_regen_rate * delta), max_shield_stamina)

func die() -> void:
	pass

# === HUD ===
func update_hud() -> void:
	var hud: CanvasLayer = get_tree().get_first_node_in_group("hud") as CanvasLayer
	if hud and hud.has_method("update_hp"):
		hud.update_hp(current_hp)

func _refresh_hud() -> void:
	var hud: CanvasLayer = get_tree().get_first_node_in_group("hud") as CanvasLayer
	if hud and hud.has_method("update_abilities"):
		hud.update_abilities(abilities)

# === 绘制 ===
func _draw() -> void:
	# 旋转 sprite 根据 facing
	var rotation := _get_facing_angle()
	draw_set_transform(Vector2.ZERO, rotation, Vector2.ONE)

	# 玩家身体
	var body_color := Color(0.3, 0.7, 1.0)
	if is_dodging:
		body_color = Color(0.6, 0.9, 1.0, 0.7)
	elif is_shielding:
		body_color = Color(0.2, 0.5, 0.9)
	elif is_break:
		body_color = Color(0.8, 0.2, 0.2)  # 破防时红色
	elif is_recovery_invincible:
		body_color = Color(1.0, 1.0, 0.5)  # 受身无敌时黄色
	var half := PLAYER_SPRITE_SIZE / 2
	draw_rect(Rect2(-half.x, -half.y, PLAYER_SPRITE_SIZE.x, PLAYER_SPRITE_SIZE.y), body_color)

	# 朝向指示
	var arrow_color := Color(1, 1, 1)
	draw_line(Vector2(16, 0), Vector2(28, 0), arrow_color, 3.0)
	draw_line(Vector2(28, 0), Vector2(22, -4), arrow_color, 3.0)
	draw_line(Vector2(28, 0), Vector2(22, 4), arrow_color, 3.0)

	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

	# 举盾
	if is_shielding:
		var shield_color := Color(0.4, 0.6, 1.0, 0.7)
		if is_parrying:
			shield_color = Color(1.0, 1.0, 0.0, 0.9)
		var facing_v := _get_facing_vector()
		var shield_pos := facing_v * 18.0
		draw_rect(Rect2(shield_pos.x - 4, shield_pos.y - 16, 8, 32), shield_color)

	# 蓄力
	if is_charging:
		var charge_color := Color(1.0, 0.5, 0.0, 0.8)
		var facing_v := _get_facing_vector()
		draw_circle(facing_v * 32.0, 8.0, charge_color)