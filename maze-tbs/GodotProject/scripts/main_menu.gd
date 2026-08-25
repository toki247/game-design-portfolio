extends Control

# 顶级主菜单 - 3 大功能入口
# 餐厅 / 地下城 / 养成
# 游戏名待定(GDD §1.1 标 [待定]),暂用工作名"迷宫餐馆"作标题

# --- 常量 ---
const ENTRIES: Array[Dictionary] = [
	{"id": "restaurant", "label": "餐厅"},
	{"id": "dungeon",    "label": "地下城"},
	{"id": "growth",     "label": "养成"},
]

const BTN_WIDTH: float = 320.0
const BTN_HEIGHT: float = 80.0
const BTN_GAP: float = 40.0
const TITLE_FONT_SIZE: int = 64
const BTN_FONT_SIZE: int = 32
const STATUS_FONT_SIZE: int = 22

# --- 状态 ---
var _status_label: Label


func _ready() -> void:
	# 等一帧,确保 viewport 尺寸已确定
	await get_tree().process_frame
	_build_ui()


func _build_ui() -> void:
	# 背景(深色调,主菜单)
	var bg := ColorRect.new()
	bg.color = Color(0.10, 0.08, 0.06)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# 标题
	var title := Label.new()
	title.text = "迷宫餐馆"
	title.add_theme_font_size_override("font_size", TITLE_FONT_SIZE)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_TOP_WIDE)
	title.offset_top = 100
	title.offset_bottom = 200
	add_child(title)

	# 3 个大按钮
	var viewport_w: float = get_viewport_rect().size.x
	var start_y: float = 280.0
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

	# 状态栏
	_status_label = Label.new()
	_status_label.text = "选择功能入口"
	_status_label.add_theme_font_size_override("font_size", STATUS_FONT_SIZE)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_status_label.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	_status_label.offset_top = -60
	_status_label.offset_bottom = -20
	add_child(_status_label)


func _on_entry_pressed(entry_id: String, entry_label: String) -> void:
	match entry_id:
		"restaurant":
			get_tree().change_scene_to_file("res://scenes/restaurant_main.tscn")
		_:
			var msg: String = "[%s] 功能建设中" % entry_label
			_status_label.text = msg
			print(msg, " (id=", entry_id, ")")
