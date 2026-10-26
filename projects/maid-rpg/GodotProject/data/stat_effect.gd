class_name StatEffect
extends Resource
## 通用属性增减效果(02-系统设计.md §1.6 PassiveFeature / CoreAmp 里的 effect 结构)
##
## 所有数值型增减走同一个结构,不按用途分叉(§1.6 设计原则)。

enum Target { SELF, ENEMY, ALLY }
enum Stat {
	ATTACK,
	IMPACT,
	CRIT_RATE,
	PARRY_RATE,
	DEFENSE,
	DAMAGE_RECEIVED,
	MAX_HP,
	SPEED,
	ACCURACY,
	EVASION,
}
enum Mode { ADD, MULTIPLY, OVERRIDE }

## 作用目标
@export var target: Target = Target.SELF
## 影响的属性
@export var stat: Stat = Stat.ATTACK
## 增减方式
@export var mode: Mode = Mode.ADD
## 数值(百分数点 / 固定值,取决于 stat)
@export var value: float = 0.0
## 持续回合数,0 = 永久(直到战斗结束)
@export var duration: int = 0
