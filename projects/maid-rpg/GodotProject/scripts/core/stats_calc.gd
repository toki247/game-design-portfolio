class_name StatsCalc
extends RefCounted
## 属性公式层(02-系统设计.md §1.9 / 05-数值与配置.md §1.1)
##
## 纯静态工具,**不 extends Node**,可 headless 跑几千次做数值调试。
##
## 公式表:
##   HP         = 体格 × 2
##   攻击力     = 力量 + 武器攻击 + buff
##   防御       = 体格
##   行动条速度 = 速度 × 2
##   闪避率     = (幸运 + 速度) / 2(向上取整)
##   暴击率     = (技巧 + 幸运) / 2
##   暴击伤害   = × 1.5
##   命中率     = 技巧 − 对方闪避
##   冲击力     = 招式伤害 × 招式冲击力倍率
##   屏障最大值 = 防御 × 5
##   减伤率     = 有效防御 / (有效防御 + K)
##   招架率     = 闪避率 + 减伤率

## 由 5 属性算出全部派生值
static func derive(unit: UnitState, config: CombatConfig) -> DerivedStats:
	var s := DerivedStats.new()
	if unit == null or config == null:
		return s

	s.max_hp = unit.physique * 2.0
	s.attack = unit.strength + unit.weapon_attack + unit.attack_buff
	s.defense = unit.physique
	s.action_gauge_speed = unit.speed * config.action_gauge_speed_mult

	# 闪避率 = (幸运 + 速度) / 2,向上取整
	s.evasion_pct = float(ceili((unit.luck + unit.speed) / 2.0))
	# 暴击率 = (技巧 + 幸运) / 2
	s.crit_pct = (unit.agility + unit.luck) / 2.0
	# 暴击伤害倍率
	s.crit_damage_mult = config.crit_damage_mult
	# 屏障最大值 = 防御 × 倍率
	s.barrier_max = s.defense * config.barrier_defense_mult
	# 减伤率 + 招架率
	s.damage_reduction_pct = damage_reduction_pct(s.defense, config.k_damage_reduction)
	s.parry_pct = s.evasion_pct + s.damage_reduction_pct
	return s

## 减伤率(百分数点)= 有效防御 / (有效防御 + K) × 100
##
## 防御穿透的用法(已定 13):不是独立乘区,是**减法扣防御值**再进这个公式
##   有效防御 = max(0, 目标防御 - 穿透值)
static func damage_reduction_pct(effective_defense: float, k: float) -> float:
	if k <= 0.0:
		return 0.0
	var d := maxf(effective_defense, 0.0)
	return d / (d + k) * 100.0

## 有效防御 = max(0, 防御 - 穿透值)
static func effective_defense(defense: float, pierce: float) -> float:
	return maxf(defense - pierce, 0.0)

## 命中率(百分数点)= 技巧 + 技能命中加成 − 对方闪避率
static func hit_pct(attacker: UnitState, target_stats: DerivedStats, skill_bonus: float = 0.0) -> float:
	if attacker == null or target_stats == null:
		return 0.0
	return attacker.agility + skill_bonus - target_stats.evasion_pct

## 冲击力 = 招式伤害 × 招式冲击力倍率
static func impact(damage: float, impact_multiplier: float) -> float:
	return damage * impact_multiplier

## 把单位刷新到派生值(顺带把 max_hp 写回单位)
static func refresh(unit: UnitState, config: CombatConfig) -> DerivedStats:
	var s := derive(unit, config)
	unit.derived = s
	unit.max_hp = s.max_hp
	if unit.hp > unit.max_hp:
		unit.hp = unit.max_hp
	return s
