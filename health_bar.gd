extends Control

var current_hp: int = 3
var max_hp: int = 3

@onready var container: HBoxContainer = $HBoxContainer

var full_hp_texture = preload("res://GoatFighter/Icons/HP1.png")
var empty_hp_texture = preload("res://GoatFighter/Icons/EmptyHP.png")


## Call this during combat setup to build total hearts and initial health.
func setup_hp(initial_hp: int, max_health: int = -1) -> void:
	if max_health <= 0:
		max_hp = initial_hp
	else:
		max_hp = max_health

	current_hp = clamp(initial_hp, 0, max_hp)
	_rebuild_hearts()


## Call this during combat whenever a goat takes damage.
func set_hp(new_hp: int) -> void:
	current_hp = clamp(new_hp, 0, max_hp)
	_update_heart_textures()


func _rebuild_hearts() -> void:
	if container == null:
		return

	# Remove existing static children instantly
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

	# Create clean TextureRect nodes for each heart point
	for i in range(max_hp):
		var heart := TextureRect.new()
		heart.name = "HP" + str(i + 1)
		heart.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		heart.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		heart.custom_minimum_size = Vector2(32, 32)
		container.add_child(heart)

	_update_heart_textures()


func _update_heart_textures() -> void:
	var children = container.get_children()
	for i in range(children.size()):
		if children[i] is TextureRect:
			if i < current_hp:
				children[i].texture = full_hp_texture
			else:
				children[i].texture = empty_hp_texture
