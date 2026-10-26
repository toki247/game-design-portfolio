class_name SkillData
extends Resource
## 技能配置(结构见 02-系统设计.md §1.6 Skill)
##
## 数值实例放 `config/skills/*.tres`,这里只定义字段。

enum SkillType { NORMAL, BURST }

@export var id: StringName = &""
@export var display_name: String = ""
@export var type: SkillType = SkillType.NORMAL
@export_multiline var description: String = ""

@export_group("伤害")
## 基础倍率数组(如 180% / 300% → [1.8] / [3.0]);多段伤害时按序取值
@export var damage_multipliers: Array[float] = []
## 固定伤害加成(在攻击力之外直接加)
@export var flat_damage: float = 0.0
## 冲击力倍率 —— 韧性系统的输入项:韧性累积 = 招式伤害 × 此倍率 × 韧性系数
@export var impact_multiplier: float = 1.0

@export_group("命中")
## 命中率加成(百分数点)
@export var hit_bonus_pct: float = 0.0
## 暴击率加成(百分数点)
@export var crit_bonus_pct: float = 0.0

@export_group("消耗 / 冷却")
## 能量消耗
@export var energy_cost: int = 0
## 使用后获得能量
@export var energy_gain_per_use: int = 0
## 冷却回合数
@export var cooldown_turns: int = 0

@export_group("范围 / 效果")
## 目标数量(1 = 单体)
@export var aoe_targets: int = 1
## 附加状态效果(BuffDebuff 结构)
@export var effects: Array[BuffData] = []

## 取第 index 段伤害倍率(越界回落到最后一段;没配则 1.0)
func get_damage_multiplier(index: int = 0) -> float:
	if damage_multipliers.is_empty():
		return 1.0
	return damage_multipliers[mini(index, damage_multipliers.size() - 1)]
