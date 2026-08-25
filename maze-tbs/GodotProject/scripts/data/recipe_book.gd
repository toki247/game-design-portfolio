extends Node

# RecipeBook autoload — 食谱库
# MVP:全部食谱默认解锁,后续可接"通过战斗/探索解锁"逻辑

const RECIPES: Array = [
	{
		"id": "recipe_stew",
		"name": "魔物炖肉",
		"icon_char": "炖",
		"desc": "用蜥蜴尾慢炖的家常菜,餐厅的招牌,温暖又饱腹。",
		"ingredients": [
			{"item_id": "food_lizard_tail", "count": 1},
		],
		"sell_price": 25,
	},
	{
		"id": "recipe_herb_soup",
		"name": "草药汤",
		"icon_char": "汤",
		"desc": "用草药熬制的清汤,朴素而美味,冒险者最爱的暖身汤。",
		"ingredients": [
			{"item_id": "food_herb", "count": 2},
		],
		"sell_price": 15,
	},
	{
		"id": "recipe_dragon_feast",
		"name": "龙肉大餐",
		"icon_char": "宴",
		"desc": "龙肉配蜂蜜的豪华料理,一道顶十道,高价值宴客菜。",
		"ingredients": [
			{"item_id": "food_dragon_meat", "count": 1},
			{"item_id": "food_honey", "count": 1},
		],
		"sell_price": 120,
	},
]


# MVP:全部解锁
func get_unlocked() -> Array:
	return RECIPES
