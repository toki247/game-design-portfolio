class_name UnitState
extends RefCounted
## 战斗单位运行时状态(纯逻辑层 —— **不 extends Node**,可 headless 跑)
##
## 字段对应 02-系统设计.md §1.6 的核心对象 + §1.5 10.4 的 Enemy 结构。
## 数值来源是 CharacterData / EnemyData,这里只放「战斗中会变」的状态。

## 唯一标识
var id: StringName = &""
## 显示名
var display_name: String = ""
## 是否玩家方单位(并列满条时玩家先动)
var is_player: bool = false
var level: int = 1

@export_group("5 属性")
## 体格
var physique: float = 0.0
## 力量
var strength: float = 0.0
## 速度
var speed: float = 0.0
## 技巧
var agility: float = 0.0
## 幸运
var luck: float = 0.0

@export_group("行动速度")
## 行动速度 —— **只喂行动条**,与上面的【速度】完全剥离(已定 15)
## 跑条速度 = 行动速度 × action_gauge_speed_mult
var action_speed: float = 0.0

@export_group("装备 / 外部加成")
## 武器攻击(攻击力 = 力量 + 武器攻击 + buff)
var weapon_attack: float = 0.0
## buff 提供的攻击力加成
var attack_buff: float = 0.0

@export_group("生命")
var max_hp: float = 0.0
var hp: float = 0.0

@export_group("行动条")
## 当前行动条(条)—— 满值见 config.action_gauge_max
var action_gauge: float = 0.0

@export_group("韧性(§1.6 Tenacity)")
var tenacity_current: float = 0.0
## 每个单位不同,逐个配置(05 §4 #5)
var tenacity_max: float = 0.0
## 是否处于破防状态(破防那 1 回合承伤 +50%)
var is_broken: bool = false
## 破防剩余回合
var broken_turns_remaining: int = 0

@export_group("护盾(§1.6 Shield)")
var shield_current: float = 0.0
## 上限 = 当前最大生命值(双刀减半上限时跟着变)
var shield_max: float = 0.0

@export_group("派生值")
## StatsCalc.derive() 的结果缓存
var derived: DerivedStats

## 是否还活着
func is_alive() -> bool:
	return hp > 0.0

## 行动条进度(0~1)
func gauge_ratio(config: CombatConfig) -> float:
	if config == null or config.action_gauge_max <= 0:
		return 0.0
	return clampf(action_gauge / float(config.action_gauge_max), 0.0, 1.0)
