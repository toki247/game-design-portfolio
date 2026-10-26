class_name ModuleData
extends Resource
## 模块配置(02-系统设计.md §1.6 Module)—— 18 个模块 = 18 份配置(S7 填充)
##
## 文档里用 map 表达「因核心而异」的部分:
##   skills_by_core      = { fire: [...], assassin: [...], strong: [...] }
##   hand_feature_by_core= { fire: ModuleFeature?, assassin: null, strong: null }
##   core_amp_by_core    = { fire: CoreAmp?, assassin: CoreAmp?, strong: CoreAmp? }
## 这里拆成显式字段(带类型、能被编辑器校验),一一对应上面三组。

enum PartType { HAND, LEG }
enum CoreType { FIRE, ASSASSIN, STRONG }

@export var id: StringName = &""
@export var display_name: String = ""
## 手部 / 腿部
@export var part_type: PartType = PartType.HAND
## 视觉资源标识(资源未定,02 §1.12)
@export var visual: String = ""
@export_multiline var description: String = ""

@export_group("技能(因核心而异)")
@export var fire_skills: Array[SkillData] = []
@export var assassin_skills: Array[SkillData] = []
@export var strong_skills: Array[SkillData] = []

@export_group("手部特性(只在火力核心下生效)")
## 暗杀 / 强击核心下手部无特性,只有技能(已定 1)
@export var fire_hand_feature: ModuleFeature
@export var assassin_hand_feature: ModuleFeature
@export var strong_hand_feature: ModuleFeature

@export_group("腿部固定被动(所有核心共用)")
@export var leg_feature: PassiveFeature

@export_group("核心增幅(每个核心独立)")
@export var fire_core_amp: CoreAmp
@export var assassin_core_amp: CoreAmp
@export var strong_core_amp: CoreAmp

## 取指定核心下的技能表
func get_skills(core: CoreType) -> Array[SkillData]:
	match core:
		CoreType.FIRE:
			return fire_skills
		CoreType.ASSASSIN:
			return assassin_skills
		CoreType.STRONG:
			return strong_skills
	return []

## 取指定核心下的手部特性(暗杀 / 强击下为 null)
func get_hand_feature(core: CoreType) -> ModuleFeature:
	match core:
		CoreType.FIRE:
			return fire_hand_feature
		CoreType.ASSASSIN:
			return assassin_hand_feature
		CoreType.STRONG:
			return strong_hand_feature
	return null

## 取指定核心下的核心增幅
func get_core_amp(core: CoreType) -> CoreAmp:
	match core:
		CoreType.FIRE:
			return fire_core_amp
		CoreType.ASSASSIN:
			return assassin_core_amp
		CoreType.STRONG:
			return strong_core_amp
	return null
