extends Control

# 仓库页面 - MVP
# 3 个分页:食材 / 装备 / 重要物品
# 食材:可堆叠(上限 99,数据中已经按 99 上限给测试值)
# 装备 / 重要物品:每件独立,不可堆叠
# 数据:从 Inventory autoload 读取(跨场景共享)

# --- 布局常量 ---
const GRID_COLUMNS: int = 6
const SLOT_SIZE: float = 72.0
const SLOT_GAP: float = 8.0
const MIN_VISIBLE_ROWS: int = 4

# --- Tab 配置 ---
const TAB_CATEGORIES: Array[String] = ["food", "equipment", "key_item"]
const TAB_LABELS: Array[String] = ["食材", "装备", "重要物品"]

# --- 状态 ---
var _current_category: String = "food"
var _tabs: Array[Button] = []
var _grid: GridContainer


func _ready() -> void:
	await get_tree().process_frame
	_build_ui()
	_refresh()


# ---------- UI 搭建 ----------

func _build_ui() -> void:
	# 背景(暗木色)
	var bg := ColorRect.new()
	bg.color = Color(0.13, 0.10, 0.08)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# 顶部 Header:标题 + 返回按钮
	var header := HBoxContainer.new()
	header.set_anchors_preset(Control.PRESET_TOP_WIDE)
	header.offset_left = 40
	header.offset_right = -40
	header.offset_top = 20
	header.offset_bottom = 80
	add_child(header)

	var title := Label.new()
	title.text = "仓库"
	title.add_theme_font_size_override("font_size", 40)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)

	var back_btn := Button.new()
	back_btn.text = "返回"
	back_btn.custom_minimum_size = Vector2(100, 50)
	back_btn.add_theme_font_size_override("font_size", 20)
	back_btn.pressed.connect(_on_back_pressed)
	header.add_child(back_btn)

	# Tab 栏
	var tab_bar := HBoxContainer.new()
	tab_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	tab_bar.offset_left = 40
	tab_bar.offset_right = -40
	tab_bar.offset_top = 100
	tab_bar.offset_bottom = 160
	tab_bar.add_theme_constant_override("separation", 16)
	add_child(tab_bar)

	for i in TAB_LABELS.size():
		var tab := Button.new()
		tab.text = TAB_LABELS[i]
		tab.custom_minimum_size = Vector2(140, 50)
		tab.add_theme_font_size_override("font_size", 22)
		tab.toggle_mode = true
		# toggled(toggled_on) 信号,后面 bind category
		tab.toggled.connect(_on_tab_toggled.bind(TAB_CATEGORIES[i]))
		tab_bar.add_child(tab)
		_tabs.append(tab)

	# Grid 容器(6 列,自动网格)
	_grid = GridContainer.new()
	_grid.columns = GRID_COLUMNS
	_grid.add_theme_constant_override("h_separation", int(SLOT_GAP))
	_grid.add_theme_constant_override("v_separation", int(SLOT_GAP))
	_grid.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_grid.offset_left = 40
	_grid.offset_right = -40
	_grid.offset_top = 180
	_grid.offset_bottom = -40
	add_child(_grid)


# ---------- 刷新逻辑 ----------

func _refresh() -> void:
	_refresh_tabs()
	_refresh_grid()


func _refresh_tabs() -> void:
	for i in _tabs.size():
		_tabs[i].button_pressed = (TAB_CATEGORIES[i] == _current_category)


func _refresh_grid() -> void:
	# 清空旧格子
	for child in _grid.get_children():
		child.queue_free()

	var items: Array = Inventory.get_items_by_category(_current_category)
	# 固定 MIN_VISIBLE_ROWS 行,空格子占位
	var total_slots: int = max(items.size(), GRID_COLUMNS * MIN_VISIBLE_ROWS)

	for i in total_slots:
		var slot: Button
		if i < items.size():
			slot = _make_item_slot(items[i])
		else:
			slot = _make_empty_slot()
		_grid.add_child(slot)


# ---------- 格子工厂 ----------

func _make_item_slot(item: Dictionary) -> Button:
	var slot := Button.new()
	slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	slot.text = item.get("icon_char", item.get("name", "?"))
	slot.add_theme_font_size_override("font_size", 24)
	slot.tooltip_text = item.get("name", "")
	slot.pressed.connect(_on_slot_pressed.bind(item))

	# 食材可堆叠:count > 1 时显示右上角
	if item.has("count") and int(item["count"]) > 1:
		var count_lbl := Label.new()
		count_lbl.text = "x%d" % int(item["count"])
		count_lbl.add_theme_font_size_override("font_size", 12)
		count_lbl.position = Vector2(SLOT_SIZE - 32, SLOT_SIZE - 18)
		count_lbl.size = Vector2(32, 18)
		count_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		slot.add_child(count_lbl)

	return slot


func _make_empty_slot() -> Button:
	var slot := Button.new()
	slot.custom_minimum_size = Vector2(SLOT_SIZE, SLOT_SIZE)
	slot.disabled = true
	slot.flat = true
	return slot


# ---------- 事件 ----------

func _on_tab_toggled(toggled_on: bool, category: String) -> void:
	# toggle_mode:再次点击会取消选中,这种情况忽略
	if not toggled_on:
		return
	_current_category = category
	_refresh_grid()


func _on_slot_pressed(item: Dictionary) -> void:
	var msg: String = "[仓库] 选中: %s (%s)" % [item.get("name", "?"), item.get("id", "")]
	print(msg)


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/restaurant_main.tscn")
