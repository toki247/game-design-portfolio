class_name DotData
extends Resource
## DOT(持续伤害)定义 —— 裂伤 / 流血(05-数值与配置.md §2 提到挂在 buff_system 周期触发)
##
## ⚠️ DOT 的**结算时机**未定(05 §4 #7):回合制惯例是行动前 / 行动后,待定。
## 本类只描述数值,时机由 buff_system 决定。

@export var id: StringName = &""
@export var display_name: String = ""
## 每跳固定伤害
@export var damage_per_tick: float = 0.0
## 每跳伤害占攻击力比例(与固定伤害相加)
@export var damage_ratio_of_attack: float = 0.0
## 触发间隔(回合)
@export var tick_interval_turns: int = 1
