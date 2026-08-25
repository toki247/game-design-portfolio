extends Control

# 烹饪页面 - MVP
# 流程:从 RecipeBook 取解锁食谱 → 每个食谱 1 个 panel(+/- 控数量) → 确认烹饪
#   → 扣食材(Inventory.remove_items) + 加金币(Inventory.money)
#   → 弹"获得 X 金币" → 弹"结束烹饪?" → 回餐厅主页

# --- 状态 ---
# 每个 recipe state:{recipe, count, max_count, panel, qty_lbl, max_hint, ing_box}
var _states: Array = []
var _total_label: Label
var _money_label: Label
var _confirm_btn: Button


func _ready() -> void:
	await get_tree().process_frame
	_build_ui()
	_refresh_total()


# ---------- UI 搭建 ----------

func _build_ui() -> void:
	# 背景
	var bg := ColorRect.new()
	bg.color = Color(0.15, 0.12, 0.10)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# 顶部 Header
	var header := HBoxContainer.new()
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 40; header.offset_right = -40
	header.offset_top = 20; header.offset_bottom = 80
	add_child(header)

	var title := Label.new()
	title.text = "烹饪"
	title.add_theme_font_size_override("font_size", 40)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	# 当前金币显示
	_money_label = Label.new()
	_money_label.text = "金币: %d" % Inventory.money
	_money_label.add_theme_font_size_override("font_size", 22)
	_money_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	header.add_child(_money_label)

	var back_btn := Button.new()
	back_btn.text = "返回"
	back_btn.custom_minimum_size = Vector2(100, 50)
	back_btn.add_theme_font_size_override("font_size", 20)
	back_btn.pressed.connect(_on_back_pressed)
	header.add_child(back_btn)

	# 食谱列表(垂直滚动,容纳任意数量食谱不被遮挡)
	var scroll := ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_TOP_WIDE)
	scroll.offset_left = 40; scroll.offset_right = -40
	scroll.offset_top = 100; scroll.offset_bottom = -100
	add_child(scroll)

	var recipes_box := VBoxContainer.new()
	recipes_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	recipes_box.add_theme_constant_override("separation", 16)
	scroll.add_child(recipes_box)

	for recipe in RecipeBook.get_unlocked():
		var state: Dictionary = {
			"recipe": recipe,
			"count": 0,
			"max_count": 0,
		}
		var panel := _make_recipe_panel(state)
		recipes_box.add_child(panel)
		state["panel"] = panel
		_update_max_count(state)
		_states.append(state)

	# 底部 Footer
	var footer := HBoxContainer.new()
	footer.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	footer.offset_left = 40; footer.offset_right = -40
	footer.offset_top = -90; footer.offset_bottom = -20
	footer.add_theme_constant_override("separation", 20)
	add_child(footer)

	_total_label = Label.new()
	_total_label.text = "预计获得: 0 金币"
	_total_label.add_theme_font_size_override("font_size", 24)
	_total_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_total_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	footer.add_child(_total_label)

	_confirm_btn = Button.new()
	_confirm_btn.text = "确认烹饪"
	_confirm_btn.custom_minimum_size = Vector2(200, 60)
	_confirm_btn.add_theme_font_size_override("font_size", 24)
	_confirm_btn.pressed.connect(_on_confirm_pressed)
	footer.add_child(_confirm_btn)


