extends SceneTree
## 核心层 headless 自测
##
## 跑法:
##   godot --headless --path <GodotProject> --script res://tests/run_tests.gd
##
## 覆盖:
##   S1 配置能加载(.tres 数值正确)
##   S2 属性公式对齐 02-系统设计.md §1.9
##   S3 行动条:跑条速度 / 溢出清零 / 并列玩家先动 / 速度 0 不卡死

const CONFIG_PATH := "res://config/combat_config.tres"

var _passed := 0
var _failed := 0

func _initialize() -> void:
	print("=== Maid RPG 核心层自测(S1 / S2 / S3) ===")
	_test_config_load()
	_test_stats_formula()
	_test_defense_pierce()
	_test_gauge_single_unit()
	_test_gauge_two_units()
	_test_tie_player_first()
	_test_overflow_clear()
	_test_zero_speed_not_stuck()
	print("=== 通过 %d,失败 %d ===" % [_passed, _failed])
	quit(0 if _failed == 0 else 1)

# --- S1 配置 ---

func _test_config_load() -> void:
	print("[S1] 配置加载")
	var cfg := load(CONFIG_PATH) as CombatConfig
	_check("配置可加载", cfg != null, true)
	if cfg == null:
		return
	_check("action_gauge_max", cfg.action_gauge_max, 1000)
	_check("action_gauge_speed_mult", cfg.action_gauge_speed_mult, 2.0)
	_check("tick_interval", cfg.tick_interval, 0.2)
	_check("k_damage_reduction", cfg.k_damage_reduction, 100.0)
	_check("k_escape", cfg.k_escape, 100.0)
	_check("broken_damage_mult", cfg.broken_damage_mult, 1.5)
	_check("strong_mode_max_turns", cfg.strong_mode_max_turns, 5)

# --- S2 属性公式 ---

func _test_stats_formula() -> void:
	print("[S2] 属性公式(02-系统设计.md §1.9)")
	var cfg := load(CONFIG_PATH) as CombatConfig
	var u := _make_unit(true, 10.0)
	u.physique = 50.0
	u.strength = 20.0
	u.agility = 10.0
	u.luck = 10.0
	u.weapon_attack = 5.0
	var s := StatsCalc.derive(u, cfg)
	_check("HP = 体格 × 2", s.max_hp, 100.0)
	_check("攻击力 = 力量 + 武器攻击", s.attack, 25.0)
	_check("防御 = 体格", s.defense, 50.0)
	_check("行动条速度 = 速度 × 2", s.action_gauge_speed, 20.0)
	_check("闪避率 = ceil((幸运+速度)/2)", s.evasion_pct, 10.0)
	_check("暴击率 = (技巧+幸运)/2", s.crit_pct, 10.0)
	_check("减伤率 = 防御/(防御+K)", s.damage_reduction_pct, 50.0 / 150.0 * 100.0)
	_check("招架率 = 闪避率 + 减伤率", s.parry_pct, 10.0 + 50.0 / 150.0 * 100.0)
	_check("屏障最大值 = 防御 × 5", s.barrier_max, 250.0)
	_check("暴击伤害倍率", s.crit_damage_mult, 1.5)

func _test_defense_pierce() -> void:
	print("[S2] 防御穿透 = 减法扣有效防御(已定 13)")
	_check("有效防御 = max(0, 50-20)", StatsCalc.effective_defense(50.0, 20.0), 30.0)
	_check("穿透大于防御时兜底 0", StatsCalc.effective_defense(50.0, 80.0), 0.0)
	_check("减伤率(有效防御 30)", StatsCalc.damage_reduction_pct(30.0, 100.0), 30.0 / 130.0 * 100.0)

# --- S3 行动条 ---

func _test_gauge_single_unit() -> void:
	print("[S3] 跑条速度基准(速度 100 ≈ 5 秒,速度 50 ≈ 10 秒)")
	var cfg := load(CONFIG_PATH) as CombatConfig

	# 速度 100 → 每 tick +40 → 25 tick = 5.0 秒
	var fast := _make_unit(true, 100.0)
	var bs1 := BattleState.new(cfg)
	bs1.add_unit(fast)
	bs1.start()
	var first_action_tick := 0
	for _i in range(200):
		if bs1.step() != null:
			first_action_tick = bs1.tick_count
			break
	_check("速度 100 第一次行动在第 25 个 tick", first_action_tick, 25)
	_check("速度 100 第一次行动用时 5.0 秒", first_action_tick * cfg.tick_interval, 5.0)

	# 速度 50 → 每 tick +20 → 50 tick = 10.0 秒
	var slow := _make_unit(true, 50.0)
	var bs2 := BattleState.new(cfg)
	bs2.add_unit(slow)
	bs2.start()
	first_action_tick = 0
	for _i in range(200):
		if bs2.step() != null:
			first_action_tick = bs2.tick_count
			break
	_check("速度 50 第一次行动在第 50 个 tick", first_action_tick, 50)
	_check("速度 50 第一次行动用时 10.0 秒", first_action_tick * cfg.tick_interval, 10.0)

