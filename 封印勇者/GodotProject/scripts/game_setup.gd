extends Node

# 运行时配置 InputMap(避免手动在 Editor 里改)
# Godot 4 中,可以在游戏启动时通过脚本配置 InputMap
#
# 2026-07-01 更新:
# - shield 从 L 改为 U
# - 新增 bow(I 键)
# - 新增 interact(J 键,与 attack 共用,通过优先级判断)
# - 移动保持 WASD(八方向)

func _ready() -> void:
	print("[GameSetup] _ready called")
	setup_input_map()
	print("[GameSetup] InputMap actions after setup: ", InputMap.get_actions().size())

func setup_input_map() -> void:
	var bindings: Dictionary = {
		# 移动(八方向,WASD / 方向键)
		"move_left": [KEY_A, KEY_LEFT],
		"move_right": [KEY_D, KEY_RIGHT],
		"move_up": [KEY_W, KEY_UP],
		"move_down": [KEY_S, KEY_DOWN],
		# 跳跃(待用户拍板是否保留)
		"jump": [KEY_SPACE],
		# 战斗
		"attack": [KEY_J],      # 剑挥砍(起手→挥砍→结束→收剑,4 段)
		"dodge": [KEY_K],       # 翻滚(起手→翻滚→起身,3 段,无敌帧)
		"shield": [KEY_U],      # 盾防御(挡前方)→ 强化后弹反
		"bow": [KEY_I],         # 弓箭(射箭 → 落地 → 回收)
		"use_charm": [KEY_E],   # 护身符(破解黑雾)
		# 交互(跟 attack 共用 J,优先级判断)
		"interact": [KEY_J],
	}

	for action_name in bindings.keys():
		if not InputMap.has_action(action_name):
			InputMap.add_action(action_name)
		for keycode in bindings[action_name]:
			var ev := InputEventKey.new()
			ev.physical_keycode = keycode
			InputMap.action_add_event(action_name, ev)

	print("InputMap 配置完成:")
	for action_name in InputMap.get_actions():
		if action_name in bindings:
			print("  - ", action_name)