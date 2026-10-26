class_name ModuleFeature
extends Resource
## 手部特性(02-系统设计.md §1.6 ModuleFeature)—— **只在火力核心下生效**
##
## 暗杀 / 强击核心下手部模块无特性,只有技能(已定 1)。

enum FeatureType { OVERHEAT, ARMOR_PIERCE, CHARGE }

@export var type: FeatureType = FeatureType.OVERHEAT
@export var display_name: String = ""

@export_group("OVERHEAT(枪炮)")
## 过热阈值(能量达到多少层触发)
@export var thresholds: Array[float] = []
## 每回合衰减
@export var decay_per_turn: float = 0.0
## 过载状态
@export var overload_state: BuffData

@export_group("ARMOR_PIERCE(双刀)")
## 基础防御穿透
@export var base_pierce: float = 0.0
## 爆发期防御穿透
@export var burst_pierce: float = 0.0
## 爆发状态
@export var burst_status: BuffData

@export_group("CHARGE(武士刀)")
## 蓄力技能 id
@export var charge_skill_id: StringName = &""
## 释放技能 id
@export var release_skill_id: StringName = &""
## 蓄力期间挂的 buff
@export var charge_buff: BuffData
