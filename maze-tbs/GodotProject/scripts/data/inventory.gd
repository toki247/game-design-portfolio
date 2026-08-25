extends Node

# Inventory autoload — 跨场景共享库存(仓库 / 烹饪都读这里)
# 物品元数据 + 数量存储,API: get_count / get_items_by_category / remove_items / add_items
# 钱(money)也暂存这里,后续可拆到 Economy autoload

# --- 物品元数据(id → {name, category, icon_char}) ---
const ITEM_META: Dictionary = {
	"food_mushroom":        {"name": "蘑菇",     "category": "food",      "icon_char": "M"},
	"food_lizard_tail":     {"name": "蜥蜴尾",   "category": "food",      "icon_char": "L"},
	"food_dragon_meat":     {"name": "龙肉",     "category": "food",      "icon_char": "D"},
	"food_rabbit":          {"name": "兔肉",     "category": "food",      "icon_char": "R"},
	"food_herb":            {"name": "草药",     "category": "food",      "icon_char": "H"},
	"food_honey":           {"name": "蜂蜜",     "category": "food",      "icon_char": "蜂"},
	"eq_iron_sword":        {"name": "铁剑",     "category": "equipment", "icon_char": "剑"},
	"eq_leather_armor":     {"name": "皮甲",     "category": "equipment", "icon_char": "甲"},
	"eq_shield":            {"name": "盾牌",     "category": "equipment", "icon_char": "盾"},
	"eq_boots":             {"name": "皮靴",     "category": "equipment", "icon_char": "鞋"},
	"key_ancient_map":      {"name": "古老地图", "category": "key_item",  "icon_char": "图"},
	"key_father_relic":     {"name": "父亲遗物", "category": "key_item",  "icon_char": "物"},
}

# --- 初始库存(id → count) ---
const INITIAL_ITEMS: Dictionary = {
	"food_mushroom":     12,
	"food_lizard_tail":  5,
	"food_dragon_meat":  3,
	"food_rabbit":       45,
	"food_herb":         99,
	"food_honey":        1,
	"eq_iron_sword":     1,
	"eq_leather_armor":  1,
	"eq_shield":         1,
	"eq_boots":          1,
	"key_ancient_map":   1,
	"key_father_relic":  1,
}

# 初始金币
const INITIAL_MONEY: int = 100

# --- 运行时状态 ---
var _items: Dictionary = {}
var money: int = 0


func _ready() -> void:
	_items = INITIAL_ITEMS.duplicate(true)
	money = INITIAL_MONEY


# --- API ---

func get_count(item_id: String) -> int:
	return int(_items.get(item_id, 0))


func get_items_by_category(category: String) -> Array:
	# 返回 [{id, name, icon_char, count}, ...]
	var result: Array = []
	for id in _items:
		if int(_items[id]) <= 0:
			continue
		var meta: Dictionary = ITEM_META.get(id, {})
		if meta.get("category", "") == category:
			result.append({
				"id": id,
				"name": meta.get("name", id),
				"icon_char": meta.get("icon_char", "?"),
				"count": int(_items[id]),
			})
	return result


# 校验 + 扣库存,任一不够则整体回滚(返回 false)
func remove_items(consume: Dictionary) -> bool:
	# 先校验
	for id in consume:
		if get_count(id) < int(consume[id]):
			return false
	# 扣
	for id in consume:
		_items[id] = get_count(id) - int(consume[id])
	return true


func add_items(add: Dictionary) -> void:
	for id in add:
		_items[id] = get_count(id) + int(add[id])
