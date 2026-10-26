extends Node
## 单例:加载 config/ 下的配置(系统规格书 §1 scripts/autoload/)
##
## 逻辑层(core/)不依赖这个单例 —— 自测脚本直接 load .tres,保证 core 能脱离场景跑。

const COMBAT_CONFIG_PATH := "res://config/combat_config.tres"

## 全局战斗配置
var combat_config: CombatConfig

func _ready() -> void:
	combat_config = load(COMBAT_CONFIG_PATH) as CombatConfig
	if combat_config == null:
		push_error("[game_data] 加载配置失败: %s" % COMBAT_CONFIG_PATH)
		return
	print("[game_data] 已加载战斗配置: %s" % COMBAT_CONFIG_PATH)
