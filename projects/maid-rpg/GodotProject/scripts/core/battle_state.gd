class_name BattleState
extends RefCounted
## 战斗容器 —— 行动条循环 + 回合推进(02-系统设计.md §1.5 10.5)
##
## **不 extends Node**,可脱离场景 headless 跑。
## 战斗流程骨架(10.5):
##   战斗开始
##     → 初始化(行动条归零 / buff 清空 / 韧性回满)
##     → 主循环(每 0.2s)
##         → 所有单位跑条
##         → 判定胜负        ← S10,还没接
##         → 满条单位行动(玩家优先)
##             → 选指令(攻击 / 技能 / 逃跑)  ← S4/S10,还没接
##             → 结算(六步顺序)              ← S4,还没接
##     → 战斗结束(胜/负/逃)                ← S10,还没接
##
## 现阶段(S3)只做到「谁在什么时候行动」,伤害管线与胜负判定还没接。

var config: CombatConfig
var units: Array[UnitState] = []

## 已推进的 tick 数
var tick_count: int = 0
## 已过去的战斗时间(秒)
var elapsed: float = 0.0
## 行动顺序记录(UnitState 数组)
var action_log: Array[UnitState] = []

func _init(cfg: CombatConfig) -> void:
	config = cfg

## 加入单位
func add_unit(unit: UnitState) -> void:
	units.append(unit)

## 战斗开始:初始化(行动条归零 / 韧性回满 / 破防状态清除)
func start() -> void:
	for u in units:
		u.action_gauge = 0.0
		u.tenacity_current = u.tenacity_max
		u.is_broken = false
		u.broken_turns_remaining = 0
	tick_count = 0
	elapsed = 0.0
	action_log.clear()

## 推进一个 tick。
##
## 顺序严格按 10.1:跑条 → 挑行动者 → 行动 → 清零。
## `action_resolver` 是行动回调(S4 接伤害管线时把结算塞进来);
## 现在不传就只记顺序,不结算伤害。
func step(action_resolver: Callable = Callable()) -> UnitState:
	ActionGauge.advance(units, config)
	tick_count += 1
	elapsed += config.tick_interval

	var actor := ActionGauge.pick_actor(units, config)
	if actor == null:
		return null

	if action_resolver.is_valid():
		action_resolver.call(actor)

	ActionGauge.consume(actor, config)
	action_log.append(actor)
	return actor

## 连续推进 N 个 tick,返回行动者列表
func run(max_ticks: int, action_resolver: Callable = Callable()) -> Array[UnitState]:
	var acted: Array[UnitState] = []
	for _i in range(max_ticks):
		var actor := step(action_resolver)
		if actor != null:
			acted.append(actor)
	return acted

## 存活单位
func alive_units() -> Array[UnitState]:
	var alive: Array[UnitState] = []
	for u in units:
		if u.is_alive():
			alive.append(u)
	return alive
