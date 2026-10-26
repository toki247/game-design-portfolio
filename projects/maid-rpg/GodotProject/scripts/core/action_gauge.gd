class_name ActionGauge
extends RefCounted
## 行动条(02-系统设计.md §1.5 10.1 / 05-数值与配置.md §1.3)
##
## 规则:
##   满值     = 1000
##   跑条速度 = 行动速度 × 2(条/秒)
##   计算频率 = 每 0.2 秒一次 tick
##   并列     = 同时满条时玩家先动
##   溢出     = 行动后清零(不保留溢出)
##
## 推进逻辑:
##   每 0.2s:
##     所有单位 action_gauge += (行动速度 × 2) × 0.2
##     找出所有 action_gauge >= 1000 的单位
##     若有多个 → 玩家优先 → 该单位行动 → action_gauge = 0
##
## ⚠️ 实现层的三个坑(规格书 §3.1):
##   1. 溢出清零后死循环 —— 行动单位直接归 0,其它满条单位保留,下个 tick 依次行动,不会饿死
##   2. tick 精度 —— 用固定步长累加,不用 delta 直接乘
##   3. 行动速度 0 卡死 —— 跑条速度设下限(见 config.action_gauge_min_speed)

## 推进所有存活单位的行动条(固定步长 = config.tick_interval)
static func advance(units: Array, config: CombatConfig) -> void:
	var step := config.tick_interval
	for u in units:
		if not u.is_alive():
			continue
		u.action_gauge += gauge_speed(u, config) * step

## 跑条速度(条/秒),带下限 —— 行动速度被减到 0 时也不会永远不动
static func gauge_speed(unit: UnitState, config: CombatConfig) -> float:
	return maxf(unit.action_speed * config.action_gauge_speed_mult, config.action_gauge_min_speed)

## 挑出本 tick 的行动者,没有则返回 null
##
## 优先级:
##   1. 满条(>= action_gauge_max)且存活
##   2. 玩家优先(并列时玩家先动)
##   3. 行动条值高者优先(溢出清零后等得越久积累越多)
##   4. 仍相同 → 按 id 排序,保证结果确定
static func pick_actor(units: Array, config: CombatConfig) -> UnitState:
	var ready: Array = []
	for u in units:
		if u.is_alive() and u.action_gauge >= float(config.action_gauge_max):
			ready.append(u)
	if ready.is_empty():
		return null

	for u in ready:
		if u.is_player:
			return u

	ready.sort_custom(_gauge_desc)
	return ready[0]

## 行动后清零(溢出清零,不保留溢出)
static func consume(unit: UnitState, _config: CombatConfig) -> void:
	unit.action_gauge = 0.0

## 排序回调:行动条值降序,相同时按 id 升序
static func _gauge_desc(a: UnitState, b: UnitState) -> bool:
	if not is_equal_approx(a.action_gauge, b.action_gauge):
		return a.action_gauge > b.action_gauge
	return String(a.id) < String(b.id)