func _make_recipe_panel(state: Dictionary) -> Panel:
	var recipe: Dictionary = state["recipe"]
	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(0, 170)

	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 16; v.offset_right = -16
	v.offset_top = 12; v.offset_bottom = -12
	v.add_theme_constant_override("separation", 8)
	panel.add_child(v)

	# 标题
	var title_lbl := Label.new()
	title_lbl.text = "%s  (售价 %d 金币/份)" % [recipe["name"], int(recipe.get("sell_price", 0))]
	title_lbl.add_theme_font_size_override("font_size", 26)
	v.add_child(title_lbl)

	# 内容(图 + 信息)
	var content := HBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	v.add_child(content)

	# 图占位
	var icon_box := Control.new()
	icon_box.custom_minimum_size = Vector2(100, 100)
	content.add_child(icon_box)
	var icon_bg := ColorRect.new()
	icon_bg.color = Color(0.3, 0.25, 0.2)
	icon_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_box.add_child(icon_bg)
	var icon_lbl := Label.new()
	icon_lbl.text = recipe.get("icon_char", "?")
	icon_lbl.add_theme_font_size_override("font_size", 48)
	icon_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	icon_lbl.set_anchors_preset(Control.PRESET_FULL_RECT)
	icon_box.add_child(icon_lbl)

	# 信息区
	var info := VBoxContainer.new()
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_child(info)

	var desc_lbl := Label.new()
	desc_lbl.text = recipe.get("desc", "")
	desc_lbl.add_theme_font_size_override("font_size", 16)
	desc_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	info.add_child(desc_lbl)

	# 食材列表(初始为空,_update_max_count 会填)
	var ing_box := VBoxContainer.new()
	ing_box.name = "Ingredients"
	info.add_child(ing_box)
	state["ing_box"] = ing_box

	# 数量选择
	var qty_box := HBoxContainer.new()
	qty_box.add_theme_constant_override("separation", 12)
	v.add_child(qty_box)

	var minus_btn := Button.new()
	minus_btn.text = "−"
	minus_btn.custom_minimum_size = Vector2(50, 40)
	minus_btn.add_theme_font_size_override("font_size", 24)
	qty_box.add_child(minus_btn)

	var qty_lbl := Label.new()
	qty_lbl.text = "0"
	qty_lbl.add_theme_font_size_override("font_size", 26)
	qty_lbl.custom_minimum_size = Vector2(60, 40)
	qty_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	qty_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	qty_box.add_child(qty_lbl)

	var plus_btn := Button.new()
	plus_btn.text = "+"
	plus_btn.custom_minimum_size = Vector2(50, 40)
	plus_btn.add_theme_font_size_override("font_size", 24)
	qty_box.add_child(plus_btn)

	var max_hint := Label.new()
	max_hint.text = "(最多 0)"
	max_hint.add_theme_font_size_override("font_size", 16)
	max_hint.name = "MaxHint"
	qty_box.add_child(max_hint)

	state["qty_lbl"] = qty_lbl
	state["max_hint"] = max_hint

	minus_btn.pressed.connect(_on_minus_pressed.bind(state))
	plus_btn.pressed.connect(_on_plus_pressed.bind(state))

	return panel


# ---------- 数量 / 库存联动 ----------

func _update_max_count(state: Dictionary) -> void:
	var recipe: Dictionary = state["recipe"]
	var max_c: int = 999
	for ing in recipe.get("ingredients", []):
		var have: int = Inventory.get_count(String(ing["item_id"]))
		var per: int = int(ing["count"])
		if per <= 0:
			continue
		max_c = min(max_c, int(floor(float(have) / float(per))))
	state["max_count"] = max_c
	if state["max_hint"]:
		state["max_hint"].text = "(最多 %d)" % max_c

	# 食材列表显示 + 库存不足标红
	var ing_box: VBoxContainer = state["ing_box"]
	if ing_box:
		# 清旧
		for child in ing_box.get_children():
			child.queue_free()
		for ing in recipe.get("ingredients", []):
			var ing_name: String = String(Inventory.ITEM_META.get(ing["item_id"], {}).get("name", ing["item_id"]))
			var need: int = int(ing["count"])
			var have: int = Inventory.get_count(String(ing["item_id"]))
			var lbl := Label.new()
			lbl.text = "  • %s × %d  (库存: %d)" % [ing_name, need, have]
			lbl.add_theme_font_size_override("font_size", 16)
			lbl.modulate = Color(1.0, 0.5, 0.5) if have < need else Color(1, 1, 1)
			ing_box.add_child(lbl)


