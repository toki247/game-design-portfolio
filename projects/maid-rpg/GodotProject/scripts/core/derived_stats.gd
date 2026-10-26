class_name DerivedStats
extends RefCounted
## 5 属性派生出来的战斗数值(02-系统设计.md §1.9 公式表)
##
## **单位约定**:所有「率」用**百分数点**(10 = 10%),不是 0~1 的比例。
## 理由:招架率 = 闪避率 + 减伤率(已定 7),两项必须同单位才能相加;
##       而 05 §5 调试基准里写的是「防 50 → 33%」这种百分数点口径。
##       代码里凡是用到率的地方都按百分数点算,别混。

## 最大生命值 = 体格 × 2
var max_hp: float = 0.0
## 攻击力 = 力量 + 武器攻击 + buff
var attack: float = 0.0
## 防御 = 体格
var defense: float = 0.0
## 行动条速度(条/秒)= 速度 × action_gauge_speed_mult
var action_gauge_speed: float = 0.0

@export_group("率(百分数点)")
## 闪避率 = (幸运 + 速度) / 2,向上取整
var evasion_pct: float = 0.0
## 暴击率 = (技巧 + 幸运) / 2
var crit_pct: float = 0.0
## 减伤率 = 有效防御 / (有效防御 + K) × 100
var damage_reduction_pct: float = 0.0
## 招架率 = 闪避率 + 减伤率
var parry_pct: float = 0.0
## 暴击伤害倍率
var crit_damage_mult: float = 1.5

@export_group("其它")
## 屏障最大值 = 防御 × barrier_defense_mult
var barrier_max: float = 0.0
