class_name PassiveFeature
extends Resource
## 腿部固定被动(02-系统设计.md §1.6 PassiveFeature)—— **所有核心共用**
##
## 腿部优先级:固定特性(恒生效)⊕ 核心增幅(按核心)。

enum Trigger { CONTINUOUS, EVERY_N_TURNS, ON_BATTLE_START }

## 触发方式
@export var trigger: Trigger = Trigger.CONTINUOUS
## trigger = EVERY_N_TURNS 时的间隔回合数
@export var trigger_interval: int = 0
## 效果
@export var effect: StatEffect
