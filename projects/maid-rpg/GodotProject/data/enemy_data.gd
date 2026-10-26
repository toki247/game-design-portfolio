class_name EnemyData
extends Resource
## 敌人配置(结构见 02-系统设计.md §1.5 10.4 Enemy)
##
## ⚠️ 敌人数值整体待设计(03-内容设计.md §4 / 05 §4 #12):
##    5 属性 / 韧性上限 / 招式表 / 经验掉落表都还没定。
##    这里只把字段立住,填值是 S9 的活。

@export var id: StringName = &""
@export var display_name: String = ""
@export var level: int = 1

@export_group("5 属性")
@export var physique: float = 10.0
@export var strength: float = 10.0
@export var speed: float = 10.0
@export var agility: float = 10.0
@export var luck: float = 10.0

@export_group("战斗")
@export var weapon_attack: float = 0.0
@export var skills: Array[SkillData] = []
## 韧性上限(每单位不同)
@export var tenacity_max: float = 0.0
## 是否 BOSS —— 决定能不能逃跑(10.3:BOSS 战禁逃)
@export var is_boss: bool = false

@export_group("产出(待拉表)")
@export var exp_reward: int = 0
