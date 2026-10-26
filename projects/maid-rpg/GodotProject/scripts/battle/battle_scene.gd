extends Node2D
## 战斗场景驱动 —— 当前阶段(S1 工程地基 + S2 属性公式 + S3 行动条)的演示。
##
## 打印三件事:
##   1. config 里的数值(S1 完成标准:改 .tres 能看到输出变化)
##   2. 两个假单位的派生值(S2)
##   3. 行动条推进与行动顺序(S3 完成标准:不同速度 → 看得出谁先动)
##
## 伤害管线(S4)/ 胜负判定(S10)/ UI(S8)还没接 —— 这里只演示到「谁在什么时候行动」。

## 演示时长(tick 数)
const DEMO_TICKS := 60
## 行动条宽度(ASCII 块,避免 Windows 控制台 GBK 码页乱码)
const BAR_WIDTH := 20

func _ready() -> void:
	var config: CombatConfig = GameData.combat_config
	if config == null:
		push_error("配置没加载成功 —— GameData.combat_config 为空")
		return

	_print_config(config)

	var battle := _build_demo_battle(config)
	_print_units(battle)
	_run_battle(battle, config)

# --- 组装演示用的两个假单位(规格书 §3.1 的例子:玩家速度 100 / 敌人速度 80)---
func _build_demo_battle(config: CombatConfig) -> BattleState:
	var player := UnitState.new()
	player.id = &"player"
	player.display_name = "玩家"
	player.is_player = true
	player.physique = 50.0
	player.strength = 20.0
	player.speed = 100.0
	player.agility = 10.0
	player.luck = 10.0

	var enemy := UnitState.new()
	enemy.id = &"enemy"
	enemy.display_name = "敌人"
	enemy.is_player = false
	enemy.physique = 50.0
	enemy.strength = 20.0
	enemy.speed = 80.0
	enemy.agility = 10.0
	enemy.luck = 10.0

	for u in [player, enemy]:
		StatsCalc.refresh(u, config)
		u.hp = u.max_hp

	var battle := BattleState.new(config)
	battle.add_unit(player)
	battle.add_unit(enemy)
	battle.start()
	return battle

func _print_config(config: CombatConfig) -> void:
	print("=== 战斗配置(来自 config/combat_config.tres) ===")
	print("  行动条满值       %d" % config.action_gauge_max)
	print("  行动条速度倍率   %.1f(条/秒 = 速度 × 此值)" % config.action_gauge_speed_mult)
	print("  tick 间隔        %.2f 秒" % config.tick_interval)
	print("  跑条速度下限     %.1f 条/秒" % config.action_gauge_min_speed)
	print("  减伤 K           %.0f" % config.k_damage_reduction)
	print("  逃跑 K           %.0f" % config.k_escape)
	print("  破防承伤倍率     %.2f" % config.broken_damage_mult)
	print("  暴击伤害倍率     %.2f" % config.crit_damage_mult)
	print("")

func _print_units(battle: BattleState) -> void:
	print("=== 派生值(S2 属性公式层) ===")
	for u in battle.units:
		var d := u.derived
		print("  %s  HP %d/%d  攻击 %.0f  防御 %.0f" % [
			u.display_name, int(u.hp), int(u.max_hp), d.attack, d.defense])
		print("      行动条速度 %.0f 条/秒  闪避 %.0f%%  暴击 %.0f%%  减伤 %.1f%%  招架 %.1f%%" % [
			d.action_gauge_speed, d.evasion_pct, d.crit_pct,
			d.damage_reduction_pct, d.parry_pct])
	print("")

func _run_battle(battle: BattleState, config: CombatConfig) -> void:
	print("=== 行动条推进(S3,每 %.1f 秒一次 tick) ===" % config.tick_interval)
	for _i in range(DEMO_TICKS):
		var actor := battle.step()
		if actor == null:
			continue
		print("--- tick %d(%.1f 秒)--- %s 行动" % [
			battle.tick_count, battle.elapsed, actor.display_name])
		for u in battle.units:
			print("  %s(速度%d) HP %d/%d  行动条 [%s] %3d%%" % [
				u.display_name, int(u.speed), int(u.hp), int(u.max_hp),
				_bar(u.gauge_ratio(config)), int(u.gauge_ratio(config) * 100.0)])

	print("")
	print("=== 行动顺序(%d 个 tick 内) ===" % DEMO_TICKS)
	var idx := 0
	for u in battle.action_log:
		idx += 1
		print("  %d. %s" % [idx, u.display_name])

# ASCII 进度条
func _bar(ratio: float) -> String:
	var filled := int(round(clampf(ratio, 0.0, 1.0) * BAR_WIDTH))
	return "#".repeat(filled) + "-".repeat(maxi(BAR_WIDTH - filled, 0))
