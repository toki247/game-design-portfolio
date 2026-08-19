extends CanvasLayer

@onready var hp_label: Label = $HPContainer/HPLabel
@onready var ability_container: HBoxContainer = $AbilityContainer
@onready var boss_hp_label: Label = $BossHPContainer/BossHPLabel

func _ready() -> void:
	add_to_group("hud")
	update_hp(5)
	update_boss_hp(3, 3)

func update_hp(current_hp: int) -> void:
	if hp_label:
		hp_label.text = "HP: " + str(current_hp) + " / 5"

func update_boss_hp(current_hp: int, max_hp: int) -> void:
	if boss_hp_label:
		boss_hp_label.text = "Boss HP: " + str(current_hp) + " / " + str(max_hp)

func update_abilities(abilities: Dictionary) -> void:
	if not ability_container:
		return
	for child in ability_container.get_children():
		child.queue_free()
	var ability_names = ["sword", "shield", "bow", "charm"]
	for ability_name in ability_names:
		var label := Label.new()
		if abilities.get(ability_name, false):
			label.text = "[" + ability_name + "]"
			label.modulate = Color(1, 1, 1)
		else:
			label.text = "[X " + ability_name + "]"
			label.modulate = Color(0.5, 0.5, 0.5)
		ability_container.add_child(label)