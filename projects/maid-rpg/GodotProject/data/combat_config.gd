class_name CombatConfig
extends Resource
## 全局战斗数值配置 —— 唯一数值入口(05-数值与配置.md §2)。
##
## 铁律(05 §0):
##   1. 所有数值走配置 —— 逻辑代码不写死数字
##   2. 规则是代码,数值是配置 —— 规则本身(5 回合上限 / 六步结算顺序 / 溢出清零)写死在代码里,不放这里
##
## 改平衡只动 `config/combat_config.tres`,不动代码。

@export_group("行动条")
## 行动条满值(条)
@export var action_gauge_max: int = 1000
## 行动条速度 = 速度属性 × 此值(条/秒)
@export var action_gauge_speed_mult: float = 2.0
## tick 间隔(秒)—— 行动条每 0.2s 结算一次
@export var tick_interval: float = 0.2
## 跑条速度下限(条/秒)—— 速度被减到 0 时保底,避免永远不动(05 §4 #8)
@export var action_gauge_min_speed: float = 1.0

@export_group("减伤 / 招架")
## 减伤常数除法的 K:减伤率 = 有效防御 / (有效防御 + K)(待调,05 §4 #1)
@export var k_damage_reduction: float = 100.0
## 逃跑成功率的 K:成功率 = 速度 / (速度 + K_escape)—— 与减伤的 K 是两个常数(05 §4 #2)
@export var k_escape: float = 100.0
## 破防时的承伤倍率
@export var broken_damage_mult: float = 1.5

@export_group("命中率 / 暴击")
## 暴击伤害倍率
@export var crit_damage_mult: float = 1.5
## 屏障最大值 = 防御 × 此值
@export var barrier_defense_mult: float = 5.0

@export_group("护盾 / 韧性")
## 护盾上限 = 当前最大 HP × 此值
@export var shield_max_ratio: float = 1.0
## 冲击力 → 韧性累积的换算比(05 §4 #4,待定)
@export var tenacity_coefficient: float = 1.0

@export_group("强击(规则写死代码,此处仅供 UI 显示)")
## 强击模式回合上限 —— 代码里同样写死 5,两者必须一致(05 §2 特殊说明)
@export var strong_mode_max_turns: int = 5
## 武士刀退出保留血量 = 身外身层数 × 此值
@export var strong_exit_hp_ratio: float = 0.10
