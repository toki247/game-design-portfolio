class_name CoreAmp
extends Resource
## 核心增幅(02-系统设计.md §1.6 CoreAmp)—— 每个核心独立
##
## ⚠️ 强击核心的腿部增幅是「双档」(已定 8):normal 一套,strong_mode 一套。

enum AmpType { PASSIVE, ACTIVE }

## 被动还是主动
@export var type: AmpType = AmpType.PASSIVE
## 触发描述("每消耗 X 能量" / "主动释放" / "受到伤害" / "常驻")
@export var trigger: String = ""
## 冷却回合数(仅 ACTIVE 有)
@export var cooldown: int = 0

@export_group("双档参数")
## 普通模式参数
@export var normal_effect: StatEffect
## 强击模式内参数(数值更强)
@export var strong_mode_effect: StatEffect
## 其他核心用单一参数
@export var effect: StatEffect
