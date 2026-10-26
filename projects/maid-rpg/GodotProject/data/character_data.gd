class_name CharacterData
extends Resource
## 玩家角色配置(5 属性 + 装备)

@export var id: StringName = &""
@export var display_name: String = ""
@export var level: int = 1

@export_group("5 属性")
@export var physique: float = 10.0
@export var strength: float = 10.0
@export var speed: float = 10.0
@export var agility: float = 10.0
@export var luck: float = 10.0

@export_group("装备 / 技能")
@export var weapon_attack: float = 0.0
@export var skills: Array[SkillData] = []
## 韧性上限(每单位不同,05 §4 #5 待定)
@export var tenacity_max: float = 0.0