func _on_minus_pressed(state: Dictionary) -> void:
	if int(state["count"]) > 0:
		state["count"] = int(state["count"]) - 1
		state["qty_lbl"].text = str(state["count"])
		_refresh_total()


func _on_plus_pressed(state: Dictionary) -> void:
	if int(state["count"]) < int(state["max_count"]):
		state["count"] = int(state["count"]) + 1
		state["qty_lbl"].text = str(state["count"])
		_refresh_total()


func _refresh_total() -> void:
	var total: int = 0
	for state in _states:
		var recipe: Dictionary = state["recipe"]
		total += int(recipe.get("sell_price", 0)) * int(state["count"])
	_total_label.text = "预计获得: %d 金币  (当前: %d)" % [total, Inventory.money]
	if _money_label:
		_money_label.text = "金币: %d" % Inventory.money


# ---------- 确认烹饪 ----------

func _on_confirm_pressed() -> void:
	# 汇总:消耗清单 + 总价 + 总份数
	var total_count: int = 0
	var total_money: int = 0
	var consume: Dictionary = {}
	for state in _states:
		if int(state["count"]) <= 0:
			continue
		var recipe: Dictionary = state["recipe"]
		var c: int = int(state["count"])
		total_count += c
		total_money += int(recipe.get("sell_price", 0)) * c
		for ing in recipe.get("ingredients", []):
			var iid: String = String(ing["item_id"])
			consume[iid] = int(consume.get(iid, 0)) + int(ing["count"]) * c

	if total_count <= 0:
		await _show_dialog("提示", "请先选择要制作的料理。")
		return

	# 扣库存
	if not Inventory.remove_items(consume):
		await _show_dialog("失败", "库存不足,请减少制作数量。")
		_refresh_all_panels()
		return

	# 加金币
	Inventory.money += total_money
	_refresh_total()

	await _show_dialog("售卖成功", "本次烹饪共获得 %d 金币!" % total_money)
	await _show_dialog("结束烹饪", "返回餐厅主页?")
	get_tree().change_scene_to_file("res://scenes/restaurant_main.tscn")


func _refresh_all_panels() -> void:
	for state in _states:
		_update_max_count(state)
		if int(state["count"]) > int(state["max_count"]):
			state["count"] = int(state["max_count"])
			state["qty_lbl"].text = str(state["count"])
	_refresh_total()


# ---------- 弹窗(异步) ----------

func _show_dialog(title: String, msg: String) -> void:
	# 半透明遮罩
	var overlay := ColorRect.new()
	overlay.color = Color(0, 0, 0, 0.6)
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(overlay)

	var center := CenterContainer.new()
	center.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)

	var panel := Panel.new()
	panel.custom_minimum_size = Vector2(440, 240)
	center.add_child(panel)

	var v := VBoxContainer.new()
	v.set_anchors_preset(Control.PRESET_FULL_RECT)
	v.offset_left = 24; v.offset_right = -24
	v.offset_top = 24; v.offset_bottom = -24
	v.add_theme_constant_override("separation", 16)
	panel.add_child(v)

	var title_lbl := Label.new()
	title_lbl.text = title
	title_lbl.add_theme_font_size_override("font_size", 30)
	title_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(title_lbl)

	var msg_lbl := Label.new()
	msg_lbl.text = msg
	msg_lbl.add_theme_font_size_override("font_size", 22)
	msg_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	msg_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(msg_lbl)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	v.add_child(spacer)

	var ok_btn := Button.new()
	ok_btn.text = "确定"
	ok_btn.custom_minimum_size = Vector2(140, 50)
	ok_btn.add_theme_font_size_override("font_size", 22)
	ok_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	v.add_child(ok_btn)

	# 等待弹窗销毁后返回
	ok_btn.pressed.connect(func() -> void: overlay.queue_free())
	await overlay.tree_exited


# ---------- 返回 ----------

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/restaurant_main.tscn")
