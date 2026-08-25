extends Control

# 餐厅页(主菜单 → 餐厅入口) - 餐厅内的子系统入口
# 售卖已整合进烹饪,这里只保留:仓库 / 烹饪
# 数据驱动:ENTRIES 数组决定入口配置

# --- 常量 ---
const ENTRIES: Array[Dictionary] = [
	{"id": "inventory", "label": "仓库"},
	{"id": "cook",      "label": "烹饪"},
]

const BTN_WIDTH: float = 280.0
const BTN_HEIGHT: float = 70.0
const BTN_GAP: float = 30.0
const TITLE_FONT_SIZE: int = 56
const BTN_FONT_SIZE: int = 28
const STATUS_FONT_SIZE: int = 22

# --- 状态 ---
var _status_label: Label


func _ready() -> void:
	# 等一帧,确保 viewport 尺寸已确定(用于按钮居中定位)
	await get_tree().process_frame
	_build_ui()


func _build_ui() -> void:
	# 背景(暗木色,匹配餐厅主题)
	var bg := ColorRect.new()
	bg.color = Color(0.15, 0.12, 0.10)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# 标题
	var title := Label.new()
	title.text = "餐厅"
	title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 80
	title.offset_bottom = 160
	add_child(title)

	# 入口按钮(垂直居中布局)
	var viewport_w: float = get_viewport_rect().size.x
	var start_y: float = 320.0
	for i in ENTRIES.size():
		var entry: Dictionary = ENTRIES[i]
		var btn := Button.new()
		btn.text = entry["label"]
		btn.custom_minimum_size = Vector2(BTN_WIDTH, BTN_HEIGHT)
		btn.add_theme_font_size_override("font_size", BTN_FONT_SIZE)
		btn.position = Vector2(
			viewport_w / 2.0 - BTN_WIDTH / 2.0,
			start_y + i * (BTN_HEIGHT + BTN_GAP)
		)
		btn.size = Vector2(BTN_WIDTH, BTN_HEIGHT)
		btn.pressed.connect(_on_entry_pressed.bind(entry["id"], entry["label"]))
		add_child(btn)

	# 状态栏(底部)
	_status_label = Label.new()
	_status_label.text = "选择功能入口"
	_status_label.add_theme_font_size_override("font_size", STATUS_FONT_SIZE)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_status_label.offset_top = -60
	_status_label.offset_bottom = -20
	add_child(_status_label)


func _on_entry_pressed(entry_id: String, entry_label: String) -> void:
	# 已接场景:仓库 / 烹饪
	match entry_id:
		"inventory":
			get_tree().change_scene_to_file("res://scenes/warehouse.tscn")
		"cook":
			get_tree().change_scene_to_file("res://scenes/cook.tscn")
		_:
			var msg: String = "[%s] 功能建设中" % entry_label
			_status_label.text = msg
			print(msg, " (id=", entry_id, ")")
