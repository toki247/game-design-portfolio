class_name BuffData
extends Resource
## 增益 / 减益通用结构(02-系统设计.md §1.6 BuffDebuff)
##
## 护盾不走这个结构 —— 它有独立的吸收逻辑,见 Shield(§1.6)。

enum BuffType {
	OVERHEAT,
	MIND_EYE,
	SHEATH,
	BURST_STATE,
	STRONG_MODE,
	WOUND,
	HEAVY_WOUND,
	SWORD_INTENT,
	HASTE,
	RECOVERY,
	SMOKE,
	PARRY,
	HARD_EDGE,
	DECAY,
	OUTSIDE_BODY,
	BACKWATER,
}

## 增益还是减益
@export var is_debuff: bool = false
## 具体类型
@export var type: BuffType = BuffType.OVERHEAT
@export var display_name: String = ""
@export_multiline var description: String = ""

@export_group("效果")
## 属性增减效果
@export var effect: StatEffect
## 附带 DOT(带周期触发的减益,如裂伤 / 流血)
@export var dot: DotData

@export_group("层数 / 持续")
## 最大层数,1 = 不叠层
@export var max_stacks: int = 1
## 持续回合数,0 = 永久
@export var duration: int = 0
## 每回合衰减量
@export var decay_per_turn: float = 0.0