func _test_gauge_two_units() -> void:
	print("[S3] 不同速度 → 行动顺序")
	var cfg := load(CONFIG_PATH) as CombatConfig
	var player := _make_unit(true, 100.0)
	var enemy := _make_unit(false, 80.0)
	var bs := BattleState.new(cfg)
	bs.add_unit(player)
	bs.add_unit(enemy)
	bs.start()
	var events: Array = []
	for _i in range(60):
		var actor := bs.step()
		if actor != null:
			events.append([bs.tick_count, String(actor.id)])
	# 玩家 40/tick → tick 25 满条;敌人 32/tick → tick 32 满条;玩家归零后 tick 50 再满
	_check("60 tick 内行动事件数", events.size(), 3)
	if events.size() == 3:
		_check("事件 1 = 玩家 @tick 25", events[0], [25, "player"])
		_check("事件 2 = 敌人 @tick 32", events[1], [32, "enemy"])
		_check("事件 3 = 玩家 @tick 50", events[2], [50, "player"])

func _test_tie_player_first() -> void:
	print("[S3] 并列满条 → 玩家先动")
	var cfg := load(CONFIG_PATH) as CombatConfig
	var player := _make_unit(true, 100.0)
	var enemy := _make_unit(false, 100.0)
	var bs := BattleState.new(cfg)
	bs.add_unit(player)
	bs.add_unit(enemy)
	bs.start()
	var events: Array = []
	for _i in range(60):
		var actor := bs.step()
		if actor != null:
			events.append([bs.tick_count, String(actor.id)])
	_check("事件数", events.size(), 4)
	if events.size() == 4:
		_check("并列时玩家先动 @tick 25", events[0], [25, "player"])
		_check("敌人下一个 tick 行动", events[1], [26, "enemy"])
		_check("玩家第二轮 @tick 50", events[2], [50, "player"])
		_check("敌人第二轮 @tick 51", events[3], [51, "enemy"])

func _test_overflow_clear() -> void:
	print("[S3] 行动后清零(溢出清零,不保留溢出)")
	var cfg := load(CONFIG_PATH) as CombatConfig
	var u := _make_unit(true, 100.0)
	var bs := BattleState.new(cfg)
	bs.add_unit(u)
	bs.start()
	# 前 24 tick 没满条:40 × 24 = 960
	for _i in range(24):
		bs.step()
	_check("24 tick 后行动条 960(未满条)", u.action_gauge, 960.0)
	_check("前 24 tick 无行动", bs.action_log.size(), 0)
	# 第 25 tick 满条 → 行动 → 清零
	var actor := bs.step()
	_check("第 25 tick 有行动者", actor != null, true)
	_check("行动后行动条归零", u.action_gauge, 0.0)
	# 溢出清零 = 重新跑满一整条,不是接着 960 跑
	for _i in range(24):
		bs.step()
	_check("归零后 24 tick 行动条 960(没继承溢出)", u.action_gauge, 960.0)
	bs.step()
	_check("第 25 tick 再次行动并归零", u.action_gauge, 0.0)
	_check("累计行动 2 次", bs.action_log.size(), 2)

func _test_zero_speed_not_stuck() -> void:
	print("[S3] 速度 0 不卡死(跑速下限)")
	var cfg := load(CONFIG_PATH) as CombatConfig
	var u := _make_unit(false, 0.0)
	_check("跑条速度 = 下限 1 条/秒", ActionGauge.gauge_speed(u, cfg), 1.0)
	var bs := BattleState.new(cfg)
	bs.add_unit(u)
	bs.start()
	for _i in range(10):
		bs.step()
	_check("10 tick 后行动条 = 2.0(在动,没卡死)", u.action_gauge, 2.0)

# --- 工具 ---

func _make_unit(is_player: bool, spd: float) -> UnitState:
	var u := UnitState.new()
	u.id = &"player" if is_player else &"enemy"
	u.display_name = "玩家" if is_player else "敌人"
	u.is_player = is_player
	u.physique = 50.0
	u.strength = 20.0
	u.speed = spd
	u.agility = 10.0
	u.luck = 10.0
	u.hp = 100.0
	u.max_hp = 100.0
	return u

func _check(label: String, actual: Variant, expected: Variant) -> void:
	if _approx(actual, expected):
		_passed += 1
		print("  [OK]   %s = %s" % [label, str(actual)])
	else:
		_failed += 1
		printerr("  [FAIL] %s: 期望 %s,实际 %s" % [label, str(expected), str(actual)])

func _approx(a: Variant, b: Variant) -> bool:
	if a is float or b is float:
		var fb := float(b)
		return absf(float(a) - fb) <= maxf(0.0001, absf(fb) * 0.0001)
	return a == b
